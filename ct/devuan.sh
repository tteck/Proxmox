#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/next/misc/debian.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"

    ____                            
   / __ \___ _   ____  ______  ____ 
  / / / / _ \ | / / / / / __ `/ __ \
 / /_/ /  __/ |/ / /_/ / /_/ / / / /
/_____/\___/|___/\__,_/\__,_/_/ /_/ 
                                    
EOF
}
header_info
echo -e "Loading..."
APP="Devuan"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="devuan"
var_version="4.0"
varibles
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
msg_info "Updating $APP LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
