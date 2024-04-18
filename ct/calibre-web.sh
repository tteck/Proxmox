#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/remz1337/Proxmox/remz/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   ______      ___ __                                 __  
  / ____/___ _/ (_) /_  ________       _      _____  / /_ 
 / /   / __ `/ / / __ \/ ___/ _ \_____| | /| / / _ \/ __ \
/ /___/ /_/ / / / /_/ / /  /  __/_____/ |/ |/ /  __/ /_/ /
\____/\__,_/_/_/_.___/_/   \___/      |__/|__/\___/_.___/ 
                                                          
EOF
}
header_info
echo -e "Loading..."
APP="Calibre-web"
var_disk="4"
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
  if [[ ! -f /etc/systemd/system/cps.service ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  header_info
  msg_info "Updating $APP LXC"
  systemctl stop cps
  cd /opt/kepubify
  rm kepubify-linux-64bit
  curl -fsSLO https://github.com/pgaskin/kepubify/releases/latest/download/kepubify-linux-64bit &>/dev/null
  chmod +x kepubify-linux-64bit
  rm /opt/calibre-web/metadata.db
  wget https://github.com/janeczku/calibre-web/raw/master/library/metadata.db -P /opt/calibre-web
  if [ -f "/opt/calibre-web/options.txt" ]; then
    echo "$FILE exists."
	cps_options="$(cat /opt/calibre-web/options.txt)"
	pip install --upgrade calibreweb[$cps_options]
  else
    pip install --upgrade calibreweb
  fi
  systemctl start cps
  msg_ok "Updated $APP LXC"
  exit
}

start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -memory 512
pct set $CTID -cores 1
msg_ok "Set Container to Normal Resources"
msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8083${CL} \n"
