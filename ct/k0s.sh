#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    __   ____          __ __      __                         __           
   / /__/ __ \_____   / //_/_  __/ /_  ___  _________  ___  / /____  _____
  / //_/ / / / ___/  / ,< / / / / __ \/ _ \/ ___/ __ \/ _ \/ __/ _ \/ ___/
 / ,< / /_/ (__  )  / /| / /_/ / /_/ /  __/ /  / / / /  __/ /_/  __(__  ) 
/_/|_|\____/____/  /_/ |_\__,_/_.___/\___/_/  /_/ /_/\___/\__/\___/____/  
                                                                          
EOF
}
header_info
echo -e "Loading..."
APP="k0s"
var_disk="4"
var_cpu="2"
var_ram="2048"
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
if [[ ! -f /etc/k0s/k0s.yaml ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP} LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
