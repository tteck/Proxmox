#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   __  __          __      __          __   _  ________
  / / / /___  ____/ /___ _/ /____     / /  | |/ / ____/
 / / / / __ \/ __  / __ `/ __/ _ \   / /   |   / /     
/ /_/ / /_/ / /_/ / /_/ / /_/  __/  / /___/   / /___   
\____/ .___/\__,_/\__,_/\__/\___/  /_____/_/|_\____/   
    /_/                                                

EOF
}
set -e
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
CM='\xE2\x9C\x94\033'
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
header_info
while true; do
  read -p "This Will Update All LXC Containers. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
clear
excluded_containers=("$@")
function update_container() {
  container=$1
  header_info
  name=$(pct exec "$container" hostname)
  echo -e "${BL}[Info]${GN} Updating ${BL}$container${CL} : ${GN}$name${CL} \n"
  os=$(pct config "$container" | awk '/^ostype/ {print $2}')
  case "$os" in
    alpine)  pct exec "$container" -- ash -c "apk update && apk upgrade" ;;
    archlinux)  pct exec "$container" -- bash -c "pacman -Syyu --noconfirm";;
    fedora|rocky|centos|alma)  pct exec "$container" -- bash -c "dnf -y update && dnf -y upgrade" ;;
    ubuntu|debian|devuan)  pct exec "$container" -- bash -c "apt-get update 2>/dev/null | grep 'packages.*upgraded'; apt list --upgradable && apt-get -y dist-upgrade" ;;
  esac
}
header_info
for container in $(pct list | awk '{if(NR>1) print $1}'); do
  excluded=false
  for excluded_container in "${excluded_containers[@]}"; do
    if [ "$container" == "$excluded_container" ]; then
      excluded=true
      break
    fi
  done
  if [ "$excluded" == true ]; then
    header_info
    echo -e "${BL}[Info]${GN} Skipping ${BL}$container${CL}"
    sleep 1
  else
    status=$(pct status $container)
    template=$(pct config $container | grep -q "template:" && echo "true" || echo "false")
    if [ "$template" == "false" ] && [ "$status" == "status: stopped" ]; then
      echo -e "${BL}[Info]${GN} Starting${BL} $container ${CL} \n"
      pct start $container
      echo -e "${BL}[Info]${GN} Waiting For${BL} $container${CL}${GN} To Start ${CL} \n"
      sleep 5
      update_container $container
      echo -e "${BL}[Info]${GN} Shutting down${BL} $container ${CL} \n"
      pct shutdown $container &
    elif [ "$status" == "status: running" ]; then
      update_container $container
    fi
  fi
done
wait
header_info
echo -e "${GN} Finished, All Containers Updated. ${CL} \n"
