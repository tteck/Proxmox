#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

set -eEuo pipefail
function header_info {
  clear
  cat <<"EOF"

   __ ___      __  ___              __             __  _
  / // / | /| / / / _ |___________ / /__ _______ _/ /_(_)__  ___
 / _  /| |/ |/ / / __ / __/ __/ -_) / -_) __/ _ `/ __/ / _ \/ _ \
/_//_/ |__/|__/ /_/ |_\__/\__/\__/_/\__/_/  \_,_/\__/_/\___/_//_/

EOF
}
header_info
echo "Loading..."
whiptail --backtitle "Proxmox VE Helper Scripts" --title "Add HW Acceleration" --yesno "This Will Add HW Acceleration to an existing LXC Container. Proceed?" 10 68 || exit
NODE=$(hostname)
PREV_MENU=()
MSG_MAX_LENGTH=0
privileged_containers=$(pct list | awk 'NR>1 && system("grep -q \047unprivileged: 1\047 /etc/pve/lxc/" $1 ".conf")')
if [ -z "$privileged_containers" ]; then
    whiptail --msgbox "No Privileged Containers Found." 10 58
    exit
fi
while read -r TAG ITEM; do
  OFFSET=2
  ((${#ITEM} + OFFSET > MSG_MAX_LENGTH)) && MSG_MAX_LENGTH=${#ITEM}+OFFSET
  PREV_MENU+=("$TAG" "$ITEM " "OFF")
done < <(echo "$privileged_containers")
privileged_container=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Privileged Containers on $NODE" --checklist "\nSelect a Container To Add HW Acceleration:\n" 16 $((MSG_MAX_LENGTH + 23)) 6 "${PREV_MENU[@]}" 3>&1 1>&2 2>&3 | tr -d '"') || exit
header_info
cat <<EOF >>/etc/pve/lxc/${privileged_container}.conf
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.cgroup2.devices.allow: c 29:0 rwm
lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
EOF
pct exec $privileged_container -- bash -c "apt-get -y install va-driver-all && apt-get -y install ocl-icd-libopencl1 && apt-get install -y intel-opencl-icd && chgrp video /dev/dri && chmod 755 /dev/dri && chmod 660 /dev/dri/* && adduser \$(id -u -n) video && adduser \$(id -u -n) render"
header_info
echo -e "Completed Successfully!\n"
echo -e "Reboot container $privileged_container to apply the new settings\n"
