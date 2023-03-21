#!/bin/sh

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

#echo "$FUNCTIONS_FILE_PATH" | . /dev/stdin
#eval "$(cat $FUNCTIONS_FILE_PATH)"
eval "$(cat -- "$FUNCTIONS_FILE_PATH")"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apk add wget
$STD apk add bash
$STD apk add curl
$STD apk add nano
$STD apk add mc
$STD apk add openssh
msg_ok "Installed Dependencies"

msg_info "Installing $APPLICATION"
VER=$(curl --silent -qI https://github.com/AdguardTeam/AdGuardHome/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}');
$STD wget -q "https://github.com/AdguardTeam/AdGuardHome/releases/download/$VER/AdGuardHome_linux_amd64.tar.gz"
$STD tar -xvf AdGuardHome_linux_amd64.tar.gz >/dev/null 2>&1
$STD mv AdGuardHome /opt
$STD rm AdGuardHome_linux_amd64.tar.gz
$STD chmod +x /opt/AdGuardHome/AdGuardHome
$STD /opt/AdGuardHome/AdGuardHome -s install
$STD /opt/AdGuardHome/AdGuardHome -s start
$STD msg_ok "Installed $APPLICATION"

motd_ssh
