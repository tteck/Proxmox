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
$STD apt-get install -y gnupg
$STD apt-get install -y apt-transport-https
msg_ok "Installed Dependencies"

msg_info "Installing Azul Zulu"
$STD apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
wget -q https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb
$STD apt-get install ./zulu-repo_1.0.0-3_all.deb
$STD apt-get update
$STD apt-get -y install zulu11-jdk
msg_ok "Installed Azul Zulu"

msg_info "Installing openHAB"
curl -fsSL "https://openhab.jfrog.io/artifactory/api/gpg/key/public" | gpg --dearmor >openhab.gpg
mv openhab.gpg /usr/share/keyrings
chmod u=rw,g=r,o=r /usr/share/keyrings/openhab.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/openhab.gpg] https://openhab.jfrog.io/artifactory/openhab-linuxpkg stable main" > /etc/apt/sources.list.d/openhab.list'
$STD apt update
$STD apt-get -y install openhab
systemctl daemon-reload
$STD systemctl enable --now openhab.service
msg_ok "Installed openHAB"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
