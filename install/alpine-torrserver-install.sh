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
msg_ok "Installed Dependencies"

msg_info "Creating User"
$STD adduser -D -h /opt/torrserver torrserver
msg_ok "Created User"

msg_info "Donwloading TorrServer"
$STD curl -sL https://github.com/YouROK/TorrServer/releases/download/MatriX.125/TorrServer-linux-amd64 -o /opt/torrserver/TorrServer-linux-amd64
$STD chmod a+x /opt/torrserver/TorrServer-linux-amd64
msg_ok "Donwloaded TorrServer"

msg_info "Creating Service"
cat <<EOF >/etc/init.d/torrserver
#!/sbin/openrc-run

name="TorrServer"
command="/opt/torrserver/TorrServer-linux-amd64"
command_args="--port 8090 --logpath /var/log/torrserver.log --path /opt/torrserver"
command_user="torrserver:torrserver"
pidfile="/run/\$SVCNAME.pid"
command_background=true

depend() {
        need net
}
EOF
$STD chmod a+x /etc/init.d/torrserver
$STD rc-update add torrserver
msg_ok "Created Service"

msg_info "Starting Service"
$STD rc-service torrserver start
msg_ok "Started Service"

motd_ssh
customize