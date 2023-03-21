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
msg_ok "Installed Dependencies"

msg_info "Installing Mosquitto MQTT Broker"
$STD wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
$STD apt-key add mosquitto-repo.gpg.key
cd /etc/apt/sources.list.d/
$STD wget http://repo.mosquitto.org/debian/mosquitto-bullseye.list
$STD apt-get update
$STD apt-get -y install mosquitto
$STD apt-get -y install mosquitto-clients
msg_ok "Installed Mosquitto MQTT Broker"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
