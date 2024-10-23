#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: jcantosz
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
$STD apt-get install -y \
    curl \
    lsb-release \
    gpg \
    g++ \
    git \
    make \
    openssl \
    python3 \
    postgresql-15 \
    redis
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y --no-install-suggests nodejs
msg_info "Installed Node.js"

msg_info "Installing Postgresql"
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=ghostfolio-db
POSTGRES_USER='postgres'
POSTGRES_PASSWORD="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"
ACCESS_TOKEN_SALT="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"
DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?connect_timeout=300&sslmode=prefer"
JWT_SECRET_KEY="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"

$STD su postgres <<EOSU
psql -c "create database \"$POSTGRES_DB\";"
psql -c "ALTER DATABASE \"$POSTGRES_DB\" OWNER TO \"$POSTGRES_USER\";"
psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$POSTGRES_USER\";"
psql -c "ALTER USER \"$POSTGRES_USER\" WITH PASSWORD '$POSTGRES_PASSWORD';"
EOSU

echo "" >~/ghostfolio.creds
echo "Ghostfolio Database Credentials" >>~/ghostfolio.creds
echo "" >>~/ghostfolio.creds
echo -e "Ghostfolio Database User: \e[32m$POSTGRES_USER\e[0m" >>~/ghostfolio.creds
echo -e "Ghostfolio Database Password: \e[32m$POSTGRES_PASSWORD\e[0m" >>~/ghostfolio.creds
echo -e "Ghostfolio Database Name: \e[32m$POSTGRES_DB\e[0m" >>~/ghostfolio.creds
msg_ok "Installed Postgresql"

msg_info "Installing Redis"
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"

$STD redis-cli CONFIG SET requirepass "$REDIS_PASSWORD"
$STD redis-cli  -a "$REDIS_PASSWORD" CONFIG REWRITE
$STD systemctl restart redis
echo "" >>~/ghostfolio.creds
echo "Ghostfolio Redis Credentials" >>~/ghostfolio.creds
echo "" >>~/ghostfolio.creds
echo -e "Ghostfolio Redis Password: \e[32m$REDIS_PASSWORD\e[0m" >>~/ghostfolio.creds
msg_ok "Installed Redis"

msg_info "Installing Ghostfolio (Patience)"
RELEASE=$(curl -sL https://api.github.com/repos/ghostfolio/ghostfolio/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt

cd /opt/
$STD curl -Ls -o ghostfolio-$RELEASE.tgz https://github.com/ghostfolio/ghostfolio/archive/refs/tags/$RELEASE.tar.gz
$STD tar xzf ghostfolio-$RELEASE.tgz
$STD rm ghostfolio-$RELEASE.tgz

cp /opt/ghostfolio-$RELEASE/package.json /opt/package.json
cp /opt/ghostfolio-$RELEASE/package-lock.json /opt/package-lock.json

cd /opt/ghostfolio-$RELEASE
$STD npm install
$STD npm run build:production
mv /opt/package-lock.json /opt/ghostfolio-$RELEASE/package-lock.json

cd /opt/ghostfolio-$RELEASE/dist/apps/api/
$STD npm install
cp -r /opt/ghostfolio-$RELEASE/prisma .
mv /opt/package.json /opt/ghostfolio-$RELEASE/dist/apps/api/package.json
$STD npm run database:generate-typings

cd /opt
mv /opt/ghostfolio-$RELEASE/dist/apps /opt/ghostfolio
mv /opt/ghostfolio-$RELEASE/docker/entrypoint.sh /opt/ghostfolio/

rm -rf /opt/ghostfolio-$RELEASE
msg_ok "Installed Ghostfolio"

msg_info "Creating Service"
cat <<EOF >/opt/ghostfolio/api/.env
# CACHE
REDIS_HOST=$REDIS_HOST
REDIS_PORT=$REDIS_PORT
REDIS_PASSWORD=$REDIS_PASSWORD

# POSTGRES
POSTGRES_DB=$POSTGRES_DB
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# VARIOUS
ACCESS_TOKEN_SALT=$ACCESS_TOKEN_SALT
DATABASE_URL="$DATABASE_URL"
JWT_SECRET_KEY=$JWT_SECRET_KEY
EOF

cat <<EOF >/opt/ghostfolio/start.sh
#!/bin/bash
# Source the environment vars and export them otherwise it wont get them properly
set -a
. /opt/ghostfolio/api/.env
set +a

# Run the docker entrypoint
/opt/ghostfolio/entrypoint.sh
EOF

chmod +x /opt/ghostfolio/start.sh

msg_info "Setup Service"
cat <<EOF >/etc/systemd/system/ghostfolio.service
[Unit]
Description=ghostfolio

[Service]
After=postgresql.service redis.service
Require=postgresql.service redis.service

# Start Service
ExecStart=/opt/ghostfolio/start.sh
WorkingDirectory=/opt/ghostfolio/api/

# Restart service after 10 seconds if node service crashes
RestartSec=10
Restart=always

# Output to syslog
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=ghostfolio

[Install]
WantedBy=multi-user.target
EOF

systemctl enable ghostfolio
systemctl start ghostfolio
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"