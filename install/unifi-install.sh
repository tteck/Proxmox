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
$STD apt-get install -y apt-transport-https
msg_ok "Installed Dependencies"

msg_info "Installing OpenJDK"
$STD apt-get install -y openjdk-11-jre-headless
$STD apt-mark hold openjdk-11-*
msg_ok "Installed OpenJDK"

msg_info "Installing MongoDB"
wget -qL https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/3.6/multiverse/binary-amd64/mongodb-org-server_3.6.23_amd64.deb
$STD dpkg -i mongodb-org-server_3.6.23_amd64.deb
msg_ok "Installed MongoDB"

msg_info "Installing UniFi Network Application"
wget -qO /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg
echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' >/etc/apt/sources.list.d/100-ubnt-unifi.list
$STD apt-get update
$STD apt-get install -y unifi
msg_ok "Installed UniFi Network Application"

motd_ssh
root

msg_info "Cleaning up"
rm -rf mongodb-org-server_3.6.23_amd64.deb
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
