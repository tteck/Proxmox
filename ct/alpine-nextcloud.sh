#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    _   __          __  ________                __
   / | / /__  _  __/ /_/ ____/ /___  __  ______/ /
  /  |/ / _ \| |/_/ __/ /   / / __ \/ / / / __  /
 / /|  /  __/>  </ /_/ /___/ / /_/ / /_/ / /_/ /
/_/ |_/\___/_/|_|\__/\____/_/\____/\__,_/\__,_/
Alpine

EOF
}
header_info
echo -e "Loading..."
APP="Alpine-Nextcloud"
var_disk="2"
var_cpu="2"
var_ram="512"
var_os="alpine"
var_version="3.18"
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
      "1" "Update Nextcloud to $RELEASE" ON \
      "2" "Nextcloud Credentials" OFF \
      "3" "Renew selfsigned Certificate" OFF \
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
echo -e "To get the randomized credentials for Setup-Wizard,
run the script again inside the LXC Container. \n

${APP} should be reachable by going to the following URL.
         ${BL}https://${IP}${CL} \n"
