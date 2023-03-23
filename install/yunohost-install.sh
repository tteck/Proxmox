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
$STD apt-key adv --fetch-keys 'https://packages.sury.org/php/apt.gpg'
$STD apt-get install -y apt-transport-https
$STD apt-get install -y lsb-release
$STD apt-get install -y ca-certificates
msg_ok "Installed Dependencies"

msg_info "Installing YunoHost (Patience)"
wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
$STD bash <(curl -fsSL https://install.yunohost.org) -a
msg_ok "Installed YunoHost"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
