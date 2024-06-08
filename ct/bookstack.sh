#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: Javed Hussain (javedh-dev)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ____              __        __             __  
   / __ )____  ____  / /_______/ /_____ ______/ /__
  / __  / __ \/ __ \/ //_/ ___/ __/ __ `/ ___/ //_/
 / /_/ / /_/ / /_/ / ,< (__  ) /_/ /_/ / /__/ ,<   
/_____/\____/\____/_/|_/____/\__/\__,_/\___/_/|_|  
                                                   
EOF
}
header_info
echo -e "Loading..."
APP="Bookstack"
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
if [[ ! -d /opt/bookstack/ ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
cd /opt/bookstack
git pull origin release
composer install --no-dev
php artisan migrate
php artisan cache:clear
php artisan config:clear
php artisan view:clear
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}${CL} \n"
