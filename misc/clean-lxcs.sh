#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info() {
  clear
  cat <<"EOF"
   ________                    __   _  ________
  / ____/ /__  ____ _____     / /  | |/ / ____/
 / /   / / _ \/ __ `/ __ \   / /   |   / /     
/ /___/ /  __/ /_/ / / / /  / /___/   / /___   
\____/_/\___/\__,_/_/ /_/  /_____/_/|_\____/   
                                               
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
echo -e "\n ${RD} USE AT YOUR OWN RISK. Deleting logs/cache may result in some apps/services broken!${CL} \n"
while true; do
  read -p "This Will Clean logs, cache and update apt lists on all LXC Containers. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
clear
function clean_container() {
  container=$1
  header_info
  name=$(pct exec "$container" hostname)
  echo -e "${BL}[Info]${GN} Cleaning ${name} ${CL} \n"
  pct exec $container -- bash -c "apt-get -y --purge autoremove && apt-get -y autoclean && bash <(curl -fsSL https://github.com/tteck/Proxmox/raw/main/misc/clean.sh) && rm -rf /var/lib/apt/lists/* && apt-get update"
}

for container in $(pct list | awk '{if(NR>1) print $1}'); do
  os=$(pct config "$container" | awk '/^ostype/ {print $2}')
  if [ "$os" != "debian" ] && [ "$os" != "ubuntu" ]; then
    header_info
    echo -e "${BL}[Info]${GN} Skipping ${name} ${RD}$container is not Debian or Ubuntu ${CL} \n"
    sleep 1
    continue
  fi
  status=$(pct status $container)
  template=$(pct config $container | grep -q "template:" && echo "true" || echo "false")
  if [ "$template" == "false" ] && [ "$status" == "status: stopped" ]; then
    echo -e "${BL}[Info]${GN} Starting${BL} $container ${CL} \n"
    pct start $container
    echo -e "${BL}[Info]${GN} Waiting For${BL} $container${CL}${GN} To Start ${CL} \n"
    sleep 5
    clean_container $container
    echo -e "${BL}[Info]${GN} Shutting down${BL} $container ${CL} \n"
    pct shutdown $container &
  elif [ "$status" == "status: running" ]; then
    clean_container $container
  fi
done
wait
header_info
echo -e "${GN} Finished, Containers Cleaned. ${CL} \n"
