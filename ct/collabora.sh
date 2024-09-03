#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   ______      ____      __                    
  / ____/___  / / /___ _/ /_  ____  _________ _
 / /   / __ \/ / / __ `/ __ \/ __ \/ ___/ __ `/
/ /___/ /_/ / / / /_/ / /_/ / /_/ / /  / /_/ / 
\____/\____/_/_/\__,_/_.___/\____/_/   \__,_/  
                                               
EOF
}
header_info
echo -e "Loading..."
APP="Collabora"
var_disk="12"
var_cpu="1"
var_ram="1024"
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
  if [[ ! -f /lib/systemd/system/coolwsd.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  msg_info "Updating ${APP} LXC"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null
  msg_ok "Updated ${APP} LXC"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} needs to be behind a proxy (Nginx Proxy Manager)."
