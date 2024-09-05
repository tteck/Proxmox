#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    __ __                     __   ________
   / //_/__  _________  ___  / /  / ____/ /__  ____ _____
  / ,< / _ \/ ___/ __ \/ _ \/ /  / /   / / _ \/ __ `/ __ \
 / /| /  __/ /  / / / /  __/ /  / /___/ /  __/ /_/ / / / /
/_/ |_\___/_/  /_/ /_/\___/_/   \____/_/\___/\__,_/_/ /_/

EOF
}
YW=$(echo "\033[33m")
RD=$(echo "\033[01;31m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
current_kernel=$(uname -r)
available_kernels=$(dpkg --list | grep 'kernel-.*-pve' | awk '{print $2}' | grep -v "$current_kernel" | sort -V)
header_info

function msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

whiptail --backtitle "Proxmox VE Helper Scripts" --title "Proxmox VE Kernel Clean" --yesno "This will Clean Unused Kernel Images, USE AT YOUR OWN RISK. Proceed?" 10 68 || exit
if [ -z "$available_kernels" ]; then
  whiptail --backtitle "Proxmox VE Helper Scripts" --title "No Old Kernels" --msgbox "It appears there are no old Kernels on your system. \nCurrent kernel ($current_kernel)." 10 68
  echo "Exiting..."
  sleep 2
  clear
  exit
fi
  KERNEL_MENU=()
  MSG_MAX_LENGTH=0
while read -r TAG ITEM; do
  OFFSET=2
  ((${#ITEM} + OFFSET > MSG_MAX_LENGTH)) && MSG_MAX_LENGTH=${#ITEM}+OFFSET
  KERNEL_MENU+=("$TAG" "$ITEM " "OFF")
done < <(echo "$available_kernels")

remove_kernels=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Current Kernel $current_kernel" --checklist "\nSelect Kernels to remove:\n" 16 $((MSG_MAX_LENGTH + 58)) 6 "${KERNEL_MENU[@]}" 3>&1 1>&2 2>&3 | tr -d '"') || exit
[ -z "$remove_kernels" ] && {
  whiptail --backtitle "Proxmox VE Helper Scripts" --title "No Kernel Selected" --msgbox "It appears that no Kernel was selected" 10 68
  echo "Exiting..."
  sleep 2
  clear
  exit
}
whiptail --backtitle "Proxmox VE Helper Scripts" --title "Remove Kernels" --yesno "Would you like to remove the $(echo $remove_kernels | awk '{print NF}') previously selected Kernels?" 10 68 || exit

msg_info "Removing ${CL}${RD}$(echo $remove_kernels | awk '{print NF}') ${CL}${YW}old Kernels${CL}"
/usr/bin/apt purge -y $remove_kernels >/dev/null 2>&1
msg_ok "Successfully Removed Kernels"

msg_info "Updating GRUB"
/usr/sbin/update-grub >/dev/null 2>&1
msg_ok "Successfully Updated GRUB"
msg_info "Exiting"
sleep 2
msg_ok "Finished"
