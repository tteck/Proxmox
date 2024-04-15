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
$STD apt-get install -y caddy
msg_ok "Installed Dependencies"

msg_info "Installing Aria2"
DEBIAN_FRONTEND=noninteractive $STD apt-get -o Dpkg::Options::="--force-confold" install -y aria2
msg_ok "Installed Aria2"

read -r -p "Would you like to add AriaNG? <y/N> " prompt
if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
  msg_info "Installing AriaNG"
  mkdir -p /var/www
  wget -q "$(curl -s https://api.github.com/repos/mayswind/ariang/releases/latest | grep download | grep AllInOne.zip | cut -d\" -f4)" -O /root/ariang.zip
  ZIP="$(ls -l /root | grep zip$ | awk '{print $9}')"
  unzip /root/$ZIP -d /var/www
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
  systemctl enable --now -q aria2.service
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

conf_path="/root/aria2.daemon"
echo 'continue
dir=/var/www/downloads
file-allocation=falloc
max-connection-per-server=4
max-concurrent-downloads=2
max-overall-download-limit=0
min-split-size=25M
rpc-allow-origin-all=true
rpc-secret=YouShouldChangeThis
input-file=/var/tmp/aria2c.session
save-session=/var/tmp/aria2c.session' >$conf_path
systemctl enable --now -q aria2.service

msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm /root/$ZIP
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
