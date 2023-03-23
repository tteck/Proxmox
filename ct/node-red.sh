#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    _   __          __        ____           __
   / | / /___  ____/ /__     / __ \___  ____/ /
  /  |/ / __ \/ __  / _ \   / /_/ / _ \/ __  / 
 / /|  / /_/ / /_/ /  __/  / _, _/  __/ /_/ /  
/_/ |_/\____/\__,_/\___/  /_/ |_|\___/\__,_/   
 
EOF
}
header_info
echo -e "Loading..."
APP="Node-Red"
var_disk="4"
var_cpu="1"
var_ram="1024"
var_os="debian"
var_version="11"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
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
if [[ ! -d /root/.node-red ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
UPD=$(whiptail --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 2 \
  "1" "Update ${APP}" ON \
  "2" "Install Themes" OFF \
  3>&1 1>&2 2>&3)
header_info
if [ "$UPD" == "1" ]; then
msg_info "Stopping ${APP}"
systemctl stop nodered
msg_ok "Stopped ${APP}"

msg_info "Updating ${APP}"
npm install -g --unsafe-perm node-red &>/dev/null
msg_ok "Updated ${APP}"

msg_info "Starting ${APP}"
systemctl start nodered
msg_ok "Started ${APP}"
msg_ok "Update Successful"
exit
fi
if [ "$UPD" == "2" ]; then
THEME=$(whiptail --title "NODE-RED THEMES" --radiolist --cancel-button Exit-Script "Choose Theme" 15 58 6 \
    "dark" "" OFF \
    "dracula" "" OFF \
    "midnight-red" "" ON \
    "oled" "" OFF \
    "solarized-dark" "" OFF \
    "solarized-light" "" OFF \
    3>&1 1>&2 2>&3)
header_info
msg_info "Installing ${THEME} Theme"    
cd /root/.node-red
sed -i 's|//theme: "",|theme: "",|g' /root/.node-red/settings.js
npm install @node-red-contrib-themes/${THEME} &>/dev/null
sed -i "{s/theme: ".*"/theme: '${THEME}',/g}" /root/.node-red/settings.js
msg_ok "Installed ${THEME} Theme"

msg_info "Restarting ${APP}"
systemctl restart nodered
msg_ok "Restarted ${APP}"
exit
fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:1880${CL} \n"
