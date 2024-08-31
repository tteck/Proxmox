#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/msarsha/Proxmox/feat/free-games-claimer/misc/build.func)
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
  VERB="yes"
  echo_default
}

function setup_services(){
  msg_info "Initializing gaming services to claim games for"
  CHOICES=$(whiptail --title "Select game services" --separate-output --checklist "Select services" 20 78 4 "EPIC" "Epic Games" OFF "GOG" "Good Old Games" OFF 3>&1 1>&2 2>&3)

  echo $CHOICES
  if [ ! -z "$CHOICES" ]; then
      for CHOICE in $CHOICES; do
        case $CHOICE in
        "EPIC")
          $STD node epic-games
          ;;
        "GOG")
          $STD node gog
          ;;
        *)
          echo "Unsupported item $CHOICE!" >&2
          exit 1
          ;;
        esac
      done
    fi
  msg_ok "Services initialized: ${CHOICES}"
}

function update_script() {
  header_info
  if [[ ! -d /opt/freegamesclaimer ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  msg_info "Updating $APP"

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "UPDATE \ Setup service" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 4 \
      "1" "Update" ON \
      "2" "Setup a service" OFF \
      3>&1 1>&2 2>&3)

  case $CHOICE in
  "1")
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
    msg_ok "Updated $APP - If needed, run update again to setup the gaming services"
    ;;
  "2")
    setup_services
    ;;
  *)
    echo "Unsupported item $CHOICE!" >&2
    exit 1
    ;;
  esac
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} installed"
