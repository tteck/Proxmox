#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/ELKozel/Proxmox/main/misc/build.func)
# Copyright (c) 2024 ELKozel
# Author: T.H. (ELKozel)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    __ __ _ __                     
   / //_/(_) /_  ____ _____  ____ _
  / ,<  / / __ \/ __ `/ __ \/ __ `/
 / /| |/ / /_/ / /_/ / / / / /_/ / 
/_/ |_/_/_.___/\__,_/_/ /_/\__,_/  

EOF
}
header_info
echo -e "Loading..."
APP="Kibana"
var_disk="6"
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
if [[ ! -f /etc/systemd/system/Kibana.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
  read -r -p "Warning: Storage is dangerously low, continue anyway? <y/N> " prompt
  [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
fi

msg_info "Stopping ${APP}"
systemctl stop Kibana
msg_ok "Stopped ${APP}"

msg_info "Updating ${APP} LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated ${APP} LXC"

msg_info "Starting ${APP}"
systemctl start Kibana
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
