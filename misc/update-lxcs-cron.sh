#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

echo "$(date)"
excluded_containers=("$@")
function update_container() {
  container=$1
  name=$(pct exec "$container" hostname)
  os=$(pct config "$container" | awk '/^ostype/ {print $2}')
  if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
    disk_info=$(pct exec "$container" df /boot | awk 'NR==2{gsub("%","",$5); printf "%s %.1fG %.1fG %.1fG", $5, $3/1024/1024, $2/1024/1024, $4/1024/1024 }')
    read -ra disk_info_array <<<"$disk_info"
    echo -e "\n[Info] Updating $container : $name - Boot Disk: ${disk_info_array[0]}% full [${disk_info_array[1]}/${disk_info_array[2]} used, ${disk_info_array[3]} free]"
  else
    echo -e "\n[Info] Updating $container : $name - [No disk info for ${os}]"
  fi
  case "$os" in
  alpine) pct exec "$container" -- ash -c "apk update && apk upgrade" ;;
  archlinux) pct exec "$container" -- bash -c "pacman -Syyu --noconfirm" ;;
  fedora | rocky | centos | alma) pct exec "$container" -- bash -c "dnf -y update && dnf -y upgrade" ;;
  ubuntu | debian | devuan) pct exec "$container" -- bash -c "apt-get update 2>/dev/null | grep 'packages.*upgraded'; apt-get upgrade --dry-run && DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" dist-upgrade -y" ;;
  esac
}

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
    echo -e "[Info] Skipping $container"
    sleep 1
  else
    status=$(pct status $container)
    template=$(pct config $container | grep -q "template:" && echo "true" || echo "false")
    if [ "$template" == "false" ] && [ "$status" == "status: stopped" ]; then
      echo -e "[Info] Starting $container"
      pct start $container
      echo -e "[Info] Waiting For $container To Start"
      sleep 5
      update_container $container
      echo -e "[Info] Shutting down $container"
      pct shutdown $container &
    elif [ "$status" == "status: running" ]; then
      update_container $container
    fi
  fi
done
wait

echo -e "Finished, All Containers Updated. \n"
