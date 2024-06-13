#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   _____                   __                    
  / ___/____  ____  ____  / /___ ___  ____ _____ 
  \__ \/ __ \/ __ \/ __ \/ / __ `__ \/ __ `/ __ \
 ___/ / /_/ / /_/ / /_/ / / / / / / / /_/ / / / /
/____/ .___/\____/\____/_/_/ /_/ /_/\__,_/_/ /_/ 
    /_/                                                         
EOF
}
header_info
echo -e "Loading..."
APP="Spoolman"
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
if [[ ! -d /opt/spoolman ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
  read -r -p "Warning: Storage is dangerously low, continue anyway? <y/N> " prompt
  [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
fi
msg_info "Stopping ${APP} Service"
systemctl stop spoolman
msg_ok "Stopped ${APP} Service"

msg_info "Updating ${APP} to latest Git"
RELEASE=$(wget -q https://github.com/Donkie/Spoolman/releases/latest -O - | grep "title>Release" | cut -d " " -f 4)
cd /opt
if [ -d spoolman_bak ]; then
  rm -rf spoolman_bak
fi
mv spoolman spoolman_bak
wget -q https://github.com/Donkie/Spoolman/releases/download/${RELEASE}/spoolman.zip 
unzip -q spoolman.zip -d spoolman 
echo "${RELEASE}" >/opt/${APP}_version.txt
cd spoolman
python3 -m venv .venv >/dev/null 2>&1
source .venv/bin/activate >/dev/null 2>&1
pip3 install -r requirements.txt >/dev/null 2>&1
cp .env.example .env
chmod +x scripts/*.sh
msg_ok "Updated ${APP} to latest Git"

msg_info "Starting ${APP} Service"
systemctl start spoolman
sleep 1
msg_ok "Started ${APP} Service"

msg_info "Cleaning up"
if [ -d "/opt/spoolman_bak" ]; then
rm -rf /opt/spoolman_bak
rm -rf /opt/spoolman.zip
fi
msg_ok "Cleaning up Successfully!"

msg_ok "Updated Successfully!\n"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:7912${CL} \n"
