#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ____             __    ____       __         _     __   ______                           __     _________            __
   / __ \___  ____  / /   / __ \___  / /_  _____(_)___/ /  /_  __/___  _____________  ____  / /_   / ____/ (_)__  ____  / /_
  / /_/ / _ \/ __ `/ /___/ / / / _ \/ __ \/ ___/ / __  /    / / / __ \/ ___/ ___/ _ \/ __ \/ __/  / /   / / / _ \/ __ \/ __/
 / _, _/  __/ /_/ / /___/ /_/ /  __/ /_/ / /  / / /_/ /    / / / /_/ / /  / /  /  __/ / / / /_   / /___/ / /  __/ / / / /_
/_/ |_|\___/\__,_/_/   /_____/\___/_.___/_/  /_/\__,_/    /_/  \____/_/  /_/   \___/_/ /_/\__/   \____/_/_/\___/_/ /_/\__/

EOF
}
header_info
echo -e "Loading..."
APP="RDTClient"
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
if [[ ! -d /opt/rdtclient/ ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated $APP LXC"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:6500${CL} \n"
