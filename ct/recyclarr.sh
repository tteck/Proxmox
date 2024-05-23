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
EOF
}
header_info
echo -e "Loading..."
APP="Recyclarr"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"
var_recyclarr_url="https://github.com/recyclarr/recyclarr/releases/latest/download/recyclarr-linux-x64.tar.xz"
var_app_dir="/opt/recyclarr"
var_app_file="$var_app_dir/recyclarr"
var_config_file="$var_app_dir/recyclarr.yml"
var_recyclarr_cron_file="$var_app_dir/recyclarr.cron"
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
  if [[ ! -d "$var_app_dir" ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  wget "$var_recyclarr_url" -O - | tar xJ --overwrite -C "$var_app_dir"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "Please update ${APP} configuration at ${var_config_file}.\n
Then run ${var_recyclarr_cron_file} for immediate sync or wait until tomorrow for the sync to complete.\n"
