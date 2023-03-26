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

msg_info "Installing Alpine-Zigbee2MQTT"
$STD apk add zigbee2mqtt
msg_ok "Installed Alpine-Zigbee2MQTT"

motd_ssh
root