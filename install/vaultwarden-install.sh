#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

#Select DB engine (Sqlite or PostgreSQL, will maybe add MySQL later)
DB_ENGINE=""
while [ -z "$DB_ENGINE" ]; do
if DB_ENGINE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "VAULTWARDEN DATABASE" --radiolist "Choose Database" 10 58 2 \
  "sqlite" "" OFF \
  "postgresql" "" OFF \
  3>&1 1>&2 2>&3); then
  if [ -n "$DB_ENGINE" ]; then
	echo -e "${DGN}Using Database Engine: ${BGN}$DB_ENGINE${CL}"
  fi
else
  exit-script
fi
done

#Fail2ban option
if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "Fail2ban" --yesno "Configure fail2ban?" 10 58); then
  ENABLE_F2B=1
else
  ENABLE_F2B=0
fi

msg_info "Installing Dependencies"
$STD apt-get update
$STD apt-get -qqy install \
  git \
  build-essential \
  pkgconf \
  libssl-dev \
  libmariadb-dev-compat \
  libpq-dev \
  curl \
  sudo \
  argon2 \
  mc
msg_ok "Installed Dependencies"

WEBVAULT=$(curl -s https://api.github.com/repos/dani-garcia/bw_web_builds/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 2, length($2)-3) }')

VAULT=$(curl -s https://api.github.com/repos/dani-garcia/vaultwarden/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 2, length($2)-3) }')

msg_info "Installing Rust"
wget -qL https://sh.rustup.rs
$STD bash index.html -y --profile minimal
echo 'export PATH=~/.cargo/bin:$PATH' >>~/.bashrc
export PATH=~/.cargo/bin:$PATH
rm index.html
msg_ok "Installed Rust"

msg_info "Building Vaultwarden ${VAULT} (Patience)"
$STD git clone https://github.com/dani-garcia/vaultwarden
cd vaultwarden
#$STD cargo build --features "sqlite,mysql,postgresql" --release
$STD cargo build --features "$DB_ENGINE" --release
msg_ok "Built Vaultwarden ${VAULT}"

$STD addgroup --system vaultwarden
$STD adduser --system --home /opt/vaultwarden --shell /usr/sbin/nologin --no-create-home --gecos 'vaultwarden' --ingroup vaultwarden --disabled-login --disabled-password vaultwarden
mkdir -p /opt/vaultwarden/bin
mkdir -p /opt/vaultwarden/data
cp target/release/vaultwarden /opt/vaultwarden/bin/

msg_info "Downloading Web-Vault ${WEBVAULT}"
curl -fsSLO https://github.com/dani-garcia/bw_web_builds/releases/download/$WEBVAULT/bw_web_$WEBVAULT.tar.gz
tar -xzf bw_web_$WEBVAULT.tar.gz -C /opt/vaultwarden/
msg_ok "Downloaded Web-Vault ${WEBVAULT}"

#admintoken=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 70 | head -n 1)
admintoken=$(generate_token)

#Local server IP
vw_ip4=$(hostname -I | awk '{print $1}')
#vw_ip4=$(ip a s dev eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
#$STD vw_ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
#echo "Local IP:$ip4"

cat <<EOF >/opt/vaultwarden/.env
ADMIN_TOKEN=${admintoken}
ROCKET_ADDRESS=${vw_ip4}
DATA_FOLDER=/opt/vaultwarden/data
DATABASE_MAX_CONNS=10
WEB_VAULT_FOLDER=/opt/vaultwarden/web-vault
WEB_VAULT_ENABLED=true
EOF


if [ "$DB_ENGINE" == "postgresql" ]; then
  msg_info "Installing PostgreSQL"
  #sudo apt install postgresql postgresql-contrib libpq-dev dirmngr git libssl-dev pkg-config build-essential curl wget apt-transport-https ca-certificates software-properties-common pwgen -y
  $STD apt -qqy install postgresql postgresql-contrib
  msg_ok "Installed PostgreSQL"
  

  ### Configure PostgreSQL DB
  # Random password
  #postgresql_pwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
  postgresql_pwd=$(generate_token)
  sudo -u postgres psql -c "CREATE DATABASE vaultwarden;"
  sudo -u postgres psql -c "CREATE USER vaultwarden WITH ENCRYPTED PASSWORD '${postgresql_pwd}';"
  sudo -u postgres psql -c "GRANT all privileges ON database vaultwarden TO vaultwarden;"
  #echo "Successfully setup PostgreSQL DB vaultwarden with user vaultwarden and password ${postgresql_pwd}"

  echo "DATABASE_URL=postgresql://vaultwarden:${postgresql_pwd}@localhost:5432/vaultwarden" >> /opt/vaultwarden/.env
fi



msg_info "Creating Service"
chown -R vaultwarden:vaultwarden /opt/vaultwarden/
chown root:root /opt/vaultwarden/bin/vaultwarden
chmod +x /opt/vaultwarden/bin/vaultwarden
chown -R root:root /opt/vaultwarden/web-vault/
chmod +r /opt/vaultwarden/.env

service_path="/etc/systemd/system/vaultwarden.service"
echo "[Unit]
Description=Bitwarden Server (Powered by Vaultwarden)
Documentation=https://github.com/dani-garcia/vaultwarden
After=network.target
[Service]
User=vaultwarden
Group=vaultwarden
EnvironmentFile=-/opt/vaultwarden/.env
ExecStart=/opt/vaultwarden/bin/vaultwarden
LimitNOFILE=65535
LimitNPROC=4096
PrivateTmp=true
PrivateDevices=true
ProtectHome=true
ProtectSystem=strict
DevicePolicy=closed
ProtectControlGroups=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
RestrictNamespaces=yes
RestrictRealtime=yes
MemoryDenyWriteExecute=yes
LockPersonality=yes
WorkingDirectory=/opt/vaultwarden
ReadWriteDirectories=/opt/vaultwarden/data
AmbientCapabilities=CAP_NET_BIND_SERVICE
[Install]
WantedBy=multi-user.target" >$service_path
systemctl daemon-reload
$STD systemctl enable --now vaultwarden.service
msg_ok "Created Service"


if [ "$ENABLE_F2B" == 1 ]; then
  msg_info "Configuring fail2ban"

  #####Fail2ban setup
  $STD apt -qqy install fail2ban

  #Create files
  touch /etc/fail2ban/filter.d/vaultwarden.conf
  touch /etc/fail2ban/jail.d/vaultwarden.local
  touch /etc/fail2ban/filter.d/vaultwarden-admin.conf
  touch /etc/fail2ban/jail.d/vaultwarden-admin.local

  #Set vaultwarden fail2ban filter conf File
  vaultwardenfail2banfilter="/etc/fail2ban/filter.d/vaultwarden.conf"
  echo "[INCLUDES]
before = common.conf

[Definition]
failregex = ^.*Username or password is incorrect\. Try again\. IP: <HOST>\. Username:.*$
ignoreregex =" > $vaultwardenfail2banfilter

  #Set vaultwarden fail2ban jail conf File
  vaultwardenfail2banjail="/etc/fail2ban/jail.d/vaultwarden.local"
  echo "[vaultwarden]
enabled = true
port = 80,443,8081
filter = vaultwarden
action = iptables-allports[name=vaultwarden]
logpath = /var/log/vaultwarden/error.log
maxretry = 3
bantime = 14400
findtime = 14400" > $vaultwardenfail2banjail

  #Set vaultwarden fail2ban admin filter conf File
  vaultwardenfail2banadminfilter="/etc/fail2ban/filter.d/vaultwarden-admin.conf"
  echo "[INCLUDES]
before = common.conf

[Definition]
failregex = ^.*Unauthorized Error: Invalid admin token\. IP: <HOST>.*$
ignoreregex =" > $vaultwardenfail2banadminfilter

  #Set vaultwarden fail2ban admin jail conf File
  vaultwardenfail2banadminjail="/etc/fail2ban/jail.d/vaultwarden-admin.local"
  echo "[vaultwarden-admin]
enabled = true
port = 80,443
filter = vaultwarden-admin
action = iptables-allports[name=vaultwarden]
logpath = /var/log/vaultwarden/error.log
maxretry = 5
bantime = 14400
findtime = 14400" > $vaultwardenfail2banadminjail

  systemctl daemon-reload
  $STD systemctl restart fail2ban
  msg_info "Configured fail2ban"
fi

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"

msg_info "Enter ${admintoken} to gain access to admin panel, please save this somewhere! Admin panel accessible at $vw_ip4:8000/admin"
