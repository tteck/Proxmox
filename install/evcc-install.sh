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
  mc \
  debian-keyring \
  debian-archive-keyring \
  lsb-release \
  gpg \
  apt-transport-https
msg_ok "Installed Dependencies"

msg_info "Setting up evcc Repository"
curl -fsSL https://dl.evcc.io/public/evcc/stable/gpg.EAD5D0E07B0EC0FD.key | gpg --dearmor -o /etc/apt/keyrings/evcc-stable.gpg || msg_error "Failed to download GPG key"
echo "deb [signed-by=/etc/apt/keyrings/evcc-stable.gpg] https://dl.evcc.io/public/evcc/stable/deb/debian $(lsb_release -cs) main" >/etc/apt/sources.list.d/evcc-stable.list || msg_error "Failed to add EVCC repository"
$STD sudo apt update
msg_ok "evcc Repository setup sucessfully"

msg_info "Installing ${APPLICATION}"
$STD sudo apt install -y evcc
$STD systemctl enable --now evcc.service
msg_ok "Installed ${APPLICATION}"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"