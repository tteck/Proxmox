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
$STD apt-get install -y git
$STD apt-get install -y ca-certificates
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"


msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip
rm -rf /usr/lib/python3.*/EXTERNALLY-MANAGED
msg_ok "Updated Python3"

msg_info "Installing Free Games Claimer"
git clone -q https://github.com/vogler/free-games-claimer.git /opt/freegamesclaimer
cd /opt/freegamesclaimer
$STD npm install
msg_ok "Installed Free Games Claimer"

msg_info "Installing apprise"
$STD pip install apprise
msg_ok "Installed apprise"

#msg_info "Creating Service"
#cat <<EOF >/etc/systemd/system/freegamesclaimer.service
#[Unit]
#Description=Free Games Claimer Service
#After=network.target
#
#[Service]
#Type=exec
#WorkingDirectory=/opt/freegamesclaimer
#ExecStart=/usr/bin/node epic-games
#
#[Install]
#WantedBy=multi-user.target
#EOF
#systemctl enable -q --now freegamesclaimer.service
#msg_ok "Created Service"

motd_ssh
customize

msg_info "Setting up Epic Games"
cd /opt/freegamesclaimer
$STD node epic-games
msg_info "Set up Epic games"

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
