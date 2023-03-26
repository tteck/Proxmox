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
default_packages

#msg_info "Installing Dependencies"
#msg_ok "Installed Dependencies"

msg_info "Installing Grafana"
$STD apk add grafana
$STD sed -i '/http_addr/s/127.0.0.1/0.0.0.0/g' /etc/conf.d/grafana
$STD rc-service grafana start
$STD rc-update add grafana default
msg_ok "Installed Grafana"

motd_ssh
root