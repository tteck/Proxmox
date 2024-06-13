#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Source: https://github.com/Donkie/Spoolman

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  unzip \
  sudo \
  jq \
  git \
  make \
  libpq-dev \
  gnupg \
  ca-certificates \
  mc
msg_ok "Installed Dependencies"

msg_info "Installing Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-setuptools \
  python3-wheel \
  python3-pip \
  python3-venv
msg_ok "Installed Python3"

msg_info "Installing Spoolman"
cd /opt
RELEASE=$(wget -q https://github.com/Donkie/Spoolman/releases/latest -O - | grep "title>Release" | cut -d " " -f 4)
wget -q https://github.com/Donkie/Spoolman/releases/download/$RELEASE/spoolman.zip
unzip -q spoolman.zip -d spoolman
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt
cd spoolman
$STD python3 -m venv .venv
$STD source .venv/bin/activate
$STD pip3 install -r requirements.txt
cp .env.example .env
chmod +x scripts/*.sh
msg_ok "Installed Spoolman"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/spoolman.service
[Unit]
Description=Spoolman
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/spoolman
EnvironmentFile=/opt/spoolman/.env
ExecStart=/opt/spoolman/scripts/start.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now spoolman.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"