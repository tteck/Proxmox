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
$STD apt-get install -y ansible git apache2
msg_ok "Installed Dependencies"

RELEASE=$(curl -sX GET "https://api.github.com/repos/netbootxyz/netboot.xyz/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
msg_info "Installing netboot.xyz ${RELEASE}"
$STD curl --silent -o ${RELEASE}.tar.gz -L "https://github.com/netbootxyz/netboot.xyz/archive/${RELEASE}.tar.gz"
$STD tar xvzf ${RELEASE}.tar.gz
VER=$(curl -s https://api.github.com/repos/netbootxyz/netboot.xyz/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 2, length($2)-3) }')
rm -rf ${RELEASE}.tar.gz
mv netboot.xyz-${VER} /opt/netboot.xyz
msg_ok "Installed netboot.xyz ${RELEASE}"

msg_info "Creating Service"
service_path="/etc/systemd/system/netbootxyz.service"
echo "[Unit]
Description=netboot.xyz
After=network.target

[Service]
Restart=always
RestartSec=5
Type=simple
User=root
WorkingDirectory=/opt/netboot.xyz
ExecStart="ansible-playbook" -i inventory site.yml
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target" >$service_path
$STD sudo systemctl enable --now netbootxyz.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
