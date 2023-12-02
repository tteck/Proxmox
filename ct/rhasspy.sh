#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
# Print Rhasspy
cat <<"EOF"
    ____  __                               
   / __ \/ /_  ____ _______________  __  __
  / /_/ / __ \/ __ `/ ___/ ___/ __ \/ / / /
 / _, _/ / / / /_/ (__  |__  ) /_/ / /_/ / 
/_/ |_/_/ /_/\__,_/____/____/ .___/\__, /  
                           /_/    /____/ 
EOF
}
header_info
echo -e "Loading..."
APP="Rhasspy"
var_disk="16"
var_cpu="2"
var_ram="2048"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="0"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
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
    header_info
    if [[ ! -d /usr/lib/rhasspy/ ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
    msg_info "Updating $APP LXC"


}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
            ${BL}http://${IP}:12101${CL}\n"
    