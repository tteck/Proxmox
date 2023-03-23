#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
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
$STD apt-get install -y git
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_16.x)
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get install -y nodejs git make g++ gcc
msg_ok "Installed Node.js"

msg_info "Installing Yarn"
$STD npm install --global yarn
msg_ok "Installed Yarn"

msg_info "Installing Dashy (Patience)"
$STD git clone https://github.com/Lissy93/dashy.git
cd /dashy
$STD yarn
export NODE_OPTIONS=--max-old-space-size=1000
$STD yarn build
msg_ok "Installed Dashy"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/dashy.service
[Unit]
Description=dashy

[Service]
Type=simple
WorkingDirectory=/dashy
ExecStart=/usr/bin/yarn start
[Install]
WantedBy=multi-user.target
EOF
$STD systemctl enable dashy
systemctl start dashy
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
