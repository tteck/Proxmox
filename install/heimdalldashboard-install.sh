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

msg_info "Installing PHP"
$STD apt-get install -y php
$STD apt-get install -y php-sqlite3
$STD apt-get install -y php-zip
$STD apt-get install -y php-xml
msg_ok "Installed PHP"

RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/Heimdall/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
msg_info "Installing Heimdall Dashboard ${RELEASE}"
$STD curl --silent -o ${RELEASE}.tar.gz -L "https://github.com/linuxserver/Heimdall/archive/${RELEASE}.tar.gz"
$STD tar xvzf ${RELEASE}.tar.gz
VER=$(curl -s https://api.github.com/repos/linuxserver/Heimdall/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 3, length($2)-4) }')
rm -rf ${RELEASE}.tar.gz
mv Heimdall-${VER} /opt/Heimdall
msg_ok "Installed Heimdall Dashboard ${RELEASE}"

msg_info "Creating Service"
service_path="/etc/systemd/system/heimdall.service"
echo "[Unit]
Description=Heimdall
After=network.target

[Service]
Restart=always
RestartSec=5
Type=simple
User=root
WorkingDirectory=/opt/Heimdall
ExecStart="/usr/bin/php" artisan serve --port 7990 --host 0.0.0.0
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target" >$service_path
$STD sudo systemctl enable --now heimdall.service
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
