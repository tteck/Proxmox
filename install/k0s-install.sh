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
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
msg_ok "Installed Dependencies"

msg_info "Installing k0s Kubernetes"
$STD bash <(curl -sSLf https://get.k0s.sh)
$STD k0s install controller --single
$STD k0s start
mkdir -p /etc/k0s
k0s config create > /etc/k0s/k0s.yaml
msg_ok "Installed k0s Kubernetes"

read -r -p "Would you like to add Helm Package Manager? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
msg_info "Installing Helm"
$STD bash <(curl -sSLf https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3)
msg_ok "Installed Helm"
fi
motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
