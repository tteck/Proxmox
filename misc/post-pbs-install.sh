#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

set -euo pipefail
shopt -s inherit_errexit nullglob
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
BGN=$(echo "\033[4;92m")
GN=$(echo "\033[1;92m")
DGN=$(echo "\033[32m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
clear
echo -e "${BL}This script will Perform Post Install Routines.${CL}"
while true; do
    read -p "Start the PBS Post Install Script (y/n)?" yn
    case $yn in
    [Yy]*) break ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
done

if command -v pveversion >/dev/null 2>&1; then
    echo -e "\n🛑  PVE Detected, Wrong Script!\n"
    exit 1
fi

function header_info {
    cat <<"EOF"
    ____  ____ _____    ____             __     ____           __        ____
   / __ \/ __ ) ___/   / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
  / /_/ / __  \__ \   / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __ `/ / / 
 / ____/ /_/ /__/ /  / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /  
/_/   /_____/____/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/   
                                                                             
EOF
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

clear
header_info
read -r -p "Disable Enterprise Repository? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
    msg_info "Disabling Enterprise Repository"
    sleep 2
    sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/pbs-enterprise.list
    msg_ok "Disabled Enterprise Repository"
fi

read -r -p "Add/Correct PBS Sources (sources.list)? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
    msg_info "Adding or Correcting PBS Sources"
    cat <<EOF >/etc/apt/sources.list
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
EOF
    sleep 2
    msg_ok "Added or Corrected PBS Sources"
fi

read -r -p "Enable No-Subscription Repository? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
    msg_info "Enabling No-Subscription Repository"
    cat <<EOF >>/etc/apt/sources.list
deb http://download.proxmox.com/debian/pbs bullseye pbs-no-subscription
EOF
    sleep 2
    msg_ok "Enabled No-Subscription Repository"
fi

read -r -p "Add (Disabled) Beta/Test Repository? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
    msg_info "Adding Beta/Test Repository and set disabled"
    cat <<EOF >>/etc/apt/sources.list
# deb http://download.proxmox.com/debian/pbs bullseye pbstest
EOF
    sleep 2
    msg_ok "Added Beta/Test Repository"
fi

read -r -p "Disable Subscription Nag? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
    msg_info "Disabling Subscription Nag"
    echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" >/etc/apt/apt.conf.d/no-nag-script
    apt --reinstall install proxmox-widget-toolkit &>/dev/null
    msg_ok "Disabled Subscription Nag"
fi

read -r -p "Update Proxmox Backup Server now? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
    msg_info "Updating Proxmox Backup Server (Patience)"
    apt-get update &>/dev/null
    apt-get -y dist-upgrade &>/dev/null
    msg_ok "Updated Proxmox Backup Server (⚠ Reboot Recommended)"
fi

read -r -p "Reboot Proxmox Backup Server now? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
    msg_info "Rebooting Proxmox Backup Server"
    sleep 2
    msg_ok "Completed Post Install Routines"
    reboot
fi

sleep 2
msg_ok "Completed Post Install Routines"
