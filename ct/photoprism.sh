#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    ____  __  ______  __________  ____  ____  _________ __  ___
   / __ \/ / / / __ \/_  __/ __ \/ __ \/ __ \/  _/ ___//  |/  /
  / /_/ / /_/ / / / / / / / / / / /_/ / /_/ // / \__ \/ /|_/ / 
 / ____/ __  / /_/ / / / / /_/ / ____/ _, _// / ___/ / /  / /  
/_/   /_/ /_/\____/ /_/  \____/_/   /_/ |_/___//____/_/  /_/   

EOF
}
header_info
echo -e "Loading..."
APP="PhotoPrism"
var_disk="8"
var_cpu="4"
var_ram="4096"
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
  if [[ ! -d /opt/photoprism ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  echo -e "\n ⚠️  Ensure you set 2vCPU & 3072MiB RAM MIMIMUM!!! \n"
  msg_info "Stopping PhotoPrism"
  sudo systemctl stop photoprism
  msg_ok "Stopped PhotoPrism"

  msg_info "Cloning PhotoPrism"
  git clone https://github.com/photoprism/photoprism.git &>/dev/null
  cd photoprism
  git checkout release &>/dev/null
  msg_ok "Cloned PhotoPrism"

  msg_info "Building PhotoPrism"
  sudo make all &>/dev/null
  sudo ./scripts/build.sh prod /opt/photoprism/bin/photoprism &>/dev/null
  sudo rm -rf /opt/photoprism/assets
  sudo cp -r assets/ /opt/photoprism/ &>/dev/null
  msg_ok "Built PhotoPrism"

  msg_info "Cleaning"
  cd ~
  rm -rf photoprism
  msg_ok "Cleaned"

  msg_info "Starting PhotoPrism"
  sudo systemctl start photoprism
  msg_ok "Started PhotoPrism"
  msg_ok "Update Successful"
  exit
}

start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -memory 2048
msg_ok "Set Container to Normal Resources"
msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:2342${CL} \n"
