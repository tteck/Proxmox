#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    __  __
   / / / /___  ____ ___  ____ ___________
  / /_/ / __ \/ __ `__ \/ __ `/ ___/ ___/
 / __  / /_/ / / / / / / /_/ / /  / /
/_/ /_/\____/_/ /_/ /_/\__,_/_/  /_/

EOF
}
header_info
echo -e "Loading..."
APP="Homarr"
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
if [[ ! -d /opt/homarr ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP (Patience)"
systemctl stop homarr
rm -rf /root/data-homarr-backup
rm -rf /root/database-homarr-backup
cp -R /opt/homarr/data /root/data-homarr-backup
cp -R /opt/homarr/database /root/database-homarr-backup
RELEASE=$(curl -s https://api.github.com/repos/ajnart/homarr/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
wget -q -O- https://github.com/ajnart/homarr/archive/refs/tags/v${RELEASE}.tar.gz | tar -xz -C /opt
cp -R /opt/homarr-${RELEASE}/* /opt/homarr
cp -R /root/data-homarr-backup/* /opt/homarr/data
cp -R /root/database-homarr-backup/* /opt/homarr/database
rm -rf /opt/homarr-${RELEASE}
cd /opt/homarr
yarn install &>/dev/null
yarn build &>/dev/null
systemctl start homarr
msg_ok "Updated $APP"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:3000${CL} \n"
