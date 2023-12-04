#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
# Print Rhasspy
cat <<"EOF"
    ____  __                               
   / __ \/ /_  ____ _______________  __  __
  / /_/ / __ \/ __ `/ ___/ ___/ __ \/ / / /
 / _, _/ / / / /_/ (__  |__  ) /_/ / /_/ / 
/_/ |_/_/ /_/\__,_/____/____/ .___/\__, /  
                           /_/    /____/ 
EOF
}
header_info
echo -e "Loading..."
APP="Rhasspy"
var_disk="16"
var_cpu="2"
var_ram="2048"
var_os="debian"
var_version="11"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="0"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
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
    if [[ ! -d /var/lib/docker/volumes/rhasspy_profiles/_data ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi
    UPD=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "UPDATE" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 4 \
     "1" "Update ALL Containers" ON \
     "2" "Remove ALL Unused Images" OFF \
    3>&1 1>&2 2>&3)
    header_info

    if [ "$UPD" == "1" ]; then
    msg_info "Updating All Containers"
    CONTAINER_LIST="${1:-$(docker ps -q)}"
    for container in ${CONTAINER_LIST}; do
      CONTAINER_IMAGE="$(docker inspect --format "{{.Config.Image}}" --type container ${container})"
      RUNNING_IMAGE="$(docker inspect --format "{{.Image}}" --type container "${container}")"
      docker pull "${CONTAINER_IMAGE}"
      LATEST_IMAGE="$(docker inspect --format "{{.Id}}" --type image "${CONTAINER_IMAGE}")"
      if [[ "${RUNNING_IMAGE}" != "${LATEST_IMAGE}" ]]; then
        echo "Updating ${container} image ${CONTAINER_IMAGE}"
        DOCKER_COMMAND="$(runlike "${container}")"
        docker rm --force "${container}"
        eval ${DOCKER_COMMAND}
      fi
    done
    msg_ok "Updated All Containers"
    exit
  fi
  if [ "$UPD" == "2" ]; then
    msg_info "Removing ALL Unused Images"
    docker image prune -af
    msg_ok "Removed ALL Unused Images"
    exit
  fi


}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
            ${BL}http://${IP}:12101${CL}\n"
    