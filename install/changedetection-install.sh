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
$STD apt-get install -y pip
msg_ok "Installed Dependencies"

msg_info "Installing Change Detection"
mkdir /opt/changedetection
$STD pip3 install changedetection.io
$STD python3 -m pip install dnspython==2.2.1
msg_ok "Installed Change Detection"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/changedetection.service
[Unit]
Description=Change Detection
After=network-online.target
[Service]
Type=simple
WorkingDirectory=/opt/changedetection
Environment="WEBDRIVER_URL=http://127.0.0.1:4444/wd/hub"
ExecStart=changedetection.io -d /opt/changedetection -p 5000
[Install]
WantedBy=multi-user.target
EOF
$STD systemctl enable --now changedetection
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
