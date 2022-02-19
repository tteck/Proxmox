#!/usr/bin/env bash

set -o errexit  
set -o errtrace 
set -o nounset  
set -o pipefail 
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
CROSS='\033[1;31m\xE2\x9D\x8C\033[0m'
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
RETRY_NUM=5
RETRY_EVERY=3
NUM=$RETRY_NUM
trap die ERR
trap 'die "Script interrupted."' INT

function error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR:LXC] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}
echo -e "${CHECKMARK} \e[1;92m Setting up Container OS... \e[0m"
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
while [ "$(hostname -I)" = "" ]; do
  1>&2 echo -e "${CROSS} \e[1;31m No Network: \e[0m $(date)"
  sleep $RETRY_EVERY
  ((NUM--))
  if [ $NUM -eq 0 ]
  then
    1>&2 echo -e "${CROSS} \e[1;31m No Network After $RETRY_NUM Tries \e[0m"
    exit 1
  fi
done
  echo -e "${CHECKMARK} \e[1;92m Network Connected: \e[0m $(hostname -I)"

echo -e "${CHECKMARK} \e[1;92m Updating Container OS... \e[0m"
apt-get update &>/dev/null
apt-get -qqy upgrade &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Dependencies... \e[0m"
apt-get update &>/dev/null
apt-get -qqy install \
    sudo \
    curl \
    wget \
    gnupg \
    openssl \
    ca-certificates \
    apache2-utils \
    logrotate \
    build-essential \
    python3-dev \
    git \
    lsb-release &>/dev/null

  echo -e "${CHECKMARK} \e[1;92m Installing Python... \e[0m"
  apt-get install -y -q --no-install-recommends python3 python3-pip python3-venv &>/dev/null
  pip3 install --upgrade setuptools &>/dev/null
  pip3 install --upgrade pip &>/dev/null
  python3 -m venv /opt/certbot/ &>/dev/null
  if [ "$(getconf LONG_BIT)" = "32" ]; then
    python3 -m pip install --no-cache-dir -U cryptography==3.3.2 &>/dev/null
  fi
  python3 -m pip install --no-cache-dir cffi certbot &>/dev/null
  
echo -e "${CHECKMARK} \e[1;92m Installing Openresty... \e[0m"
wget -q -O - https://openresty.org/package/pubkey.gpg | apt-key add - &>/dev/null
codename=`grep -Po 'VERSION="[0-9]+ \(\K[^)]+' /etc/os-release` &>/dev/null
echo "deb http://openresty.org/package/debian $codename openresty" | tee /etc/apt/sources.list.d/openresty.list &>/dev/null
apt-get -y update &>/dev/null
apt-get -y install --no-install-recommends openresty &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Setting up Node.js Repository... \e[0m"
sudo curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - &>/dev/null
    
echo -e "${CHECKMARK} \e[1;92m Installing Node.js... \e[0m"
sudo apt-get install -y nodejs git make g++ gcc &>/dev/null
    
echo -e "${CHECKMARK} \e[1;92m Installing Yarn... \e[0m"
npm install --global yarn &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Downloading NPM v2.9.16... \e[0m"
wget -q https://codeload.github.com/NginxProxyManager/nginx-proxy-manager/tar.gz/v2.9.16 -O - | tar -xz &>/dev/null
cd ./nginx-proxy-manager-2.9.16

echo -e "${CHECKMARK} \e[1;92m Setting up Enviroment... \e[0m"
ln -sf /usr/bin/python3 /usr/bin/python
ln -sf /usr/bin/certbot /opt/certbot/bin/certbot
ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx
ln -sf /usr/local/openresty/nginx/ /etc/nginx

sed -i "s+0.0.0+#v2.9.16+g" backend/package.json
sed -i "s+0.0.0+#v2.9.16+g" frontend/package.json

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

echo resolver "$(awk 'BEGIN{ORS=" "} $1=="nameserver" {print ($2 ~ ":")? "["$2"]": $2}' /etc/resolv.conf);" > /etc/nginx/conf.d/include/resolvers.conf

if [ ! -f /data/nginx/dummycert.pem ] || [ ! -f /data/nginx/dummykey.pem ]; then
  echo -e "${CHECKMARK} \e[1;92m Generating dummy SSL Certificate... \e[0m"
  openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/O=Nginx Proxy Manager/OU=Dummy Certificate/CN=localhost" -keyout /data/nginx/dummykey.pem -out /data/nginx/dummycert.pem &>/dev/null
fi

mkdir -p /app/global /app/frontend/images
cp -r backend/* /app
cp -r global/* /app/global

echo -e "${CHECKMARK} \e[1;92m Building Frontend... \e[0m"
cd ./frontend
export NODE_ENV=development
yarn install --network-timeout=30000 &>/dev/null
yarn build &>/dev/null
cp -r dist/* /app/frontend
cp -r app-images/* /app/frontend/images

echo -e "${CHECKMARK} \e[1;92m Initializing Backend... \e[0m"
rm -rf /app/config/default.json &>/dev/null
if [ ! -f /app/config/production.json ]; then
cat << 'EOF' > /app/config/production.json
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
yarn install --network-timeout=30000 &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Creating NPM Service... \e[0m"
cat << 'EOF' > /lib/systemd/system/npm.service
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

echo -e "${CHECKMARK} \e[1;92m Customizing Container... \e[0m"
rm /etc/motd 
rm /etc/update-motd.d/10-uname 
touch ~/.hushlogin 
GETTY_OVERRIDE="/etc/systemd/system/container-getty@1.service.d/override.conf"
mkdir -p $(dirname $GETTY_OVERRIDE)
cat << EOF > $GETTY_OVERRIDE
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM
EOF
systemctl daemon-reload
systemctl restart $(basename $(dirname $GETTY_OVERRIDE) | sed 's/\.d//')

echo -e "${CHECKMARK} \e[1;92m Starting Services... \e[0m"
systemctl enable npm &>/dev/null
systemctl start openresty
systemctl start npm

echo -e "${CHECKMARK} \e[1;92m Cleanup... \e[0m"
rm -rf /npm_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
