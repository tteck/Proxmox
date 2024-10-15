#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"     
  ___ _   ____________
 / _ \ | / / ___/ ___/
/  __/ |/ / /__/ /__  
\___/|___/\___/\___/  

EOF
}
header_info
echo -e "Loading..."
APP="evcc"
var_disk="4"
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
if [[ ! -d /usr/bin/evcc ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
  read -r -p "Warning: Storage is dangerously low, continue anyway? <y/N> " prompt
  [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
fi
RELEASE=$(curl -s https://api.github.com/repos/evcc-io/evcc/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-4) }')
if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
  msg_info "Stopping ${APP}"
  systemctl stop evcc
  msg_ok "${APP} Stopped"
  
  msg_info "Updating ${APP} to ${RELEASE}"
  wget -q "https://github.com/evcc-io/evcc/releases/download/${RELEASE}/evcc_${RELEASE}_amd64.deb"
  $STD dpkg -i evcc_${RELEASE}_amd64.deb
  msg_ok "Updated Successfully"
  
  msg_info "Starting ${APP}"
  systemctl start evcc
  msg_ok "Started ${APP}"
  
  msg_info "Cleaning Up"
  rm -rf evcc_${RELEASE}_amd64.deb
  msg_ok "Cleaned"
  msg_ok "Updated Successfully"
else
  msg_ok "No update required. ${APP} is already at ${RELEASE}"
fi
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:7070${CL} \n"
