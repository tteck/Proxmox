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
msg_ok "Installed Dependencies"

msg_info "Installing pip3 Package Manager"
$STD apk add py3-pip
msg_ok "Installed pip3 Package Manager"

msg_info "Installing Alpine-Whoogle"
$STD pip3 install brotli
$STD pip3 install whoogle-search

echo "#!/sbin/openrc-run
description=\"Whoogle-Search\"
pidfile=\"/run/whoogle.pid\"

start() {
    /usr/bin/whoogle-search --host 0.0.0.0 &
    echo \$! > \$pidfile
}

stop() {
    kill \$(cat \$pidfile)
    rm \$pidfile
}" >/etc/init.d/whoogle

chmod 755 /etc/init.d/whoogle
rc-service -q whoogle start
rc-update add -q whoogle default
msg_ok "Installed Alpine-Whoogle"

motd_ssh
root
