#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
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

msg_info "Installing lldap"
DISTRO="Debian"
os=$(less /etc/os-release | grep "^ID=")
os="${os:3}"
if [ "$os" == "ubuntu" ]; then
  DISTRO="Ubuntu"
fi
DISTRO_VER=$(less /etc/os-release | grep "^VERSION_ID=")
DISTRO_VER="${DISTRO_VER:12}"
DISTRO_VER="${DISTRO_VER%%\"}"
echo "deb http://download.opensuse.org/repositories/home:/Masgalor:/LLDAP/${DISTRO}_${DISTRO_VER}/ /" > /etc/apt/sources.list.d/home:Masgalor:LLDAP.list
curl -fsSL https://download.opensuse.org/repositories/home:Masgalor:LLDAP/${DISTRO}_${DISTRO_VER}/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/home_Masgalor_LLDAP.gpg
$STD apt update
$STD apt install -y lldap
systemctl enable -q --now lldap
msg_ok "Installed lldap"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
