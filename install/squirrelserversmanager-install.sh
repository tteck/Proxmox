#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
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

# Generate a random string
generate_random_string() {
    local LENGTH=$1
  tr -dc A-Za-z0-9 </dev/urandom | head -c ${LENGTH} 2>/dev/null || true
}

msg_info "Installing Dependencies"
$STD apk add git
$STD apk add nodejs
$STD apk add npm
$STD apk add ansible
$STD apk add nmap
$STD apk add sudo
$STD apk add openssh
$STD apk add sshpass
$STD apk add py3-pip
$STD apk add expect
$STD apk add libcurl
$STD apk add gcompat
$STD apk add curl
$STD apk add newt
$STD git --version
$STD node --version
$STD npm --version
msg_ok "Installed Dependencies"

msg_info "Installing Redis"
$STD apk add redis
msg_ok "Installed Redis"

msg_info "Installing Nginx"
$STD apk add nginx
rm -rf /etc/nginx/http.d/default.conf
cat <<'EOF'> /etc/nginx/http.d/default.conf
server {
  listen 80;
  server_name localhost;
  access_log off;
  error_log off;

 location /api/socket.io/ {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;

      proxy_pass http://127.0.0.1:3000/socket.io/;

      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
  }

  location /api/ {
    proxy_pass http://127.0.0.1:3000/;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  location / {
    proxy_pass http://127.0.0.1:8000/;

    # WebSocket support
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    error_page 501 502 503 404 /custom.html;
    location = /custom.html {
            root /usr/share/nginx/html;
    }
  }
}

EOF
msg_ok "Installed Nginx"

msg_info "Installing MongoDB Database"
DB_NAME=ssm
DB_PORT=27017
echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' >> /etc/apk/repositories
echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories
$STD apk update
$STD apk add mongodb mongodb-tools
msg_ok "Installed MongoDB Database"

msg_info "Starting Services"
$STD rc-service redis start
$STD rc-update add redis default
$STD rc-service mongodb start
$STD rc-update add mongodb default
msg_ok "Started Services"

msg_info "Setting Up Squirrel Servers Manager"
$STD git clone https://github.com/SquirrelCorporation/SquirrelServersManager.git /opt/squirrelserversmanager
SECRET=$(generate_random_string 32)
SALT=$(generate_random_string 16)
VAULT_PWD=$(generate_random_string 32)
cat <<EOF > /opt/squirrelserversmanager/.env
# SECRETS
SECRET=$SECRET
SALT=$SALT
VAULT_PWD=$VAULT_PWD
# MONGO
DB_HOST=127.0.0.1
DB_NAME=ssm
DB_PORT=27017
# REDIS
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
EOF
export NODE_ENV=production
export $(grep -v '^#' /opt/squirrelserversmanager/.env | xargs)
$STD npm install -g npm@latest
$STD npm install -g @umijs/max
$STD npm install -g typescript
$STD npm install pm2 -g
msg_ok "Squirrel Servers Manager Has Been Setup"

msg_info "Building Squirrel Servers Manager Lib"
cd /opt/squirrelserversmanager/shared-lib
$STD npm ci
$STD npm run build
msg_ok "Squirrel Servers Manager Lib built"

msg_info "Building & Running Squirrel Servers Manager Client"
cd /opt/squirrelserversmanager/client
$STD npm ci
$STD npm run build
$STD pm2 start --name="squirrelserversmanager-frontend" npm -- run serve
msg_ok "Squirrel Servers Manager Client Built & Ran"

msg_info "Building & Running Squirrel Servers Manager Server"
cd /opt/squirrelserversmanager/server
$STD npm ci
$STD npm run build
$STD pm2 start --name="squirrelserversmanager-backend" node -- ./dist/src/index.js
msg_ok "Squirrel Servers Manager Server Built & Ran"

msg_info "Starting Squirrel Servers Manager"
$STD pm2 startup
$STD pm2 save
mkdir -p /usr/share/nginx/html/
cp /opt/squirrelserversmanager/proxy/www/index.html /usr/share/nginx/html/custom.html

$STD rc-service nginx start
$STD rc-update add nginx default
msg_ok "Squirrel Servers Manager Started"

motd_ssh
customize
