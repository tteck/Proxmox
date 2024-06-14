#!/usr/bin/env bash

# Copyright (c) 2021-2024 ulmentflam
# Author: ulmentflam
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
$STD apt-get install -y build-essential
msg_ok "Installed Dependencies"

msg_info "Installing Ollama"
$STD curl -fsSL https://ollama.com/install.sh | sh

msg_ok "Installed Ollama"

msg_info "Creating Service"
service_path="/etc/systemd/system/ollama.service"
echo "[Unit]
Description=Ollama Service
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/ollama serve
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target" >$service_path
systemctl enable -q --now ollama.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
