#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/next/misc/alpine.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ___    __      _          
   /   |  / /___  (_)___  ___ 
  / /| | / / __ \/ / __ \/ _ \
 / ___ |/ / /_/ / / / / /  __/
/_/  |_/_/ .___/_/_/ /_/\___/ 
        /_/                   

EOF
}
header_info
echo -e "Loading..."
APP="Alpine"
var_disk="0.1"
var_cpu="1"
var_ram="512"
var_os="alpine"
var_version="3.17"
variables
color
catch_errors

function update_script() {
UPD=$(whiptail --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 1 \
  "1" "Check for Alpine Updates" ON \
  3>&1 1>&2 2>&3)

header_info
if [ "$UPD" == "1" ]; then
apk update && apk upgrade
exit;
fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
