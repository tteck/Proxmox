#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Author: DeepWoods
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"

    _   __       ______ _  __ __             
   / | / /_  __ / ____/(_)/ // /_ ___   _____
  /  |/ /| |/_// /_   / // // __// _ \ / ___/
 / /|  /_>  < / __/  / // // /_ /  __// /    
/_/ |_//_/|_|/_/    /_//_/ \__/ \___//_/     
                                             
EOF
}
header_info
echo -e "Loading..."
APP="NxFilter"
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
if [[ ! -d /nxfilter ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
  read -r -p "Warning: Storage is dangerously low! Consider lowering ${APP} log retention days in System->Setup->Misc.  Continue anyway??? <y/N> " prompt
  [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
fi
LATEST=$(curl -fsSL https://nxfilter.org/curver.php)
if [ "${LATEST}" != "$(cat /nxfilter/version.txt)" ];
then
  msg_info "Stopping ${APP}"
  systemctl stop nxfilter
  msg_ok "Stopped ${APP}"

  msg_info "Updating ${APP} to v${LATEST}"
  curl -fsSL $(printf ' -O http://pub.nxfilter.org/nxfilter-%s.deb' ${LATEST})
  apt-get update &>/dev/null
  apt-get install -y --no-install-recommends ./$(printf 'nxfilter-%s.deb' ${LATEST}) &>/dev/null
  echo "${LATEST}" > /nxfilter/version.txt
  msg_ok "Updated ${APP} to v${LATEST}"

  msg_info "Cleaning up"
  rm -rf ./$(printf 'nxfilter-%s.deb' ${LATEST})
  msg_ok "Cleaned"

  msg_info "Starting ${APP}"
  systemctl start nxfilter
  msg_ok "Started ${APP}"
  msg_ok "Updated Successfully"
else
  msg_ok "No update required.  Already running ${APP} version v${LATEST}."
fi
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP}${CL} should be reachable by going to the following URL.
         ${BL}http://${IP}/admin.jsp${CL} \n"
