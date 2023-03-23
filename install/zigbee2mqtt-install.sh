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
$STD apt-get install -y make
$STD apt-get install -y g++
$STD apt-get install -y gcc
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_18.x)
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Setting up Zigbee2MQTT Repository"
$STD git clone https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt
msg_ok "Set up Zigbee2MQTT Repository"

read -r -p "Switch to Edge/dev branch? (y/N) " prompt
if [[ $prompt == "y" ]]; then
  DEV="y"
else
  DEV="n"
fi

msg_info "Installing Zigbee2MQTT"
cd /opt/zigbee2mqtt
if [[ $DEV == "y" ]]; then
$STD git checkout dev
fi
$STD npm ci
msg_ok "Installed Zigbee2MQTT"

msg_info "Creating Service"
service_path="/etc/systemd/system/zigbee2mqtt.service"
echo "[Unit]
Description=zigbee2mqtt
After=network.target
[Service]
Environment=NODE_ENV=production
ExecStart=/usr/bin/npm start
WorkingDirectory=/opt/zigbee2mqtt
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root
[Install]
WantedBy=multi-user.target" >$service_path
$STD systemctl enable zigbee2mqtt.service
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
