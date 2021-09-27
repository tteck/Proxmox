#!/usr/bin/env bash

echo -e "\e[1;33m This script will Disable the Enterprise Repo, Enable the No Subscription Repo,
Add (Disabled) Test Repo (repo's can be enabled/disabled via the UI in Repositories) and attempt 
the No Nag fix *PVE7 ONLY*\e[0m"

read -p "Press [Enter] to start the PVE7 Post Install Script"

sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/pve-enterprise.list

cat <<EOF > /etc/apt/sources.list
deb http://ftp.us.debian.org/debian bullseye main contrib
deb http://ftp.us.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org bullseye-security main contrib
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
# deb http://download.proxmox.com/debian/pve bullseye pvetest
EOF

sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status.toLowerCase() \!== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

echo -e "\e[1;33m Finished....Please Update Proxmox \e[0m"
systemctl restart pveproxy.service # for the no-nag

# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/post_install.sh)"
