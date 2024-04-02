#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: MountyMapleSyrup (MountyMapleSyrup)
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
$STD apt-get install -y git
$STD apt-get install -y python3
msg_ok "Installed Dependencies"

msg_info "Installing LazyLibrarian"
mkdir -p /opt/LazyLibrarian/
chmod 775 /opt/LazyLibrarian/
$STD git clone https://gitlab.com/LazyLibrarian/LazyLibrarian /opt/LazyLibrarian
msg_ok "Installed LazyLibrarian"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/lazylibrarian.service
[Unit]
Description=LazyLibrarian Daemon
After=syslog.target network.target
[Service]
UMask=0002
Type=simple
ExecStart=/usr/bin/python3 /opt/LazyLibrarian/LazyLibrarian.py
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl -q daemon-reload
systemctl enable --now -q lazylibrarian
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
