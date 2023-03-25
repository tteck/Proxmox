#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apk add newt
$STD apk add curl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
$STD apk add git
msg_ok "Installed Dependencies"

msg_info "Installing pip3 Package Manager"
$STD apk add py3-pip
msg_ok "Installed pip3 Package Manager"

msg_info "Installing Alpine-ESPHome"
$STD pip3 install esphome
$STD pip3 install tornado esptool

echo "#!/sbin/openrc-run
description=\"ESPHome\"
pidfile=\"/run/esphome.pid\"
start() {
    esphome dashboard /root/esphome/config/ > /dev/null 2>&1 &
    echo \$! > \$pidfile
}
stop() {
    kill \$(cat \$pidfile)
    rm \$pidfile
}" >/etc/init.d/esphome

chmod 755 /etc/init.d/esphome
rc-service -q esphome start
rc-update add -q esphome default
msg_ok "Installed Alpine-ESPHome"

motd_ssh
root
