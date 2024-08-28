#!/usr/bin/env bash

# Copyright (c) 2024 chmistry
# Author: chmistry
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
$STD apt install -y curl
$STD apt install -y git
$STD apt install -y python3-venv
$STD apt install -y python3-dev
$STD apt install -y build-essential
$STD apt install -y unzip
$STD apt install -y postgresql-common
$STD apt install -y gnupg
$STD apt install -y software-properties-common
$STD apt install -y redis
msg_ok "Installed Dependencies"

msg_info "Adding immich user"
$STD useradd -m immich
#TODO: strip user login etc. (make it more a daemon user)
msg_ok "User immich added"

msg_info "Installing Node.js"
#source ~/.bashrc
su immich -s /usr/bin/bash <<EOF
bash <(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh)
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"
nvm install 20
EOF
msg_ok "Installed Node.js"

msg_info "Installing Postgresql and pgvector"
$STD /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
$STD apt install -y postgresql postgresql-16-pgvector
msg_ok "Installed Postgresql and pgvector"

msg_info "Setting up database"
su postgres <<EOF
psql -c "CREATE DATABASE immich;"
psql -c "CREATE USER immich WITH ENCRYPTED PASSWORD 'YUaaWZAvtL@JpNgpi3z6uL4MmDMR_w';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE immich to immich;"
psql -c "ALTER USER immich WITH SUPERUSER;"
EOF
msg_ok "Database setup completed"

msg_info "Installing ffmpeg yellyfin"
$STD add-apt-repository universe -y
$STD mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg
$STD export VERSION_OS="$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release )"
$STD export VERSION_CODENAME="$( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release )"
$STD export DPKG_ARCHITECTURE="$( dpkg --print-architecture )"
cat <<EOF | tee /etc/apt/sources.list.d/jellyfin.sources
Types: deb
URIs: https://repo.jellyfin.org/${VERSION_OS}
Suites: ${VERSION_CODENAME}
Components: main
Architectures: ${DPKG_ARCHITECTURE}
Signed-By: /etc/apt/keyrings/jellyfin.gpg
EOF
$STD apt update

$STD apt install -y jellyfin-ffmpeg6

ln -s /usr/lib/jellyfin-ffmpeg/ffmpeg  /bin/ffmpeg
ln -s /usr/lib/jellyfin-ffmpeg/ffprobe  /bin/ffprobe
msg_ok "Installed ffmpeg yellyfin"

msg_info "Installing ${APPLICATION}"

su immich -s /usr/bin/bash -c "git clone https://github.com/loeeeee/immich-in-lxc.git /tmp/immich-in-lxc"
cd /tmp/immich-in-lxc
su immich -s /usr/bin/bash -c "./install.sh" # creates env file
# Replace password in runtime.env file
sed -i 's/A_SEHR_SAFE_PASSWORD/YUaaWZAvtL@JpNgpi3z6uL4MmDMR_w/g' runtime.env
su immich -s /usr/bin/bash -c "./install.sh" # runs rest of script
msg_ok "Installed ${APPLICATION}"

msg_info "Creating log directory /var/log/immich"
mkdir -p /var/log/immich
chmod immich:immich /var/log/immich
msg_ok "Log directory created"

msg_info "Creating Services"
cat <<EOF >/etc/systemd/system/immich-microservices.service
[Unit]
Description=immich microservices
Documentation=https://github.com/immich-app/immich
Requires=redis-server.service
Requires=postgresql.service

[Service]
User=immich
Group=immich
Type=simple
Restart=on-failure
UMask=0077

ExecStart=/bin/bash /home/immich/app/start.sh microservices

SyslogIdentifier=immich-microservices
StandardOutput=append:/var/log/immich/microservices.log
StandardError=append:/var/log/immich/microservices.log

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/immich-ml.service
[Unit]
Description=immich machine-learning
Documentation=https://github.com/immich-app/immich

[Service]
User=immich
Group=immich
Type=simple
Restart=on-failure
UMask=0077

WorkingDirectory=/home/immich/app
EnvironmentFile=/home/immich/runtime.env
ExecStart=/home/immich/app/machine-learning/start.sh

SyslogIdentifier=immich-machine-learning
StandardOutput=append:/var/log/immich/ml.log
StandardError=append:/var/log/immich/ml.log

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/immich-web.service
[Unit]
Description=immich web server
Documentation=https://github.com/immich-app/immich
Requires=redis-server.service
Requires=postgresql.service
Requires=immich-ml.service
Requires=immich-microservices.service

[Service]
User=immich
Group=immich
Type=simple
Restart=on-failure
UMask=0077

ExecStart=/bin/bash /home/immich/app/start.sh immich

SyslogIdentifier=immich-web
StandardOutput=append:/var/log/immich/web.log
StandardError=append:/var/log/immich/web.log

[Install]
WantedBy=multi-user.target
EOF

systemctl enable -q --now immich-microservices.service
systemctl enable -q --now immich-ml.service
systemctl enable -q --now immich-web.service

msg_ok "Created Services"

motd_ssh
customize

msg_info "Cleaning up"

$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

