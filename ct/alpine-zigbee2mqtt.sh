#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/next/misc/alpine.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
 _____   _       __             ___   __  _______  ____________
/__  /  (_)___ _/ /_  ___  ___ |__ \ /  |/  / __ \/_  __/_  __/
  / /  / / __  / __ \/ _ \/ _ \__/ // /|_/ / / / / / /   / /   
 / /__/ / /_/ / /_/ /  __/  __/ __// /  / / /_/ / / /   / /    
/____/_/\__, /_.___/\___/\___/____/_/  /_/\___\_\/_/   /_/     
       /____/ Alpine
 
EOF
}
header_info
echo -e "Loading..."
APP="Alpine-Zigbee2MQTT"
var_disk="0.3"
var_cpu="1"
var_ram="256"
var_os="alpine"
var_version="3.17"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW="-password alpine"
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET=dhcp
  GATE=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
UPD=$(whiptail --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 1 \
  "1" "Check for Zigbee2MQTT Update" ON \
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
