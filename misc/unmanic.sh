#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
  __  __                     _
 / / / /__  __ _  ___ ____  (_)___
/ /_/ / _ \/  ' \/ _ `/ _ \/ / __/
\____/_//_/_/_/_/\_,_/_//_/_/\__/

EOF
}
header_info
while true; do
  read -p "This will add Unmanic to an existing LXC Container ONLY. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
set -e
NODE=$(hostname)
while read -r line; do
  TAG=$(echo "$line" | awk '{print $1}')
  ITEM=$(echo "$line" | awk '{print substr($0,36)}')
  OFFSET=2
  if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
    MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
  fi
  CTID_MENU+=("$TAG" "$ITEM " "OFF")
done < <(pct list | awk 'NR>1')

while [ -z "${CTID:+x}" ]; do
  CTID=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Containers on $NODE" --radiolist \
    "\nSelect a container to add Unmanic to:\n" \
    16 $(($MSG_MAX_LENGTH + 23)) 6 \
    "${CTID_MENU[@]}" 3>&1 1>&2 2>&3) || exit
done

echo "Installing Unmanic..."
lxc-attach -n $CTID -- bash -c "apt-get -y install python3-pip && python3 -m pip install unmanic && apt-get -y install ffmpeg && cat << EOF >/etc/systemd/system/unmanic.service
[Unit]
Description=Unmanic - Library Optimiser
After=network-online.target
StartLimitInterval=200
StartLimitBurst=3

[Service]
Type=simple
ExecStart=/usr/local/bin/unmanic
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF"
lxc-attach -n $CTID -- bash -c "systemctl enable -q --now unmanic.service"
echo "Installed Unmanic"
sleep 2
echo -e "\n\e[1;32m ✔ Completed Successfully!\e[0m"
echo -e "\n\e[1;32m In a browser, go to ${CTID}'s IP:8888 \e[0m"
