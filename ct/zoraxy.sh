#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
 _____
/__  /  ____  _________ __  ____  __
  / /  / __ \/ ___/ __ `/ |/_/ / / /
 / /__/ /_/ / /  / /_/ />  </ /_/ /
/____/\____/_/   \__,_/_/|_|\__, /
                           /____/
EOF
}
header_info
echo -e "Loading..."
APP="Zoraxy"
var_disk="6"
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
if [[ ! -d /opt/zoraxy/src ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP"
systemctl stop zoraxy
cd /opt/zoraxy/src
if ! git pull; then
  echo "Already up to date."
  systemctl start zoraxy
  echo "No update required."
  exit
fi
go mod tidy
go build
systemctl start zoraxy
msg_ok "Updated $APP"
exit
}

start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -cores 2
msg_ok "Set Container to Normal Resources"
msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8000${CL} \n"
