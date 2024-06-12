#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    __  ___      __  __            __         _     __         
   /  |/  /___ _/ /_/ /____  _____/ /_  _____(_)___/ /___ ____ 
  / /|_/ / __ `/ __/ __/ _ \/ ___/ __ \/ ___/ / __  / __ `/ _ \
 / /  / / /_/ / /_/ /_/  __/ /  / /_/ / /  / / /_/ / /_/ /  __/
/_/  /_/\__,_/\__/\__/\___/_/  /_.___/_/  /_/\__,_/\__, /\___/ 
                                                  /____/                                      
EOF
}
header_info
echo -e "Loading..."
APP="matterbridge"
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
  if [[ ! -d /opt/matterbridge ]]; then 
	msg_error "No ${APP} Installation Found!"; 
	exit; 
fi

LATEST_VERSION=$(grep -oP '## \[\d+\.\d+\.\d+\]' /opt/matterbridge/CHANGELOG.md | head -1 | sed 's/## \[\(.*\)\]/\1/')
RELEASE=$(curl -s https://api.github.com/repos/Luligu/matterbridge/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')

header_info
if [[ "${RELEASE}" != "${LATEST_VERSION}" ]]; then
    msg_info "Stopping Matterbridge Service"
    systemctl stop matterbridge
    msg_ok "Stopped Matterbridge Service"

    msg_info "Updating ${APP} LXC"
    cd /opt/matterbridge
    wget -q "https://github.com/Luligu/matterbridge/archive/refs/tags/${RELEASE}.zip"  >/dev/null 2>&1
    unzip -q ${RELEASE}.zip
    mv matterbridge-${RELEASE} /opt/matterbridge
    cd /opt/matterbridge
    npm ci >/dev/null 2>&1
    npm run build >/dev/null 2>&1
    
    msg_info "Cleaning up"
    rm /opt/${RELEASE}.zip 
    msg_ok "Cleaned"

    msg_info "Starting Matterbridge Service"
    systemctl start matterbridge
    sleep 1
    msg_ok "Started Matterbridge Service"
  msg_ok "Updated Successfully!\n"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}"
  fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:8283${CL} \n"
