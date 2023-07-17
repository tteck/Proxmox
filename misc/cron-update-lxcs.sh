#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

clear
cat <<"EOF"
   __  __          __      __          __   _  ________        ______
  / / / /___  ____/ /___ _/ /____     / /  | |/ / ____/____   / ____/________  ____
 / / / / __ \/ __  / __ `/ __/ _ \   / /   |   / /   / ___/  / /   / ___/ __ \/ __ \
/ /_/ / /_/ / /_/ / /_/ / /_/  __/  / /___/   / /___(__  )  / /___/ /  / /_/ / / / /
\____/ .___/\__,_/\__,_/\__/\___/  /_____/_/|_\____/____/   \____/_/   \____/_/ /_/
    /_/

EOF

add() {
while true; do
  read -p "This script will add a cron job to update all LXCs at midnight. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

sh -c '(crontab -l -u root 2>/dev/null; echo "0 0 * * * bash -c \"\$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/update-lxcs-cron.sh >>/var/log/update-lxcs-cron.log 2>&1)\"") | sed "$!N; /^\(.*\)\n\1$/!P; D" | crontab -u root -'
clear
echo -e "\n To view Update LXCs Cron logs: cat /var/log/update-lxcs-cron.log"
}

remove() {
  (crontab -l | grep -v "github.com/tteck/Proxmox/raw/main/misc/update-lxcs-cron.sh") | crontab -
  rm /var/log/update-lxcs-cron.log
  echo "Removed Update LXCs Cron from Proxmox VE"
}

# Define options for the whiptail menu
OPTIONS=(Add "Add Update LXCs Cron to Proxmox VE" \
         Remove "Remove Update LXCs Cron from Proxmox VE")

# Show the whiptail menu and save the user's choice
CHOICE=$(whiptail --title "Update LXCs Cron for Proxmox VE" --menu "Select an option:" 10 58 2 \
          "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

# Check the user's choice and perform the corresponding action
case $CHOICE in
  "Add")
    add
    ;;
  "Remove")
    remove
    ;;
  *)
    echo "Exiting..."
    exit 0
    ;;
esac
