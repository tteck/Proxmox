#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y --no-install-recommends \
  postgresql \
  build-essential \
  libpq-dev \
  libmagic-dev \
  libzbar0 \
  nginx \
  libsasl2-dev \
  libldap2-dev \
  libssl-dev \
  gpg \
  curl \
  sudo \
  git \
  make \
  mc
msg_ok "Installed Dependencies"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-setuptools \
  python3-pip
msg_ok "Updated Python3"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
$STD npm install -g yarn
msg_ok "Installed Node.js"

msg_info "Installing Tandoor (Patience)"
$STD git clone https://github.com/vabene1111/recipes.git -b master /opt/tandoor
mkdir -p /opt/tandoor/{config,api,mediafiles,staticfiles}
$STD pip3 install -r /opt/tandoor/requirements.txt
cd /opt/tandoor/vue
$STD yarn install
$STD yarn build
wget -q https://raw.githubusercontent.com/vabene1111/recipes/develop/.env.template -O /opt/tandoor/.env
DB_NAME=tandordb
DB_USER=tandoor
DB_ENCODING=utf8
DB_TIMEZONE=UTC
secret_key=$(openssl rand -base64 45 | sed 's/\//\\\//g')
DB_PASS="$(openssl rand -base64 18 | cut -c1-13)"
sed -i -e "s|SECRET_KEY=.*|SECRET_KEY=$secret_key|g" \
       -e "s|POSTGRES_HOST=.*|POSTGRES_HOST=127.0.0.1|g" \
       -e "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$DB_PASS|g" \
       -e "s|POSTGRES_DB=.*|POSTGRES_DB=$DB_NAME|g" \
       -e "s|POSTGRES_USER=.*|POSTGRES_USER=$DB_USER|g" \
       -e "\$a\STATIC_URL=/staticfiles\\nMEDIA_URL=/mediafiles" /opt/tandoor/.env
msg_ok "Installed Tandoor"

msg_info "Setting up PostgreSQL database"
$STD sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
$STD sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
$STD sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 
$STD sudo -u postgres psql -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET client_encoding TO $DB_ENCODING;"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET timezone TO $DB_TIMEZONE;"
$STD sudo -u postgres psql -c "ALTER USER $DB_USER WITH SUPERUSER;"
echo "" >>~/tandoor.creds
echo -e "Tandoor Database Name: \e[32m$DB_NAME\e[0m" >>~/tandoor.creds
echo -e "Tandoor Database User: \e[32m$DB_USER\e[0m" >>~/tandoor.creds
echo -e "Tandoor Database Password: \e[32m$DB_PASS\e[0m" >>~/tandoor.creds
export $(cat /opt/tandoor/.env |grep "^[^#]" | xargs)
/usr/bin/python3 /opt/tandoor/manage.py migrate >/dev/null 2>&1
/usr/bin/python3 /opt/tandoor/manage.py collectstatic --no-input >/dev/null 2>&1
/usr/bin/python3 /opt/tandoor/manage.py collectstatic_js_reverse >/dev/null 2>&1
msg_ok "Set up PostgreSQL database"

msg_info "Creating Services"
cat <<EOF >/etc/systemd/system/gunicorn_tandoor.service
[Unit]
Description=gunicorn daemon for tandoor
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=3
WorkingDirectory=/opt/tandoor
EnvironmentFile=/opt/tandoor/.env
ExecStart=/usr/local/bin/gunicorn --error-logfile /tmp/gunicorn_err.log --log-level debug --capture-output --bind unix:/opt/tandoor/tandoor.sock recipes.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' >/etc/nginx/conf.d/tandoor.conf
server {
    listen 8002;
    #access_log /var/log/nginx/access.log;
    #error_log /var/log/nginx/error.log;

    # serve media files
    location /static/ {
        alias /opt/tandoor/staticfiles/;
    }

    location /media/ {
        alias /opt/tandoor/mediafiles/;
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_pass http://unix:/opt/tandoor/tandoor.sock;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
systemctl reload nginx
systemctl enable -q --now gunicorn_tandoor
msg_ok "Created Services"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
