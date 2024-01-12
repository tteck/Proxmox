#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   ____                      __     
  / __ \____ ___  ____ _____/ /___ _
 / / / / __  __ \/ __  / __  / __  /
/ /_/ / / / / / / /_/ / /_/ / /_/ / 
\____/_/ /_/ /_/\__,_/\__,_/\__,_/  
 
EOF
}
header_info
echo -e "Loading..."
APP="Omada"
var_disk="8"
var_cpu="2"
var_ram="2048"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="0"
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
if [[ ! -d /opt/tplink ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
latest_url=$(curl -fsSL "https://www.tp-link.com/us/support/download/omada-software-controller/" | grep -o 'https://.*x64.deb' | head -n1)
latest_version=$(basename "${latest_url}" | sed -e 's/.*ller_//;s/_Li.*//')
if [ -z "${latest_version}" ]; then
  msg_error "It seems that the server (tp-link.com) might be down. Please try again at a later time."
  exit
fi
installed_version=$(dpkg -l | grep omada | awk '{print $3}')

if [ "v${installed_version}" = "${latest_version}" ]; then
  msg_info "Installed version (v${installed_version}) is the same as the latest version (${latest_version})"
  sleep 2
  msg_ok "Omada Controller is already up to date"
  exit
else
  echo -e "Updating Omada Controller to ${latest_version}"
  wget -qL ${latest_url}
  dpkg -i Omada_SDN_Controller_${latest_version}_Linux_x64.deb
  rm -rf Omada_SDN_Controller_${latest_version}_Linux_x64.deb
  echo -e "Updated Omada Controller to ${latest_version}"
exit
fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}https://${IP}:8043${CL} \n"
