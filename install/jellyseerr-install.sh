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
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing Yarn"
$STD npm install -g yarn
msg_ok "Installed Yarn"

msg_info "Installing Jellyseerr (Patience)"
git clone -q https://github.com/Fallenbagel/jellyseerr.git /opt/jellyseerr
cd /opt/jellyseerr
$STD yarn install
$STD yarn build
msg_ok "Installed Jellyseerr"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/jellyseerr.service
[Unit]
Description=jellyseerr Service
After=network.target

[Service]
Type=exec
WorkingDirectory=/opt/jellyseerr
ExecStart=/usr/bin/yarn start

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now jellyseerr.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
