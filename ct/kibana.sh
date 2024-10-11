#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/ELKozel/Proxmox/main/misc/build.func)
# Copyright (c) 2024 ELKozel
# Author: T.H. (ELKozel)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
 _  ___ _                       
| |/ (_) |__   __ _ _ __   __ _ 
| ' /| | '_ \ / _` | '_ \ / _` |
| . \| | |_) | (_| | | | | (_| |
|_|\_\_|_.__/ \__,_|_| |_|\__,_|

EOF
}
header_info
echo -e "Loading..."
APP="Kibana"
var_disk="2"
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
  if [[ ! -f /etc/systemd/system/elasticsearch.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
    read -r -p "Warning: Storage is dangerously low, continue anyway? <y/N> " prompt
    [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
  fi

  msg_info "Stopping ${APP}"
  $STD /bin/systemctl stop  kibana.service
  msg_ok "Stopped ${APP}"

  msg_info "Updating ${APP}"
  $STD apt-get install kibana &>/dev/null
  msg_ok "Updated ${APP}"

  msg_info "Starting ${APP}"
  $STD /bin/systemctl restart  kibana.service
  msg_ok "Started ${APP}"

  msg_ok "Updated Successfully"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:5601${CL} \n"
