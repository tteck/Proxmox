#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: jcantosz
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"     
   ________               __  ____      ___     
  / ____/ /_  ____  _____/ /_/ __/___  / (_)___ 
 / / __/ __ \/ __ \/ ___/ __/ /_/ __ \/ / / __ \
/ /_/ / / / / /_/ (__  ) /_/ __/ /_/ / / / /_/ /
\____/_/ /_/\____/____/\__/_/  \____/_/_/\____/ 
                                                
EOF
}
header_info
echo -e "Loading..."
APP="Ghostfolio"
var_disk="6"
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
  INSTALL_ALL="yes"
  echo_default
}

function update_script() {
header_info
if [[ ! -d /etc/neo4j ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating OS"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:3333${CL} \n"
