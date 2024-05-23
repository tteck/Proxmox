#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/jawaff/Proxmox/recyclarr/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    ____                       __               
   / __ \___  _______  _______/ /___ ___________
  / /_/ / _ \/ ___/ / / / ___/ / __ `/ ___/ ___/
 / _, _/  __/ /__/ /_/ / /__/ / /_/ / /  / /    
/_/ |_|\___/\___/\__, /\___/_/\__,_/_/  /_/     
                /____/                          
 Alpine                                                 

EOF
}
header_info
echo -e "Loading..."
APP="Alpine-Recyclarr"
var_disk="0.3"
var_cpu="1"
var_ram="256"
var_os="alpine"
var_version="3.19"
var_recyclarr_url="https://github.com/recyclarr/recyclarr/releases/latest/download/recyclarr-linux-x64.tar.xz"
var_config_file="/opt/recyclarr/recyclarr.yml"
var_recyclarr_cron_path="/etc/periodic/daily/recyclarr"
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
  if ! apk -e info newt >/dev/null 2>&1; then
    apk add -q newt
  fi
  while true; do
    CHOICE=$(
      whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --menu "Select option" 11 58 2 \
        "1" "Update Recyclarr" \
        3>&2 2>&1 1>&3
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
      curl -s -L "$var_recyclarr_url" | tar xJ --overwrite -C /usr/local/bin
      exit
      ;;
    esac
  done
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "Please update ${APP} configuration at ${var_config_file}.\n
Then run ${var_recyclarr_cron_path} for immediate sync or wait until tomorrow for the sync to complete.\n"
