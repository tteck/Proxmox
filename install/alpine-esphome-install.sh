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
$STD apk add newt
$STD apk add curl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
$STD apk add git
msg_ok "Installed Dependencies"

msg_info "Installing Alpine-ESPHome"
$STD apk add py3-pip
$STD pip3 install esphome
$STD pip3 install tornado esptool

service_path="/etc/init.d/esphome"
echo "#!/sbin/openrc-run
name=\"esphome\"
description=\"ESPHome Dashboard\"
command=\"/usr/bin/esphome /root/config/ dashboard\"
command_user=\"root\"
command_background=true
pidfile=\"/run/\$name.pid\"

depend() {
    need net
}

start_pre() {
    checkpath --directory --mode 0755 /run/\$name
}

start() {
    ebegin \"Starting \$description\"
    start-stop-daemon --start --quiet --background --exec /usr/bin/esphome -- /root/config/ dashboard
    eend \$?
}

stop() {
    ebegin \"Stopping \$description\"
    pkill esphome
    eend \$?
}" > $service_path

chmod 755 $service_path
$STD rc-update add esphome default
$STD /etc/init.d/esphome start
msg_ok "Installed Alpine-ESPHome"

motd_ssh
root
