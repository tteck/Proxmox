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

start() {
  BACKUP_PATH=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "\nDefaults to root\ne.g. /mnt/backups/" 9 68 --title "Directory to backup to:" 3>&1 1>&2 2>&3)

  if [ -z "$BACKUP_PATH" ]; then
    BACKUP_PATH="/root/"
  else
    BACKUP_PATH="$BACKUP_PATH"
  fi

  DIR=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "\nDefaults to etc\ne.g. root, var/lib/pve-cluster etc." 9 68 --title "Directory to work in (No leading or trailing slashes):" 3>&1 1>&2 2>&3)

  if [ -z "$DIR" ]; then
    DIR="etc"
  else
    DIR="$DIR"
  fi

  DIR_DASH=$(echo "$DIR" | tr '/' '-')
  BACKUP_FILE="$(hostname)-${DIR_DASH}-backup"
  selected_directories=()

  while read -r dir; do
    DIRNAME=$(basename "$dir")
    OFFSET=2
    if [[ $((${#DIRNAME} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
      MSG_MAX_LENGTH=$((${#DIRNAME} + $OFFSET))
    fi
    CTID_MENU+=("$DIRNAME" "$dir " "OFF")
  done < <(ls -d /${DIR}/*)

  while [ -z "${HOST_BACKUP:+x}" ]; do
    HOST_BACKUP=$(whiptail --backtitle "Proxmox VE Host Backup" --title "Working in the ${DIR} directory " --checklist \
      "\nSelect what files/directories to backup:\n" \
      16 $(($MSG_MAX_LENGTH + 58)) 6 \
      "${CTID_MENU[@]}" 3>&1 1>&2 2>&3) || exit

    for selected_dir in ${HOST_BACKUP//\"/}; do
      selected_directories+=("/${DIR}/$selected_dir")
    done
  done

  selected_directories_string=$(printf "%s " "${selected_directories[@]}")
  header_info
  echo -e "This will create a backup in\e[1;33m $BACKUP_PATH \e[0mfor these files and directories\e[1;33m ${selected_directories_string% } \e[0m"
  read -p "Press ENTER to continue..."
  header_info
  echo "Working..."
  tar -czf "$BACKUP_PATH$BACKUP_FILE-$(date +%Y_%m_%d).tar.gz" --absolute-names ${selected_directories_string% }
  header_info
  echo -e "\nFinished"
  echo -e "\e[1;33m \nA backup is rendered ineffective when it remains stored on the host.\n \e[0m"
}

if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "Proxmox VE Host Backup" --yesno "This will create backups for particular files and directories located within a designated directory. Proceed?" 10 88); then
  start
fi
