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
$STD apt-get install -y wget
$STD apt-get install -y unzip
msg_ok "Installed Dependencies"

msg_info "Installing Aria2"
DEBIAN_FRONTEND=noninteractive $STD apt-get -o Dpkg::Options::="--force-confold" install -y aria2
systemctl enable -q --now apt-cacher-ng
msg_ok "Installed Aria2"

read -r -p "Would you like to add ar? <y/N> " prompt
if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
  msg_info "Installing AriaNG"
  mkdir -p /var/www
  wget -q $(curl -s https://api.github.com/repos/maywind/ariang/releases/latest | grep download | grep AllInOne.zip | cut -d\" -f4)
  ZIP="$(ls -l /root | grep zip$ | awk '{print $9}')"
  unzip $FILENAME -d /var/www
  service_path="/etc/systemd/system/ariang.service"
echo '[Unit]
Description=AriaNG
ConditionFileIsExecutable=/usr/local/bin/caddy
After=network.target

[Service]
ExecStart=/usr/local/bin/caddy "-root /var/www "browse"
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target' >$service_path
  msg_ok "Installed AriaNG"
fi
msg_info "Creating Service"
  service_path="/etc/systemd/system/aria2.service"
echo '[Unit]
Description=Aria2c download manager
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStartPre=/usr/bin/env touch /var/tmp/aria2c.session
ExecStart=/usr/bin/aria2c --console-log-level=warn --enable-rpc --rpc-listen-all --conf-path=/root/aria2.daemon
TimeoutStopSec=20
Restart=on-failure

[Install]
WantedBy=multi-user.target' >$service_path
systemctl enable --now -q aria2.service

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
