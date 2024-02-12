#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    _   __          __       __                __   __  __      __
   / | / /__  _  __/ /______/ /___  __  ______/ /  / / / /_  __/ /_
  /  |/ / _ \| |/_/ __/ ___/ / __ \/ / / / __  /  / /_/ / / / / __ \
 / /|  /  __/>  </ /_/ /__/ / /_/ / /_/ / /_/ /  / __  / /_/ / /_/ /
/_/ |_/\___/_/|_|\__/\___/_/\____/\__,_/\__,_/  /_/ /_/\__,_/_.___/
Alpine
EOF
}
header_info
echo -e "Loading..."
APP="Alpine-Nextcloud"
var_disk="2"
var_cpu="2"
var_ram="1024"
var_os="alpine"
var_version="3.19"
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
  if [[ ! -d /usr/share/webapps/nextcloud ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  if ! apk -e info newt >/dev/null 2>&1; then
    apk add -q newt
  fi
  RELEASE=$(curl -s https://api.github.com/repos/nextcloud/server/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  while true; do
    CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select"  11 58 3 \
      "1" "Update Nextcloud to $RELEASE" OFF \
      "2" "Nextcloud Login Credentials" ON \
      "3" "Renew Self-signed Certificate" OFF \
      3>&1 1>&2 2>&3)      
    exit_status=$?
    if [ $exit_status == 1 ]; then
      clear
      exit-script
    fi
    header_info
    case $CHOICE in
    1)
      apk update && apk upgrade
      if ! apk -e info php82-sodium >/dev/null 2>&1; then
        apk add -q php82-sodium
      fi
      if ! apk -e info php82-bz2 >/dev/null 2>&1; then
        apk add -q php82-bz2
      fi
      su nextcloud -s /bin/sh -c 'php82 /usr/share/webapps/nextcloud/occ upgrade'
      su nextcloud -s /bin/sh -c 'php82 /usr/share/webapps/nextcloud/occ db:add-missing-indices'
      exit
      ;;
    2)
      cat nextcloud.creds
      exit
      ;;
    3)
      openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/nextcloud-selfsigned.key -out /etc/ssl/certs/nextcloud-selfsigned.crt -subj "/C=US/O=Nextcloud/OU=Domain Control Validated/CN=nextcloud.local" > /dev/null 2>&1
      rc-service nginx restart
      exit
      ;;
    esac
  done
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}https://${IP}${CL} \n"
