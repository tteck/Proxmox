#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
 _    __            ____                          __         
| |  / /___ ___  __/ / /__      ______ __________/ /__  ____ 
| | / / __ `/ / / / / __/ | /| / / __ `/ ___/ __  / _ \/ __ \
| |/ / /_/ / /_/ / / /_ | |/ |/ / /_/ / /  / /_/ /  __/ / / /
|___/\__,_/\__,_/_/\__/ |__/|__/\__,_/_/   \__,_/\___/_/ /_/ 
 Alpine                                                 

EOF
}
header_info
echo -e "Loading..."
APP="Alpine-Vaultwarden"
var_disk="0.3"
var_cpu="1"
var_ram="256"
var_os="alpine"
var_version="3.17"
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
  NET=dhcp
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
  if ! apk -e info newt >/dev/null 2>&1; then
    apk add -q newt
  fi
  while true; do
    CHOICE=$(
      whiptail --title "SUPPORT" --menu "Select option" 11 58 2 \
        "1" "Update Vaultwarden" \
        "2" "Reset ADMIN_TOKEN" 3>&2 2>&1 1>&3
    )
    exit_status=$?
    if [ $exit_status == 1 ]; then
      clear
      exit-script
    fi
    header_info
    case $CHOICE in
    1)
      apk update && apk upgrade
      exit
      ;;
    2)
      if NEWTOKEN=$(whiptail --passwordbox "Setup your ADMIN_TOKEN (make it strong)" 10 58 3>&1 1>&2 2>&3); then
        if [[ -z "$NEWTOKEN" ]]; then exit-script; fi      
        ADMINTOKEN=$(echo -n ${NEWTOKEN} | argon2 "$(openssl rand -base64 32)" -e -id -k 19456 -t 2 -p 1)
        if [[ -f /var/lib/vaultwarden/config.json ]]; then 
          sed -i '/admin_token/d' /var/lib/vaultwarden/config.json
          sed -i "2i\\  \"admin_token\": \"$ADMINTOKEN\"" /var/lib/vaultwarden/config.json
        fi
      fi
      cat <<EOF >/etc/conf.d/vaultwarden
export DATA_FOLDER=/var/lib/vaultwarden
export WEB_VAULT_FOLDER=/var/lib/vaultwarden/web-vault
export WEB_VAULT_ENABLED=true
export ADMIN_TOKEN='$ADMINTOKEN'
export ROCKET_ADDRESS=0.0.0.0
EOF
      rc-service vaultwarden restart
      clear
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
         ${BL}http://${IP}:8000${CL} \n"
