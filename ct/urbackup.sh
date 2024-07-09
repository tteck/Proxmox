#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE


function header_info {
clear
cat <<"EOF"
   __  __     ____             __             
  / / / /____/ __ )____ ______/ /____  ______ 
 / / / / ___/ __  / __ `/ ___/ //_/ / / / __ \
/ /_/ / /  / /_/ / /_/ / /__/ ,< / /_/ / /_/ /
\____/_/  /_____/\__,_/\___/_/|_|\__,_/ .___/ 
                                     /_/    

EOF
}
header_info
echo -e "Loading..."
APP="UrBackup"
var_disk="10"
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
  echo_default
}

function update_script() {
  header_info
  if [[ ! -f /etc/default/urbackupsrv ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  RELEASE=$(wget -q -O - https://hndl.urbackup.org/Server/latest/debian/bookworm/ | grep -oP 'urbackup-server_\K[\d\.]+(?=_amd64\.deb)' | head -1)
  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
    msg_info "Updating $APP LXC"
    wget -q https://hndl.urbackup.org/Server/latest/debian/bookworm/urbackup-server_${RELEASE}_amd64.deb 
    sudo DEBIAN_FRONTEND=noninteractive dpkg -i urbackup-server_${RELEASE}_amd64.deb
	sudo apt install -f
    rm -f urbackup-server_${RELEASE}_amd64.deb
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated $APP LXC"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}"
  fi
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:55414${CL} \n"