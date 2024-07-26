#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-author: Rogue-King
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ____       ___                        ____                   __
   / __ \___  / (_)________ _____        / __ \____ _____  ___  / /
  / /_/ / _ \/ / / ___/ __ `/ __ \______/ /_/ / __ `/ __ \/ _ \/ / 
 / ____/  __/ / / /__/ /_/ / / / /_____/ ____/ /_/ / / / /  __/ /  
/_/    \___/_/_/\___/\__,_/_/ /_/     /_/    \__,_/_/ /_/\___/_/   
                                                                   
EOF
}
header_info
echo -e "Loading..."
APP="Pelican-Panel"
var_disk="8"
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
if [[ ! -d /var/www/pelican || ! $(ls -A /var/www/pelican) ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
RELEASE=$(wget -q https://github.com/pelican-dev/panel/releases/latest -O - | grep "title>Release" | cut -d " " -f 4 | sed 's/^v//')
msg_info "Updating $APP to ${RELEASE}"
cd /var/www/pelican
php artisan down
curl -L https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz
$STD tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache
composer install --no-dev --optimize-autoloader
php artisan view:clear
php artisan config:clear
php artisan migrate --seed --force
chown -R www-data:www-data /var/www/pelican/* 
php artisan queue:restart
php artisan up
msg_ok "Updated $APP Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:80${CL} \n"
