#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: MickLesk (Canbiz)
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
  python3 \
  python3-dev \
  python3-setuptools \
  python3-venv \
  build-essential \
  libpq-dev \
  libmagic-dev \
  libzbar0 \
  nginx \
  libsasl2-dev \
  libldap2-dev \
  libssl-dev \
  curl \
  sudo \
  git \
  make \
  mc
msg_ok "Installed Dependencies"

msg_info "Setup Tandoor (Patience)"
sudo useradd tandoor
cd /opt
git clone https://github.com/vabene1111/recipes.git -b master >/dev/null 2>&1
mv recipes tandoor >/dev/null 2>&1
chown -R tandoor:www-data /opt/tandoor >/dev/null 2>&1
python3 -m venv /opt/tandoor >/dev/null 2>&1
source /opt/tandoor/bin/activate >/dev/null 2>&1
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - >/dev/null 2>&1
apt install -y nodejs >/dev/null 2>&1
sudo npm install --global yarn  >/dev/null 2>&1
/opt/tandoor/bin/pip3 install -r /opt/tandoor/requirements.txt >/dev/null 2>&1
cd /opt/tandoor/vue
yarn install --silent  >/dev/null 2>&1
yarn build --silent  >/dev/null 2>&1
cd /opt/tandoor
sudo mkdir -p config api mediafiles staticfiles >/dev/null 2>&1
msg_ok "Initial Setup complete"

msg_info "Setting up Database"
DB_NAME=djangodb
DB_USER=djangouser
DB_ENCODING=utf8
DB_TIMEZONE=UTC
DB_PASS="$(openssl rand -base64 18 | cut -c1-13)"
$STD sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
$STD sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
$STD sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 
$STD sudo -u postgres psql -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER;"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET client_encoding TO $DB_ENCODING;"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET timezone TO $DB_TIMEZONE;"
$STD sudo -u postgres psql -c "ALTER USER $DB_USER WITH SUPERUSER;"
echo "" >>~/tandoor.creds
echo -e "Tandoor Database User: \e[32m$DB_USER\e[0m" >>~/tandoor.creds
echo -e "Tandoor Database Password: \e[32m$DB_PASS\e[0m" >>~/tandoor.creds
echo -e "Tandoor Database Name: \e[32m$DB_NAME\e[0m" >>~/tandoor.creds
msg_ok "Set up PostgreSQL database"

msg_info "Setting up Tandoor Env"
wget https://raw.githubusercontent.com/vabene1111/recipes/develop/.env.template -O /opt/tandoor/.env >/dev/null 2>&1
secret_key=$(openssl rand -base64 45 | sed 's/\//\\\//g') >/dev/null 2>&1
sudo sed -i "s/SECRET_KEY=.*/SECRET_KEY=$secret_key/" /opt/tandoor/.env
sudo sed -i 's/POSTGRES_HOST=.*/POSTGRES_HOST=127.0.0.1/' /opt/tandoor/.env
sudo sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$DB_PASS/" /opt/tandoor/.env
sudo sed -i 's/STATIC_URL=.*/STATIC_URL=\/staticfiles\//' /opt/tandoor/.env
sudo sed -i 's/MEDIA_URL=.*/MEDIA_URL=\/mediafiles\//' /opt/tandoor/.env
msg_ok "Tandoor successfully set up"

msg_info "Initialize Application"
export $(cat /opt/tandoor/.env |grep "^[^#]" | xargs) >/dev/null 2>&1
/opt/tandoor/bin/python3 /opt/tandoor/manage.py migrate >/dev/null 2>&1
$STD sudo -u postgres psql -c "ALTER USER $DB_USER WITH NOSUPERUSER;"
/opt/tandoor/bin/python3 /opt/tandoor/manage.py collectstatic --no-input >/dev/null 2>&1
/opt/tandoor/bin/python3 /opt/tandoor/manage.py collectstatic_js_reverse >/dev/null 2>&1
msg_ok "Application Initialized"

msg_info "Set up web services"
cat <<EOF >/etc/systemd/system/gunicorn_tandoor.service
[Unit]
Description=gunicorn daemon for tandoor
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=3
User=tandoor
Group=www-data
WorkingDirectory=/opt/tandoor
EnvironmentFile=/opt/tandoor/.env
ExecStart=/opt/tandoor/bin/gunicorn --error-logfile /tmp/gunicorn_err.log --log-level debug --capture-output --bind unix:/opt/tandoor/tandoor.sock recipes.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

$STD sudo systemctl enable --now gunicorn_tandoor

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

$STD sudo systemctl reload nginx
msg_ok "Created Services"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
