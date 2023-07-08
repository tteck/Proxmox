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
$STD apt-get install -y ca-certificates
msg_ok "Installed Dependencies"

msg_info "Installing Sonarr"
wget -qO /etc/apt/trusted.gpg.d/sonarr-repo.asc "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2009837cbffd68f45bc180471f4f90de2a9b4bf8"
echo "deb https://apt.sonarr.tv/debian testing-main main" >/etc/apt/sources.list.d/sonarr.list
$STD apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" install -qqy sonarr &>/dev/null
msg_ok "Installed Sonarr"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
