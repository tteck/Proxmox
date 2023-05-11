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
$STD apt-get install -y unzip
$STD apt-get install -y python3-pip
$STD apt-get install -y python3-distutils
msg_ok "Installed Dependencies"

msg_info "Installing Bazarr"
mkdir -p /var/lib/bazarr/
chmod 775 /var/lib/bazarr/
$STD wget --content-disposition 'https://github.com/morpheus65535/bazarr/releases/latest/download/bazarr.zip'
$STD unzip bazarr -d Bazarr 
mv Bazarr /opt
chmod 775 /opt/Bazarr
$STD python3 -m pip install -r requirements.txt
msg_ok "Installed Bazarr"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/bazarr.service
[Unit]
Description=Bazarr Daemon
After=syslog.target network.target

# After=syslog.target network.target sonarr.service radarr.service

[Service]
WorkingDirectory=/opt/bazarr/
User=your_user(username of your choice)
Group=your_group(group of your choice)
UMask=0002
Restart=on-failure
RestartSec=5
Type=simple
ExecStart=/usr/bin/python3 /opt/bazarr/bazarr.py
KillSignal=SIGINT
TimeoutStopSec=20
SyslogIdentifier=bazarr
ExecStartPre=/bin/sleep 30

[Install]
WantedBy=multi-user.target
EOF
systemctl -q daemon-reload
systemctl enable --now -q bazarr
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
rm -rf Bazarr.master.*.tar.gz
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
