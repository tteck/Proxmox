#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

clear
cat <<"EOF"
    _   __     __  ____        __
   / | / /__  / /_/ __ \____ _/ /_____ _
  /  |/ / _ \/ __/ / / / __ `/ __/ __ `/
 / /|  /  __/ /_/ /_/ / /_/ / /_/ /_/ /
/_/ |_/\___/\__/_____/\__,_/\__/\__,_/

EOF

install() {
while true; do
  read -p "This script will install NetData on Proxmox VE. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

curl -sSL --fail --connect-timeout 10 --retry 3 -o /root/netdata-repo-edge_2-1+debian12_all.deb https://repo.netdata.cloud/repos/repoconfig/debian/bookworm/netdata-repo-edge_2-1+debian12_all.deb
cat <<EOF >/etc/apt/sources.list.d/netdata.list
deb http://repo.netdata.cloud/repos/stable/debian/ bookworm/
deb http://repo.netdata.cloud/repos/repoconfig/debian/ bookworm/
EOF
rm -rf /etc/apt/sources.list.d/netdata-edge.list
apt-get update && apt-get -y upgrade
apt-get install -y netdata
echo -e "\nInstalled NetData (http://$(hostname -I | awk '{print $1}'):19999)\n"
}

uninstall() {
apt purge -y netdata netdata-core
rm -rf /var/log/netdata /var/lib/netdata /var/cache/netdata /etc/apt/sources.list.d/netdata.list /usr/share/keyrings/netdata.gpg
apt autoremove -y
userdel netdata
  echo -e "\nRemoved NetData from Proxmox VE\n"
}

if ! command -v pveversion >/dev/null 2>&1; then
  clear
  echo -e "\n No PVE Detected!\n"
  exit
fi

OPTIONS=(Install "Install NetData on Proxmox VE" \
         Uninstall "Uninstall NetData from Proxmox VE")

# Show the whiptail menu and save the user's choice
CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "NetData" --menu "Select an option:" 10 58 2 \
          "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

case $CHOICE in
  "Install")
    install
    ;;
  "Uninstall")
    uninstall
    ;;
  *)
    echo "Exiting..."
    exit 0
    ;;
esac
