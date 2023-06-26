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

msg_info "Installing Node.js"
$STD bash <(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh)
. ~/.bashrc
$STD nvm install 16.20.1
ln -sf /root/.nvm/versions/node/v16.20.1/bin/node /usr/bin/node
msg_ok "Installed Node.js"

msg_info "Installing n8n (Patience)"
$STD npm install --global n8n
msg_ok "Installed n8n"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/n8n.service
[Unit]
Description=n8n

[Service]
Type=simple
ExecStart=n8n start
[Install]
WantedBy=multi-user.target
EOF
$STD systemctl enable --now n8n
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
