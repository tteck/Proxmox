#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Source: https://github.com/matze/wastebin


function header_info {
clear
cat <<"EOF"
 _       __           __       __    _     
| |     / /___ ______/ /____  / /_  (_)___ 
| | /| / / __ `/ ___/ __/ _ \/ __ \/ / __ \
| |/ |/ / /_/ (__  ) /_/  __/ /_/ / / / / /
|__/|__/\__,_/____/\__/\___/_.___/_/_/ /_/ 
                                            
EOF
}
header_info
echo -e "Loading..."
APP="Wastebin"
var_disk="4"
var_cpu="4"
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
if [[ ! -d /opt/wastebin ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
  read -r -p "Warning: Storage is dangerously low, continue anyway? <y/N> " prompt
  [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
fi
msg_info "Stopping Wastebin"
systemctl stop wastebin
msg_ok "Wastebin Stopped"

msg_info "Updating Wastebin"
RELEASE=$(curl -s https://api.github.com/repos/matze/wastebin/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
cd /opt
if [ -d wastebin_bak ]; then
  rm -rf wastebin_bak
fi
mv wastebin wastebin_bak
wget -q "https://github.com/matze/wastebin/archive/refs/tags/${RELEASE}.zip"
unzip -q ${RELEASE}.zip
mv wastebin-${RELEASE} /opt/wastebin
cd /opt/wastebin
cargo update -q 
cargo build -q --release
msg_ok "Updated Wastebin"

msg_info "Starting Wastebin"
systemctl start wastebin
msg_ok "Started Wastebin"

msg_info "Cleaning Up"
cd /opt
rm -R ${RELEASE}.zip 
rm -R wastebin_bak 
msg_ok "Cleaned"
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -cores 2
msg_ok "Set Container to Normal Resources"

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:8088${CL} \n"
