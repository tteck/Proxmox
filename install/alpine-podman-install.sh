#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
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
$STD apk add curl
$STD apk add sudo
$STD apk add mc
msg_ok "Installed Dependencies"

get_latest_release() {
  curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
}

msg_info "Installing Podman"
$STD apk add podman

$STD rc-service cgroups start
$STD rc-update add cgroups default

$STD rc-service podman start
$STD rc-update add podman default

echo -e 'unqualified-search-registries=["docker.io"]' >> /etc/containers/registries.conf
msg_ok "Installed Podman"

motd_ssh
customize
