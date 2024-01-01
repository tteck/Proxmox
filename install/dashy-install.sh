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
$STD apt-get install -y git
msg_ok "Installed Dependencies"

msg_info "Installing Node.js (Patience)"
$STD apt-get install -y npm
$STD npm cache clean -f
$STD npm install -g n
$STD n 16.20.1
$STD npm install -g pnpm
ln -sf /usr/local/bin/node /usr/bin/node
msg_ok "Installed Node.js"

msg_info "Installing Yarn"
$STD npm install --global yarn
ln -sf /usr/local/bin/yarn /usr/bin/yarn
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
systemctl -q --now enable dashy
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
