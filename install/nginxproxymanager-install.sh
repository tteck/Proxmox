#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get update
$STD apt-get -y install \
  sudo \
  mc \
  curl \
  gnupg \
  make \
  g++ \
  gcc \
  ca-certificates \
  apache2-utils \
  logrotate \
  build-essential \
  python3-dev \
  git \
  lsb-release
msg_ok "Installed Dependencies"

msg_info "Installing Python"
$STD apt-get install -y -q --no-install-recommends python3 python3-pip python3-venv
$STD pip3 install --upgrade setuptools
$STD pip3 install --upgrade pip
$STD python3 -m venv /opt/certbot/
if [ "$(getconf LONG_BIT)" = "32" ]; then
  $STD python3 -m pip install --no-cache-dir -U cryptography==3.3.2
fi
$STD python3 -m pip install --no-cache-dir cffi certbot
msg_ok "Installed Python"

msg_info "Installing Openresty"
$STD apt-key add <(curl -fsSL https://openresty.org/package/pubkey.gpg)
sh -c 'echo "deb http://openresty.org/package/debian $(lsb_release -cs) openresty" > /etc/apt/sources.list.d/openresty.list'
$STD apt-get -y update
$STD apt-get -y install --no-install-recommends openresty
msg_ok "Installed Openresty"

msg_info "Setting up Node.js Repository"
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_16.x)
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing Yarn"
$STD npm install --global yarn
msg_ok "Installed Yarn"

RELEASE=$(curl -s https://api.github.com/repos/NginxProxyManager/nginx-proxy-manager/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 3, length($2)-4) }')

msg_info "Downloading Nginx Proxy Manager v2.9.22"
wget -q https://codeload.github.com/NginxProxyManager/nginx-proxy-manager/tar.gz/v2.9.22 -O - | tar -xz
cd ./nginx-proxy-manager-2.9.22
msg_ok "Downloaded Nginx Proxy Manager v2.9.22"

msg_info "Setting up Enviroment"
ln -sf /usr/bin/python3 /usr/bin/python
ln -sf /usr/bin/certbot /opt/certbot/bin/certbot
ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx
ln -sf /usr/local/openresty/nginx/ /etc/nginx

sed -i "s+0.0.0+2.9.22+g" backend/package.json
sed -i "s+0.0.0+2.9.22+g" frontend/package.json

sed -i 's+^daemon+#daemon+g' docker/rootfs/etc/nginx/nginx.conf
NGINX_CONFS=$(find "$(pwd)" -type f -name "*.conf")
for NGINX_CONF in $NGINX_CONFS; do
  sed -i 's+include conf.d+include /etc/nginx/conf.d+g' "$NGINX_CONF"
done

mkdir -p /var/www/html /etc/nginx/logs
cp -r docker/rootfs/var/www/html/* /var/www/html/
cp -r docker/rootfs/etc/nginx/* /etc/nginx/
cp docker/rootfs/etc/letsencrypt.ini /etc/letsencrypt.ini
cp docker/rootfs/etc/logrotate.d/nginx-proxy-manager /etc/logrotate.d/nginx-proxy-manager
ln -sf /etc/nginx/nginx.conf /etc/nginx/conf/nginx.conf
rm -f /etc/nginx/conf.d/dev.conf

mkdir -p /tmp/nginx/body \
  /run/nginx \
  /data/nginx \
  /data/custom_ssl \
  /data/logs \
  /data/access \
  /data/nginx/default_host \
  /data/nginx/default_www \
  /data/nginx/proxy_host \
  /data/nginx/redirection_host \
  /data/nginx/stream \
  /data/nginx/dead_host \
  /data/nginx/temp \
  /var/lib/nginx/cache/public \
  /var/lib/nginx/cache/private \
  /var/cache/nginx/proxy_temp

chmod -R 777 /var/cache/nginx
chown root /tmp/nginx

echo resolver "$(awk 'BEGIN{ORS=" "} $1=="nameserver" {print ($2 ~ ":")? "["$2"]": $2}' /etc/resolv.conf);" >/etc/nginx/conf.d/include/resolvers.conf

if [ ! -f /data/nginx/dummycert.pem ] || [ ! -f /data/nginx/dummykey.pem ]; then
  echo -en "${GN} Generating dummy SSL Certificate... "
  openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/O=Nginx Proxy Manager/OU=Dummy Certificate/CN=localhost" -keyout /data/nginx/dummykey.pem -out /data/nginx/dummycert.pem &>/dev/null
fi

mkdir -p /app/global /app/frontend/images
cp -r backend/* /app
cp -r global/* /app/global
msg_ok "Set up Enviroment"

msg_info "Building Frontend"
cd ./frontend
export NODE_ENV=development
$STD yarn install --network-timeout=30000
$STD yarn build
cp -r dist/* /app/frontend
cp -r app-images/* /app/frontend/images
msg_ok "Built Frontend"

msg_info "Initializing Backend"
rm -rf /app/config/default.json
if [ ! -f /app/config/production.json ]; then
  cat <<'EOF' >/app/config/production.json
{
  "database": {
    "engine": "knex-native",
    "knex": {
      "client": "sqlite3",
      "connection": {
        "filename": "/data/database.sqlite"
      }
    }
  }
}
EOF
fi
cd /app
export NODE_ENV=development
$STD yarn install --network-timeout=30000
msg_ok "Initialized Backend"

msg_info "Creating Service"
cat <<'EOF' >/lib/systemd/system/npm.service
[Unit]
Description=Nginx Proxy Manager
After=network.target
Wants=openresty.service

[Service]
Type=simple
Environment=NODE_ENV=production
ExecStartPre=-mkdir -p /tmp/nginx/body /data/letsencrypt-acme-challenge
ExecStart=/usr/bin/node index.js --abort_on_uncaught_exception --max_old_space_size=250
WorkingDirectory=/app
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
msg_ok "Created Service"

motd_ssh
root

msg_info "Starting Services"
$STD systemctl enable --now openresty
$STD systemctl enable --now npm
msg_ok "Started Services"

msg_info "Cleaning up"
rm -rf ../nginx-proxy-manager-*
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
