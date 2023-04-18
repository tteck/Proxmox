#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    __  __                                          
   / / / /___  ____ ___  ___  ____  ____ _____ ____ 
  / /_/ / __ \/ __ `__ \/ _ \/ __ \/ __ `/ __ `/ _ \
 / __  / /_/ / / / / / /  __/ /_/ / /_/ / /_/ /  __/
/_/ /_/\____/_/ /_/ /_/\___/ .___/\__,_/\__, /\___/ 
                          /_/          /____/       
EOF
}
header_info
echo -e "Loading..."
APP="Homepage"
var_disk="3"
var_cpu="2"
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
header_info
if [[ ! -d /opt/homepage ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP}"
if ! command -v pnpm >/dev/null 2>&1; then
    npm install -g pnpm &>/dev/null
fi
cd /opt/homepage
systemctl stop homepage
git pull --force &>/dev/null
pnpm install &>/dev/null
pnpm build &>/dev/null
systemctl start homepage
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:3000${CL} \n"
