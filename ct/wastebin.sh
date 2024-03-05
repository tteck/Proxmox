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
 _    _           _       _     _       
| |  | |         | |     | |   (_)      
| |  | | __ _ ___| |_ ___| |__  _ _ __  
| |/\| |/ _` / __| __/ _ \ '_ \| | '_ \ 
\  /\  / (_| \__ \ ||  __/ |_) | | | | |
 \/  \/ \__,_|___/\__\___|_.__/|_|_| |_|
                                               
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
if [[ ! -d /opt/wastebin ]]; then 
	msg_error "No ${APP} Installation Found!"; 
	exit; 
fi
msg_info "Updating ${APP} LXC"
cd /opt/wastebin && git_output=$(git pull)
if [[ $git_output == *"Already up to date."* ]]; then
    msg_error "There is currently no update available."
    exit 0
else
    echo "Update found. Perform next steps..."
    cd /opt/wastebin
    cargo update
    nohup cargo run --release > /opt/wastebin/wastebin.log 2>&1 &
    msg_ok "Updated Successfully"
fi
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
