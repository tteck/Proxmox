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
$STD apt-get install -y nginx
msg_ok "Installed Dependencies"

msg_info "Installing Aria2"
DEBIAN_FRONTEND=noninteractive $STD apt-get -o Dpkg::Options::="--force-confold" install -y aria2
msg_ok "Installed Aria2"

read -r -p "Would you like to add AriaNG? <y/N> " prompt
if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
  msg_info "Installing AriaNG"
  cd /root
  mkdir -p /var/www
  wget -q "$(curl -s https://api.github.com/repos/mayswind/ariang/releases/latest | grep download | grep AllInOne.zip | cut -d\" -f4)" -O /root/ariang.zip
  unzip "$(ls -l /root | grep zip$ | awk '{print $9}')" -d /var/www
  service_path="/etc/systemd/system/ariang.service"
cat <<EOF >/etc/nginx/conf.d/ariang.conf
server {
    listen 6880 default_server;
    listen [::]:6880 default_server;

    server_name _;

    root /var/www;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
  rm /etc/nginx/sites-enabled/*
  systemctl restart nginx
  msg_ok "Installed AriaNG"
fi

msg_info "Creating Service"

mkdir /root/downloads
cat <<EOF >/root/aria2.daemon
continue
dir=/root/downloads
file-allocation=falloc
max-connection-per-server=4
max-concurrent-downloads=2
max-overall-download-limit=0
min-split-size=25M
rpc-allow-origin-all=true
rpc-secret=YouShouldChangeThis
input-file=/var/tmp/aria2c.session
save-session=/var/tmp/aria2c.session
EOF

cat <<EOF >/etc/systemd/system/aria2.service
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
WantedBy=multi-user.target'
EOF
systemctl enable --now -q aria2.service

msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm /root/"$(ls -l /root | grep zip$ | awk '{print $9}')"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
