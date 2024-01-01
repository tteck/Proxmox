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
msg_ok "Installed Dependencies"

msg_info "Installing Mosquitto MQTT Broker"
if [ "$PCT_OSTYPE" == "debian" ]; then
  VERSION="$(awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release)"
  wget -qO- http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key >/etc/apt/trusted.gpg.d/mosquitto-repo.asc
  wget -qO /etc/apt/sources.list.d/mosquitto-${VERSION}.list http://repo.mosquitto.org/debian/mosquitto-${VERSION}.list
  $STD apt-get update
fi
$STD apt-get -y install mosquitto
$STD apt-get -y install mosquitto-clients
cat <<EOF >/etc/mosquitto/conf.d/default.conf
allow_anonymous false
persistence true
password_file /etc/mosquitto/passwd
listener 1883
EOF
msg_ok "Installed Mosquitto MQTT Broker"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
