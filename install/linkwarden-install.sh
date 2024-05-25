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

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
$STD apt-get install -y gpg
$STD apt-get install -y postgresql
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js/Yarn"
$STD apt-get update
$STD apt-get install -y nodejs
$STD npm install -g yarn
msg_ok "Installed Node.js/Yarn"

msg_info "Clone Linkwarden Repository"
$STD git clone https://github.com/linkwarden/linkwarden.git /opt/linkwarden
cd /opt/linkwarden
msg_ok "Cloned Linkwarden Repository"

msg_info "Setting up PostgreSQL DB"
DB_NAME=linkwardendb
DB_USER=linkwarden
DB_PASS="$(openssl rand -base64 18 | tr -d '/' | cut -c1-13)"
$STD sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';"
$STD sudo -u postgres psql -c "CREATE DATABASE $DB_NAME WITH OWNER $DB_USER TEMPLATE template0;"

echo "" >>~/linkwarden.creds
echo -e "Linkwarden Database User: \e[32m$DB_USER\e[0m" >>~/linkwarden.creds
echo -e "Linkwarden Database Password: \e[32m$DB_PASS\e[0m" >>~/linkwarden.creds
echo -e "Linkwarden Database Name: \e[32m$DB_NAME\e[0m" >>~/linkwarden.creds
msg_ok "Set up PostgreSQL DB"

read -r -p "Would you like to add Adminer? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
  msg_info "Installing Adminer"
  $STD apt install -y adminer
  $STD a2enconf adminer
  systemctl reload apache2
  IP=$(hostname -I | awk '{print $1}')
  echo "" >>~/linkwarden.creds
  echo -e "Adminer Interface: \e[32m$IP/adminer/\e[0m" >>~/linkwarden.creds
  echo -e "Adminer System: \e[32mPostgreSQL\e[0m" >>~/linkwarden.creds
  echo -e "Adminer Server: \e[32mlocalhost:5432\e[0m" >>~/linkwarden.creds
  echo -e "Adminer Username: \e[32m$DB_USER\e[0m" >>~/linkwarden.creds
  echo -e "Adminer Password: \e[32m$DB_PASS\e[0m" >>~/linkwarden.creds
  echo -e "Adminer Database: \e[32m$DB_NAME\e[0m" >>~/linkwarden.creds
  msg_ok "Installed Adminer"
fi

msg_info "Installing Linkwarden (Patience)"
RELEASE=$(curl -s https://api.github.com/repos/linkwarden/linkwarden/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt
$STD yarn
$STD npx playwright install-deps
IP=$(hostname -I | awk '{print $1}')
SECRET_KEY="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"
env_path="/opt/linkwarden/.env"
echo " 
NEXTAUTH_SECRET=${SECRET_KEY}
NEXTAUTH_URL=http://${IP}:3000
DATABASE_URL=postgresql://${DB_USER}:${DB_PASS}@localhost:5432/${DB_NAME}
" >$env_path
$STD yarn build
$STD yarn prisma migrate deploy
msg_ok "Installed Linkwarden"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/linkwarden.service
[Unit]
Description=Linkwarden Service
After=network.target

[Service]
Type=exec
WorkingDirectory=/opt/linkwarden
ExecStart=/usr/bin/yarn start

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now linkwarden.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
