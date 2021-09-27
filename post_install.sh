#!/usr/bin/env bash

echo -e "\e[1;33m This script will disable the Enterprise Repo,
enable the No Subscription Repo and attempt a No Nag fix *PVE7 ONLY*\e[0m"
read -p "Press [Enter] to start the PVE7 Post Install Script"
read -t 2 -p "Disabling Enterprise Repo ..."
sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/pve-enterprise.list
read -t 2 -p "Enabling No Subscription Repo ..."
cat <<EOF > /etc/apt/sources.list
deb http://ftp.us.debian.org/debian bullseye main contrib
deb http://ftp.us.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org bullseye-security main contrib
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
# deb http://download.proxmox.com/debian/pve bullseye pvetest
EOF

read -t 2 -p "Enabling No Nag ..."
sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status.toLowerCase() \!== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service

echo -e "\e[1;33m Finished....Please Update Proxmox \e[0m"