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

msg_info "Installing Python3-pip"
$STD apt-get install -y python3-pip
msg_ok "Installed Python3-pip"

msg_info "Installing ESPHome"
$STD pip3 install esphome
msg_ok "Installed ESPHome"

msg_info "Installing ESPHome Dashboard"
$STD pip3 install tornado esptool

service_path="/etc/systemd/system/esphomeDashboard.service"
echo "[Unit]
Description=ESPHome Dashboard
After=network.target
[Service]
ExecStart=/usr/local/bin/esphome /root/config/ dashboard
Restart=always
User=root
[Install]
WantedBy=multi-user.target" >$service_path
$STD systemctl enable esphomeDashboard.service
systemctl start esphomeDashboard
msg_ok "Installed ESPHome Dashboard"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
