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

RELEASE=$(curl -s https://api.github.com/repos/zadam/trilium/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 3, length($2)-4) }')

msg_info "Installing Trilium"
wget -q https://github.com/zadam/trilium/releases/download/v$RELEASE/trilium-linux-x64-server-$RELEASE.tar.xz
$STD tar -xvf trilium-linux-x64-server-$RELEASE.tar.xz
mv trilium-linux-x64-server /opt/trilium
msg_ok "Installed Trilium"

msg_info "Creating Service"
service_path="/etc/systemd/system/trilium.service"

echo "[Unit]
Description=Trilium Daemon
After=syslog.target network.target

[Service]
User=root
Type=simple
ExecStart=/opt/trilium/trilium.sh
WorkingDirectory=/opt/trilium/
TimeoutStopSec=20
Restart=always

[Install]
WantedBy=multi-user.target" >$service_path
systemctl enable --now -q trilium
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
rm -rf /root/trilium-linux-x64-server-$RELEASE.tar.xz
msg_ok "Cleaned"
