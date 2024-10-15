#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Source: https://github.com/evcc-io/evcc

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  sudo \
  mc 
msg_ok "Installed Dependencies"

RELEASE=$(curl -s https://api.github.com/repos/evcc-io/evcc/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
msg_info "Installing ${APPLICATION} ${RELEASE}"
wget -q "https://github.com/evcc-io/evcc/releases/download/${RELEASE}/evcc_${RELEASE}_amd64.deb"
$STD dpkg -i evcc_${RELEASE}_amd64.deb
echo "${RELEASE}" >"/opt/${APPLICATION}_version.txt"
msg_ok "Installed ${APPLICATION} ${RELEASE}"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf evcc_${RELEASE}_amd64.deb
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"