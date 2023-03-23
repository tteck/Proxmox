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
msg_ok "Installed Dependencies"

msg_info "Installing Python3-pip"
$STD apt-get install -y python3-pip
msg_ok "Installed Python3-pip"

msg_info "Installing Whoogle"
$STD pip install brotli
$STD pip install whoogle-search

service_path="/etc/systemd/system/whoogle.service"
echo "[Unit]
Description=Whoogle-Search
After=network.target
[Service]
ExecStart=/usr/local/bin/whoogle-search --host 0.0.0.0
Restart=always
User=root
[Install]
WantedBy=multi-user.target" >$service_path

$STD systemctl enable --now whoogle.service
msg_ok "Installed Whoogle"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
