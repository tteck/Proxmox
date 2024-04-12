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

msg_info "Installing iVentoy"
mkdir -p /opt/iventoy/

wget -q $(curl -s https://api.github.com/repos/ventoy/pxe/releases/latest | grep download | grep linux-free | cut -d\" -f4)      
tar -C /opt/iventoy -xzf iventoy*.tar.gz
rm -rf iventoy*.tar.gz

msg_ok "Installed iVentoy"

msg_info "Creating Service"
service_path="/etc/systemd/system/iventoy.service"
echo "# /etc/systemd/system/iventoy.service
[Unit]
Description=iVentoy PXE Booter
Documentation=https://www.iventoy.com
Wants=network-online.target

[Service]
Type=forking
Environment=IVENTOY_API_ALL=1
Environment=IVENTOY_AUTO_RUN=1
Environment=LIBRARY_PATH=/opt/iventoy/lib/lin64
Environment=LD_LIBRARY_PATH=/opt/iventoy/lib/lin64
ExecStart=sh ./iventoy.sh -R start
WorkingDirectory=/opt/iventoy
Restart=on-failure

[Install]
WantedBy=multi-user.target" >$service_path
systemctl enable --now -q iventoy.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
