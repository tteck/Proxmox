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
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_18.x)
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD sudo apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing Uptime Kuma"
$STD git clone https://github.com/louislam/uptime-kuma.git
mv uptime-kuma /opt/uptime-kuma
cd /opt/uptime-kuma
$STD npm run setup
msg_ok "Installed Uptime Kuma"

msg_info "Creating Service"
service_path="/etc/systemd/system/uptime-kuma.service"
echo "[Unit]
Description=uptime-kuma

[Service]
Type=simple
Restart=always
User=root
WorkingDirectory=/opt/uptime-kuma
ExecStart=/usr/bin/npm start

[Install]
WantedBy=multi-user.target" >$service_path
$STD systemctl enable --now uptime-kuma.service
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
