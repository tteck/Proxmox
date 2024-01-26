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
$STD apt-get install -y apt-transport-https
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

msg_info "Installing MongoDB"
wget -qO- https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor >/usr/share/keyrings/mongodb-server-7.0.gpg
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" >/etc/apt/sources.list.d/mongodb-org-7.0.list
$STD apt-get update
$STD apt install -y mongodb-org
sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mongod.conf
systemctl enable -q --now mongod.service
msg_ok "Installed MongoDB"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
