#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    __  ___      ______
   /  |/  /___ _/ __/ /
  / /|_/ / __ `/ /_/ /
 / /  / / /_/ / __/ /
/_/  /_/\__,_/_/ /_/
EOF
}
header_info
echo -e "Loading..."
APP="Mafl"
var_disk="2"
var_cpu="1"
var_ram="512"
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
  if [[ ! -d /opt/mafl ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  msg_info "Stopping ${APP}"
  systemctl stop mafl
  msg_ok "Stopped ${APP}"

  msg_info "Backing up config.yml"
  cd ~
  cp -R /opt/mafl/data/config.yml config.yml
  cp -R /opt/mafl/public/icons icons
  cp -R /opt/mafl/public/favicons favicons
  msg_ok "Backed up config.yml and icons, favicons directory"

  msg_info "Updating ${APP}"
  RELEASE=$(curl -s https://api.github.com/repos/hywax/mafl/releases/latest | grep zipball_url | cut -d '"' -f 4)
  rm -rf /opt/mafl/*
  cd /opt/mafl
  wget -q RELEASE -O mafl.zip
  unzip mafl.zip &>/dev/null
  msg_ok "Updated ${APP}"
  msg_info "Restoring config.yml"
  cd ~
  cp -R config.yml /opt/mafl/data
  cp -R icons /opt/mafl/public/icons
  cp -R favicons /opt/mafl/public/favicons
  msg_ok "Restored config.yml and icons, favicons directory"

  msg_info "Cleaning"
  rm -rf config.yml icons favicons /opt/mafl/mafl.zip
  msg_ok "Cleaned"

  msg_info "Starting ${APP}"
  systemctl start mafl
  msg_ok "Started ${APP}"
  msg_ok "Updated Successfully"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:3000${CL} \n"
