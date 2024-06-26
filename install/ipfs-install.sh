#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: ulmentflam
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
$STD apt-get install -y gpg
msg_ok "Installed Dependencies"

msg_info "Installing IPFS"
wget -q "$(curl -s "https://api.github.com/repos/ipfs/kubo/releases/latest" | grep "linux-amd64.tar.gz" | grep "browser_download_url" | head -n 1 | cut -d\" -f4)"
tar -xzf kubo*linux-amd64.tar.gz -C /usr/local
$STD ln -s /usr/local/kubo/ipfs /usr/local/bin/ipfs
ipfs init
msg_ok "Installed IPFS"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/ipfs.service
[Unit]
Description=IPFS Daemon
After=syslog.target network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ipfs daemon
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl -q daemon-reload
systemctl enable --now -q ipfs.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf kubo*linux-amd64.tar.gz
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
