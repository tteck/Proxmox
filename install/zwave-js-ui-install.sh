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
msg_ok "Installed Dependencies"

msg_info "Installing Z-Wave JS UI"
mkdir /opt/zwave-js-ui
cd /opt/zwave-js-ui
RELEASE=$(curl -s https://api.github.com/repos/zwave-js/zwave-js-ui/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
$STD wget https://github.com/zwave-js/zwave-js-ui/releases/download/${RELEASE}/zwave-js-ui-${RELEASE}-linux.zip
$STD unzip zwave-js-ui-${RELEASE}-linux.zip
msg_ok "Installed Z-Wave JS UI"

msg_info "Creating Service"
service_path="/etc/systemd/system/zwave-js-ui.service"
echo "[Unit]
Description=zwave-js-ui
Wants=network-online.target
After=network-online.target
[Service]
User=root
WorkingDirectory=/opt/zwave-js-ui
ExecStart=/opt/zwave-js-ui/zwave-js-ui-linux
[Install]
WantedBy=multi-user.target" >$service_path
systemctl start zwave-js-ui
$STD systemctl enable zwave-js-ui
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm zwave-js-ui-${RELEASE}-linux.zip
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
