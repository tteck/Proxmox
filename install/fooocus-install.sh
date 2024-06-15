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
msg_ok "Installed Dependencies"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel
msg_ok "Updated Python3"

msg_info "Installing Fooocus"
FOOOCUS_VERSION=$(wget -q https://github.com/lllyasviel/Fooocus/releases/latest -O - | grep "title>Release" | cut -d " " -f 4)
cd /opt || msg_error "Failed to change directory to /opt"
$STD wget https://github.com/lllyasviel/Fooocus/releases/download/"$FOOOCUS_VERSION"/"$FOOOCUS_VERSION".tar.xz
$STD tar -xf "${FOOOCUS_VERSION}".tar.xz -C /opt/
mv "${FOOOCUS_VERSION}" /opt/Fooocus
rm -rf "${FOOOCUS_VERSION}" "${FOOOCUS_VERSION}".tar.xz
cd /opt/Fooocus || msg_error "Failed to change directory to /opt/Fooocus"
$STD pip3 install --upgrade pip
$STD pip3 install -r requirements.txt
echo "${FOOOCUS_VERSION}" >/opt/Fooocus_version.txt
msg_ok "Installed Fooocus"

msg_info "Creating Service"
service_path="/etc/systemd/system/fooocus.service"
echo "[Unit]
Description=Fooocus Image Generation Service
After=network-online.target

[Service]
Type=simple
UMask=007
ExecStart=/usr/bin/python3 /opt/Fooocus/entry_with_update.py --listen
Restart=on-failure
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target" >$service_path
systemctl enable --now -q fooocus.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
