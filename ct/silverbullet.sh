#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: Gabriel Lima (ewilazarus)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   _____ ______ _    ____________  ____  __  ____    __    ____________
  / ___//  _/ /| |  / / ____/ __ \/ __ )/ / / / /   / /   / ____/_  __/
  \__ \ / // / | | / / __/ / /_/ / __  / / / / /   / /   / __/   / /
 ___/ // // /__| |/ / /___/ _, _/ /_/ / /_/ / /___/ /___/ /___  / /
/____/___/_____/___/_____/_/ |_/_____/\____/_____/_____/_____/ /_/
 
EOF
}
header_info
echo -e "Loading..."
APP="Silverbullet"
var_disk="2"
var_cpu="1"
var_ram="512"
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
if [[ ! -d /opt/silverbullet ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP}"
systemctl stop silverbullet
silverbullet upgrade
systemctl start silverbullet
msg_ok "Updated ${APP}"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:3000/${CL} \n"
