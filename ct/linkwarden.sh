#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    __    _       __                           __
   / /   (_)___  / /___      ______ __________/ /__  ____
  / /   / / __ \/ //_/ | /| / / __ `/ ___/ __  / _ \/ __ \
 / /___/ / / / / ,<  | |/ |/ / /_/ / /  / /_/ /  __/ / / /
/_____/_/_/ /_/_/|_| |__/|__/\__,_/_/   \__,_/\___/_/ /_/

EOF
}
header_info
echo -e "Loading..."
APP="Linkwarden"
var_disk="8"
var_cpu="2"
var_ram="2048"
var_os="ubuntu"
var_version="22.04"
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
if [[ ! -d /opt/linkwarden ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP"
systemctl stop linkwarden
cd /opt/linkwarden
if git pull | grep -q 'Already up to date'; then
  msg_ok "Already up to date"
  systemctl start linkwarden
  exit
fi
git pull
yarn
npx playwright install-deps
yarn build
yarn prisma migrate deploy
systemctl start linkwarden
msg_ok "Updated $APP"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP}${CL} should be reachable by going to the following URL.
         ${BL}http://${IP}:3000${CL} \n"
