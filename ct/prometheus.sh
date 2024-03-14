#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ____                            __  __                   
   / __ \_________  ____ ___  ___  / /_/ /_  ___  __  _______
  / /_/ / ___/ __ \/ __  __ \/ _ \/ __/ __ \/ _ \/ / / / ___/
 / ____/ /  / /_/ / / / / / /  __/ /_/ / / /  __/ /_/ (__  ) 
/_/   /_/   \____/_/ /_/ /_/\___/\__/_/ /_/\___/\__,_/____/  
 
EOF
}
header_info
echo -e "Loading..."
APP="Prometheus"
var_disk="4"
var_cpu="1"
var_ram="2048"
var_os="debian"
var_version="12"
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
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
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
if [[ ! -f /etc/systemd/system/prometheus.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_error "There is currently no update path available."
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:9090${CL} \n"
