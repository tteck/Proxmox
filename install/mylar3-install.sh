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
$STD apt-get install -y par2
$STD apt-get install -y p7zip-full
cat <<EOF >/etc/apt/sources.list.d/non-free.list
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
EOF
$STD apt-get update
$STD apt-get install -y unrar
rm /etc/apt/sources.list.d/non-free.list
msg_ok "Installed Dependencies"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip
$STD apt-get install -y python3-setuptools
msg_ok "Updated Python3"

msg_info "Installing Mylar3"
RELEASE=$(curl -s https://api.github.com/repos/mylar3/mylar3/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
$STD tar zxvf <(curl -fsSL https://github.com/mylar3/mylar3/archive/refs/tags/${RELEASE}.tar.gz)
mv mylar3-${RELEASE:1} /opt/mylar3
cd /opt/mylar3
$STD python3 -m pip install -r requirements.txt
msg_ok "Installed Mylar3"

msg_info "Creating Service"
service_path="/etc/systemd/system/mylar3.service"
echo "[Unit]
Description=Mylar3
After=network.target
[Service]
WorkingDirectory=/opt/mylar3
ExecStart=python3 Mylar.py -p 8585
Restart=always
User=root
[Install]
WantedBy=multi-user.target" >$service_path
systemctl enable --now -q mylar3.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
