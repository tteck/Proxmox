#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   ______                                ______              __
  / ____/___  ____ ___  ____ ___  ____ _/ ____/__  ___  ____/ /
 / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ /_  / _ \/ _ \/ __  /
/ /___/ /_/ / / / / / / / / / / / /_/ / __/ /  __/  __/ /_/ /
\____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/    \___/\___/\__,_/

EOF
}
header_info
echo -e "Loading..."
APP="CommaFeed"
var_disk="4"
var_cpu="2"
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
if [[ ! -d /opt/commafeed ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Stopping CommaFeed"
systemctl stop commafeed
msg_ok "Stopped CommaFeed"

msg_info "Updating CommaFeed"
cd /opt/commafeed
rm commafeed.jar
wget -q https://github.com/Athou/commafeed/releases/latest/download/commafeed.jar
msg_ok "Updated CommaFeed"

msg_info "Starting CommaFeed"
systemctl start commafeed
msg_ok "Update Completed Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8082${CL} \n"
