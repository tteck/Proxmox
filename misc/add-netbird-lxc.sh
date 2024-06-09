#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    _   __     __  ____  _          __
   / | / /__  / /_/ __ )(_)________/ /
  /  |/ / _ \/ __/ __  / / ___/ __  /
 / /|  /  __/ /_/ /_/ / / /  / /_/ /
/_/ |_/\___/\__/_____/_/_/   \__,_/

EOF
}
header_info
set -e
while true; do
  read -p "This will add NetBird to an existing LXC Container ONLY. Proceed (Y/n)? " yn
  case $yn in
  [Yy]*|"") break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
header_info
echo "Loading..."
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

NODE=$(hostname)
MSG_MAX_LENGTH=0
declare -a CTID_MENU
declare -a SELECTED_CTIDS
declare -a ERROR_LOG
INSTALL_LOG=""

# Read the list of containers and prepare the menu
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
  # Allow the user to select multiple containers
  SELECTED_CTIDS=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Containers on $NODE" --checklist \
    "\nSelect containers to add NetBird to:\n" \
    16 $(($MSG_MAX_LENGTH + 23)) 6 \
    "${CTID_MENU[@]}" 3>&1 1>&2 2>&3) || exit
done

# Strip quotations 
SELECTED_CTIDS=$(echo "$SELECTED_CTIDS" | tr -d '"')

# Install NetBird on each selected container
for CTID in $SELECTED_CTIDS; do
  CTID_CONFIG_PATH="/etc/pve/lxc/${CTID}.conf"
  cat <<EOF >>$CTID_CONFIG_PATH
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
EOF
  header_info
  msg "Installing NetBird on container $CTID..."
  if ! pct exec "$CTID" -- bash -c '
    apt install -y ca-certificates gpg &>/dev/null
    wget -qO- https://pkgs.netbird.io/debian/public.key | gpg --dearmor >/usr/share/keyrings/netbird-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/netbird-archive-keyring.gpg] https://pkgs.netbird.io/debian stable main" >/etc/apt/sources.list.d/netbird.list
    apt-get update &>/dev/null
    apt-get install -y netbird-ui &>/dev/null
  '; then
    ERROR_LOG+=("Error installing NetBird on container $CTID")
  else
    # Append the success message to the INSTALL_LOG variable
    INSTALL_LOG+="\e[1;32m ✔ Installed NetBird on container $CTID.\e[0m\n"
  fi
done

# Display the installation log
echo -e "$INSTALL_LOG"

# Display errors, if any
if [ ${#ERROR_LOG[@]} -ne 0 ]; then
  msg "Some containers encountered errors during installation:"
  for error in "${ERROR_LOG[@]}"; do
    msg "$error"
  done
fi
msg "\e[1;31m Reboot the LXC containers to apply the changes, then run \e[0mnetbird up\e[1;31m in the LXC console\e[0m"

