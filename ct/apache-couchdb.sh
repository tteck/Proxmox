#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/JamborJan/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster), JamborJan
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"

╔═══╗             ╔╗          ╔═══╗            ╔╗  ╔═══╗╔══╗ 
║╔═╗║             ║║          ║╔═╗║            ║║  ╚╗╔╗║║╔╗║ 
║║ ║║╔══╗╔══╗ ╔══╗║╚═╗╔══╗    ║║ ╚╝╔══╗╔╗╔╗╔══╗║╚═╗ ║║║║║╚╝╚╗
║╚═╝║║╔╗║╚ ╗║ ║╔═╝║╔╗║║╔╗║    ║║ ╔╗║╔╗║║║║║║╔═╝║╔╗║ ║║║║║╔═╗║
║╔═╗║║╚╝║║╚╝╚╗║╚═╗║║║║║║═╣    ║╚═╝║║╚╝║║╚╝║║╚═╗║║║║╔╝╚╝║║╚═╝║
╚╝ ╚╝║╔═╝╚═══╝╚══╝╚╝╚╝╚══╝    ╚═══╝╚══╝╚══╝╚══╝╚╝╚╝╚═══╝╚═══╝
     ║║                                                      
     ╚╝                                                      
                               
EOF
}
header_info
echo -e "Loading..."
APP="Apache-CouchDB"
var_disk="10"
var_cpu="2"
var_ram="4096"
var_os="debian"
var_version="12"
VERBOSE="yes"
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
if [[ ! -f /etc/systemd/system/couchdb.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_error "There is currently no update path available."
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
