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
$STD apt-get install -y gnupg
$STD apt-get install -y mc
msg_ok "Installed Dependencies"

msg_info "Installing audiobookshelf"
$STD apt-key add <(curl -s --compressed "https://advplyr.github.io/audiobookshelf-ppa/KEY.gpg")
sh -c 'echo "deb https://advplyr.github.io/audiobookshelf-ppa ./" > /etc/apt/sources.list.d/audiobookshelf.list'
$STD apt-get update
$STD apt install audiobookshelf
msg_ok "Installed audiobookshelf"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
