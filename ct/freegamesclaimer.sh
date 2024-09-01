#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
 _____                 ____                              ____ _       _
|  ___| __ ___  ___   / ___| __ _ _ __ ___   ___  ___   / ___| | __ _(_)_ __ ___   ___ _ __
| |_ | '__/ _ \/ _ \ | |  _ / _` | '_ ` _ \ / _ \/ __| | |   | |/ _` | | '_ ` _ \ / _ \ '__|
|  _|| | |  __/  __/ | |_| | (_| | | | | | |  __/\__ \ | |___| | (_| | | | | | | |  __/ |
|_|  |_|  \___|\___|  \____|\__,_|_| |_| |_|\___||___/  \____|_|\__,_|_|_| |_| |_|\___|_|

EOF
}
header_info
echo -e "Loading..."
APP="Free Games Claimer"
var_disk="8"
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
  if [[ ! -d /opt/freegamesclaimer ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  msg_info "Updating $APP"

  cd /opt/freegamesclaimer || exit
  output=$(git pull)
  git pull &>/dev/null
  if echo "$output" | grep -q "Already up to date."
  then
    msg_ok "$APP is already up to date."
    systemctl start overseerr
    exit
  fi
  $STD npm install
  $STD npx playwright install firefox --with-deps
  msg_ok "Updated $APP"
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} has been setup to claim GOG and Epic games.
Make sure to run an initial login for the cookies to be set. \n

For initial setup run: \n
1. cd /opt/freegamesclaimer
2. node epic-games
3. node gog \n"