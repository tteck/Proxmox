#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Source: https://github.com/ArchiveBox/ArchiveBox

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  build-essential \
  curl \
  sudo \
  python3-{pip,minimal,distutils,ldap,msgpack,mutagen,regex,pycryptodome} \
  libatomic1 \
  zlib1g-dev \
  libssl-dev \
  libldap2-dev \
  libsasl2-dev \
  procps \
  dnsutils \
  yt-dlp \
  ffmpeg \
  ripgrep \
  mc

msg_ok "Installed Dependencies"

msg_info "Installing Playright"
$STD pip install --upgrade playwright
$STD playwright install --with-deps chromium
msg_ok "Installed Playright"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing ArchiveBox"
$STD pip install --upgrade --ignore-installed archivebox[ldap,sonic]
$STD sudo adduser --system --shell /bin/bash --gecos 'Archive Box User' --group --disabled-password --home /opt/archivebox archivebox
mkdir -p /opt/archivebox/data
cd /opt/archivebox/data
sudo chown -R archivebox:archivebox /opt/archivebox/data
sudo chown -R archivebox:archivebox /root
sudo chmod -R 755 /opt/archivebox/data
$STD sudo -u archivebox archivebox init 
msg_ok "Installed ArchiveBox"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/archivebox.service
[Unit]
Description=ArchiveBox Server
After=network.target

[Service]
User=archivebox
WorkingDirectory=/opt/archivebox/data
ExecStart=/usr/local/bin/archivebox server 0.0.0.0:8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now archivebox.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
