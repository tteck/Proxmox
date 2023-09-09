#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
    clear
cat <<"EOF"
   __ __         __    ___           __
  / // /__  ___ / /_  / _ )___ _____/ /____ _____
 / _  / _ \(_-</ __/ / _  / _ `/ __/  '_/ // / _ \
/_//_/\___/___/\__/ /____/\_,_/\__/_/\_\\_,_/ .__/
                                           /_/
EOF
}
header_info
while true; do
  read -p "This will backup specific files and directories within the 'etc' directory. Proceed (y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
header_info

BACKUP_PATH="/root/"
BACKUP_FILE="$(hostname)-host-backup"
selected_directories=()

while read -r dir; do
  DIRNAME=$(basename "$dir")
  OFFSET=2
  if [[ $((${#DIRNAME} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
    MSG_MAX_LENGTH=$((${#DIRNAME} + $OFFSET))
  fi
  CTID_MENU+=("$DIRNAME" "$dir " "OFF")
done < <(ls -d /etc/*)

while [ -z "${HOST_BACKUP:+x}" ]; do
  HOST_BACKUP=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SELECTIONS" --checklist \
    "\nSelect what files/directories to backup:\n" \
    16 $(($MSG_MAX_LENGTH + 58)) 6 \
    "${CTID_MENU[@]}" 3>&1 1>&2 2>&3) || exit

  for selected_dir in ${HOST_BACKUP//\"}; do
    selected_directories+=("/etc/$selected_dir")
  done
done

selected_directories_string=$(printf "%s " "${selected_directories[@]}")
header_info
echo -e "This will create backups for the directories \e[1;33m ${selected_directories_string% } \e[0m"
read -p "Press ENTER to continue..."
header_info
tar -czf $BACKUP_PATH$BACKUP_FILE-$(date +%Y_%m_%d).tar.gz --absolute-names ${selected_directories_string% }

echo -e "\nFinished"
echo -e "\e[1;33m \nA backup is rendered ineffective when it remains stored on the host.\n \e[0m"
