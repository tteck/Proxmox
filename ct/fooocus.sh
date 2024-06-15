#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: ulmentflam
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ______
   / ____/___  ____  ____  _______  _______
  / /_  / __ \/ __ \/ __ \/ ___/ / / / ___/
 / __/ / /_/ / /_/ / /_/ / /__/ /_/ (__  )
/_/    \____/\____/\____/\___/\__,_/____/

EOF
}
header_info
echo -e "Loading..."
APP="Fooocus"
var_disk="4"
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
if [[ ! -f /etc/systemd/system/fooocus.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC"
apt-get update &>/dev/null

RELEASE=$(curl -s https://api.github.com/repos/lllyasviel/Fooocus/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')

if [[ -z "$RELEASE" ]]; then
  msg_error "Failed to get latest version"
  exit
fi

UPD=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 2 \
  "1" "Update Fooocus to $RELEASE" ON \
  3>&1 1>&2 2>&3)
header_info
if [ "$UPD" == "1" ]; then
  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
    msg_info "Updating $APP to $RELEASE"
    systemctl stop fooocus.service
    cd ~ || msg_error "Failed to change directory"
    wget -q https://github.com/lllyasviel/Fooocus/archive/refs/tags/${RELEASE}.tar.gz
    # shellcheck disable=SC2086
    tar -xf ${RELEASE}.tar.gz
    cp -r "${RELEASE}"/* /opt/Fooocus
    rm -rf "${RELEASE}" "${RELEASE}".tar.gz
    cd /opt/Fooocus || msg_error "Failed to change directory"
    pip3 install --upgrade pip
    pip3 install -r requirements_versions.txt
    echo "$RELEASE" > /opt/${APP}_version.txt
    systemctl start fooocus.service
    msg_ok "Updated $APP LXC"
  else
    msg_warn "Already on latest version"
  fi
fi
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:80${CL} \n"
