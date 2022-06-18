#!/usr/bin/env bash
YW=`echo "\033[33m"`
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
RETRY_NUM=10
RETRY_EVERY=3
NUM=$RETRY_NUM
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR="\\r\\033[K"
HOLD="-"
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR

function error_exit() {
  trap - ERR
  local reason="Unknown failure occured."
  local msg="${1:-$reason}"
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  exit $EXIT
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_info "Setting up Container OS "
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
while [ "$(hostname -I)" = "" ]; do
  1>&2 echo -en "${CROSS}${RD} No Network! "
  sleep $RETRY_EVERY
  ((NUM--))
  if [ $NUM -eq 0 ]
  then
    1>&2 echo -e "${CROSS}${RD}  No Network After $RETRY_NUM Tries${CL}"    
    exit 1
  fi
done
msg_ok "Setup Container OS"
msg_ok "Network Connected: ${BL}$(hostname -I)"

msg_info "Updating Container OS"
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null
msg_ok "Updated Container OS"

msg_info "Installing Dependencies"
apt-get -qqy install \
    git \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    curl \
    libpq-dev \
    postgresql \
    libsasl2-dev \
    python3-dev \
    libldap2-dev \
    libssl-dev \
    sudo &>/dev/null
msg_ok "Installed Dependencies"

msg_info "Cloning & Preparation of Recipes"
git clone https://github.com/vabene1111/recipes.git -b master
mv recipes /var/www
cd /var/www/recipes
sudo useradd recipes
chown -R recipes:www-data /var/www/recipes
python3 -m venv /var/www/recipes
msg_ok "Cloning & Preparation done"

msg_ok "Installing NodeJS"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
msg_ok "Installed NodeJS"

msg_ok "Installing Project Requirements"
/var/www/recipes/bin/pip3 install -r requirements.txt
cd ./vue
yarn install
yarn build
msg_ok "Installed Project Requirements"

msg_ok "Setup Database started"
sudo -u postgres psql
PWDJANGO=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 23 ; echo '')
CREATE DATABASE djangodb;
CREATE USER djangouser WITH PASSWORD '$PWDJANGO';
GRANT ALL PRIVILEGES ON DATABASE djangodb TO djangouser;
ALTER DATABASE djangodb OWNER TO djangouser;
ALTER ROLE djangouser SET client_encoding TO 'utf8';
ALTER ROLE djangouser SET default_transaction_isolation TO 'read committed';
ALTER ROLE djangouser SET timezone TO 'UTC';
ALTER USER djangouser WITH SUPERUSER;
exit
msg_ok "Setup Database finished"

msg_ok "Setup .env started"
wget https://raw.githubusercontent.com/vabene1111/recipes/develop/.env.template -O /var/www/recipes/.env
SECRETKEY=$(base64 /dev/urandom | head -c50)
msg_ok "Setup .env finished"

msg_info "Creating Service"
service_path="/etc/systemd/system/gunicorn_recipes.service" &>/dev/null

echo "[Unit]
Description=gunicorn daemon for recipes
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=3
User=recipes
Group=www-data
WorkingDirectory=/var/www/recipes
EnvironmentFile=/var/www/recipes/.env
ExecStart=/var/www/recipes/bin/gunicorn --error-logfile /tmp/gunicorn_err.log --log-level debug --capture-output --bind unix:/var/www/recipes/recipes.sock recipes.wsgi:application

[Install]
WantedBy=multi-user.target" > $service_path
systemctl daemon-reload
systemctl enable --now gunicorn_recipes.service &>/dev/null
msg_ok "Created Service"

msg_ok "Creating NGINX Config"
nginxconfig_path="/etc/nginx/conf.d/recipes.conf" &>/dev/null

echo "server {
    listen 8002;
    #access_log /var/log/nginx/access.log;
    #error_log /var/log/nginx/error.log;

    # serve media files
    location /static {
        alias /var/www/recipes/staticfiles;
    }
    
    location /media {
        alias /var/www/recipes/mediafiles;
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_pass http://unix:/var/www/recipes/recipes.sock;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}" > $nginxconfig_path
systemctl reload nginx
msg_ok "Created NGINX Config"

PASS=$(grep -w "root" /etc/shadow | cut -b6);
  if [[ $PASS != $ ]]; then
msg_info "Customizing Container"
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
msg_ok "Customized Container"
  fi
  
msg_info "Cleaning up"
apt-get autoremove -y >/dev/null
apt-get autoclean >/dev/null
rm -rf /var/{cache,log}/* /var/lib/apt/lists/*
msg_ok "Cleaned"
