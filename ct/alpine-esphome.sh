#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    ___________ ____  __  __                   
   / ____/ ___// __ \/ / / /___  ____ ___  ___ 
  / __/  \__ \/ /_/ / /_/ / __ \/ __ `__ \/ _ \
 / /___ ___/ / ____/ __  / /_/ / / / / / /  __/
/_____//____/_/   /_/ /_/\____/_/ /_/ /_/\___/ 
 Alpine                                               

EOF
}
header_info
echo -e "Loading..."
APP="Alpine-ESPHome"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="alpine"
var_version="3.17"
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
  if [[ ! -f /usr/bin/esphome ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  while true; do
    CHOICE=$(
      whiptail --title "SUPPORT" --menu "Select option" 11 58 1 \
        "1" "Check for ESPHome Updates" 3>&2 2>&1 1>&3
    )
    exit_status=$?
    if [ $exit_status == 1 ]; then
      clear
      exit-script
    fi
    header_info
    case $CHOICE in
    1)
      msg_info "Updating ESPHome"
      pip3 install esphome --upgrade &>/dev/null
      rc-service -q esphome restart
      msg_ok "Updated Successfully!"
      exit
      ;;
    esac
  done
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:6052${CL} \n"
