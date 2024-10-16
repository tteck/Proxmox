#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
       __     ____
      / /__  / / /_  __________  ___  __________
 __  / / _ \/ / / / / / ___/ _ \/ _ \/ ___/ ___/
/ /_/ /  __/ / / /_/ (__  )  __/  __/ /  / /
\____/\___/_/_/\__, /____/\___/\___/_/  /_/
              /____/
EOF
}
header_info
echo -e "Loading..."
APP="Jellyseerr"
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
if [[ ! -d /opt/jellyseerr ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
  read -r -p "Warning: Storage is dangerously low, continue anyway? <y/N> " prompt
  [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
fi
RELEASE=$(curl -s https://api.github.com/repos/Fallenbagel/jellyseerr/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
  msg_info "Stopping ${APP}"
  systemctl stop jellyseerr
  msg_ok "${APP} Stopped"

  msg_info "Setting Container to Extended Resources"
  pct set $CTID -memory 4096
  msg_ok "Set Container to Extended Resources"
  
  msg_info "Updating ${APP} to ${RELEASE}"
  cd /opt
  wget -q "https://github.com/Fallenbagel/jellyseerr/archive/refs/tags/${RELEASE}.zip"
  unzip -q ${RELEASE}.zip 
  mv jellyseerr-${RELEASE:1} /opt/jellyseerr
  cd /opt/jellyseerr
  pnpm install &>/dev/null
  yarn build &>/dev/null
  echo "${RELEASE}" >/opt/${APP}_version.txt
  msg_ok "Updated ${APP}"

  msg_info "Starting ${APP}"
  systemctl start jellyseerrr
  msg_ok "Started ${APP}"

  msg_info "Cleaning Up"
  rm -R ${RELEASE}.zip 
  msg_ok "Cleaned"
  msg_ok "Updated Successfully"
else
  msg_ok "No update required. ${APP} is already at ${RELEASE}"
fi
exit
}

start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -memory 2048
msg_ok "Set Container to Normal Resources"

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:5055${CL} \n"
