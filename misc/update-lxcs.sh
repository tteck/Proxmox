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
set -eEuo pipefail
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
CM='\xE2\x9C\x94\033'
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
header_info
echo "Loading..."
whiptail --backtitle "Proxmox VE Helper Scripts" --title "Proxmox VE LXC Updater" --yesno "This Will Update LXC Containers. Proceed?" 10 58 || exit
NODE=$(hostname)
EXCLUDE_MENU=()
MSG_MAX_LENGTH=0
while read -r TAG ITEM; do
  OFFSET=2
  ((${#ITEM} + OFFSET > MSG_MAX_LENGTH)) && MSG_MAX_LENGTH=${#ITEM}+OFFSET
  EXCLUDE_MENU+=("$TAG" "$ITEM " "OFF")
done < <(pct list | awk 'NR>1')
excluded_containers=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Containers on $NODE" --checklist "\nSelect containers to skip from updates:\n" 16 $((MSG_MAX_LENGTH + 23)) 6 "${EXCLUDE_MENU[@]}" 3>&1 1>&2 2>&3 | tr -d '"') || exit
function update_container() {
  container=$1
  header_info
  name=$(pct exec "$container" hostname)
  os=$(pct config "$container" | awk '/^ostype/ {print $2}')
  if [[ "$os" == "ubuntu" || "$os" == "debian" || "$os" == "fedora" ]]; then
    disk_info=$(pct exec "$container" df /boot | awk 'NR==2{gsub("%","",$5); printf "%s %.1fG %.1fG %.1fG", $5, $3/1024/1024, $2/1024/1024, $4/1024/1024 }')
    read -ra disk_info_array <<<"$disk_info"
    echo -e "${BL}[Info]${GN} Updating ${BL}$container${CL} : ${GN}$name${CL} - ${YW}Boot Disk: ${disk_info_array[0]}% full [${disk_info_array[1]}/${disk_info_array[2]} used, ${disk_info_array[3]} free]${CL}\n"
  else
    echo -e "${BL}[Info]${GN} Updating ${BL}$container${CL} : ${GN}$name${CL} - ${YW}[No disk info for ${os}]${CL}\n"
  fi
  case "$os" in
  alpine) pct exec "$container" -- ash -c "apk update && apk upgrade" ;;
  archlinux) pct exec "$container" -- bash -c "pacman -Syyu --noconfirm" ;;
  fedora | rocky | centos | alma) pct exec "$container" -- bash -c "dnf -y update && dnf -y upgrade" ;;
  ubuntu | debian | devuan) pct exec "$container" -- bash -c "apt-get update 2>/dev/null | grep 'packages.*upgraded'; apt list --upgradable && apt-get -y dist-upgrade" ;;
  esac
}
header_info
for container in $(pct list | awk '{if(NR>1) print $1}'); do
  if [[ " ${excluded_containers[@]} " =~ " $container " ]]; then
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
echo -e "${GN} Finished, Selected Containers Updated. ${CL} \n"
