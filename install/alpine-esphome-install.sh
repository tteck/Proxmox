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
cat <<EOF >/etc/init.d/esphome
#!/sbin/openrc-run

name="esphome"
description="ESPHome Service"
RC_SVCNAME="esphome"
command="/usr/bin/esphome /root/config/ dashboard"
pidfile="/run/$RC_SVCNAME/pid"

depend() {
    need net
}

start_pre() {
    checkpath --directory --mode 0755 /run/$RC_SVCNAME
}

start() {
    ebegin "Starting $description"
    start-stop-daemon --start --quiet --exec $command
    eend $?
}

stop() {
    ebegin "Stopping $description"
    start-stop-daemon --stop --quiet --exec $command
    eend $?
}
EOF

chmod 755 /etc/init.d/esphome
/etc/init.d/esphome start
rc-update add esphome default
msg_ok "Installed Alpine-ESPHome"

motd_ssh
root
