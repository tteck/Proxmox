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
msg_ok "Installed Dependencies"

read -r -p "Local Controller? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
  LOCAL="--local-controller"
else
  LOCAL=""
fi

msg_info "Installing UniFi Network Application (Patience)"
wget -qL https://get.glennr.nl/unifi/install/install_latest/unifi-latest.sh
$STD bash unifi-latest.sh --skip --add-repository $LOCAL
msg_ok "Installed UniFi Network Application"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
