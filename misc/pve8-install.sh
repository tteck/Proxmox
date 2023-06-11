#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

header_info() {
  clear
  cat <<"EOF"
    ____ _    ____________     ____           __        ____
   / __ \ |  / / ____( __ )   /  _/___  _____/ /_____ _/ / /
  / /_/ / | / / __/ / __  |   / // __ \/ ___/ __/ __ `/ / /
 / ____/| |/ / /___/ /_/ /  _/ // / / (__  ) /_/ /_/ / / /
/_/     |___/_____/\____/  /___/_/ /_/____/\__/\__,_/_/_/

EOF
}

RD=$(echo "\033[01;31m")
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

set -euo pipefail
shopt -s inherit_errexit nullglob

msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}


start_routines() {
  header_info

  CHOICE=$(whiptail --title "PVE8 SOURCES" --menu "This will set the correct sources to update and install Proxmox VE 8.\n \nChange to Proxmox VE 8 sources?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Changing to Proxmox VE 8 Sources"
    cat <<EOF >/etc/apt/sources.list
deb http://ftp.debian.org/debian bookworm main contrib
deb http://ftp.debian.org/debian bookworm-updates main contrib
deb http://security.debian.org/debian-security bookworm-security main contrib
EOF
    msg_ok "Changed to Proxmox VE 8 Sources"
    ;;
  no)
    msg_error "Selected no to Correcting Proxmox VE 8 Sources"
    ;;
  esac

  CHOICE=$(whiptail --title "PVE8-ENTERPRISE" --menu "The 'pve-enterprise' repository is only available to users who have purchased a Proxmox VE subscription.\n \nDisable 'pve-enterprise' repository?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Disabling 'pve-enterprise' repository"
    cat <<EOF >/etc/apt/sources.list.d/pve-enterprise.list
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
EOF
    msg_ok "Disabled 'pve-enterprise' repository"
    ;;
  no)
    msg_error "Selected no to Disabling 'pve-enterprise' repository"
    ;;
  esac

  CHOICE=$(whiptail --title "PVE8-NO-SUBSCRIPTION" --menu "The 'pve-no-subscription' repository provides access to all of the open-source components of Proxmox VE.\n \nEnable 'pve-no-subscription' repository?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Enabling 'pve-no-subscription' repository"
    cat <<EOF >/etc/apt/sources.list.d/pve-install-repo.list
# deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
EOF
    msg_ok "Enabled 'pve-no-subscription' repository"
    ;;
  no)
    msg_error "Selected no to Enabling 'pve-no-subscription' repository"
    ;;
  esac

  CHOICE=$(whiptail --title "PVE8 CEPH PACKAGE REPOSITORIES" --menu "The 'Ceph Package Repositories' provides access to both the 'no-subscription' and 'enterprise' repositories.\n \nEnable 'ceph package repositories?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Enabling 'ceph package repositories'"
    cat <<EOF >/etc/apt/sources.list.d/ceph.list
# deb http://download.proxmox.com/debian/ceph-quincy bookworm enterprise
deb http://download.proxmox.com/debian/ceph-quincy bookworm no-subscription
EOF
    msg_ok "Enabled 'ceph package repositories'"
    ;;
  no)
    msg_error "Selected no to Enabling 'ceph package repositories'"
    ;;
  esac

  CHOICE=$(whiptail --title "PVE8 TEST" --menu "The 'pvetest' repository can give advanced users access to new features and updates before they are officially released.\n \nAdd 'pvetest' repository?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Adding 'pvetest' repository and set disabled"
    cat <<EOF >/etc/apt/sources.list.d/pvetest-for-beta.list
deb http://download.proxmox.com/debian/pve bookworm pvetest
EOF
    msg_ok "Added 'pvetest' repository"
    ;;
  no)
    msg_error "Selected no to Adding 'pvetest' repository"
    ;;
  esac

  CHOICE=$(whiptail --title "PVE8 UPDATE" --menu "\nUpdate to Proxmox VE 8 now?" 11 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Updating to Proxmox VE 8 (Patience)"
    apt-get update
    apt-get -y dist-upgrade
    msg_ok "Updated to Proxmox VE 8"
    ;;
  no)
    msg_error "Selected no to Updating to Proxmox VE 8"
    ;;
  esac

  CHOICE=$(whiptail --title "REBOOT" --menu "\nReboot Proxmox VE 8 now? (recommended)" 11 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Rebooting Proxmox VE 8"
    sleep 2
    msg_ok "Completed Install Routines"
    reboot
    ;;
  no)
    msg_error "Selected no to Rebooting Proxmox VE 8 (Reboot recommended)"
    msg_ok "Completed Install Routines"
    ;;
  esac
}

header_info
while true; do
  read -p "Start the Update to Proxmox VE 8 Script (y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) clear; exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

if ! command -v pveversion >/dev/null 2>&1; then
  header_info
  msg_error "\n No PVE Detected!\n"
  exit
fi

if [ $(pveversion | grep "pve-manager/7.4-13" | wc -l) -ne 1 ]; then
  header_info
  msg_error "This version of Proxmox Virtual Environment is not supported"
  echo -e "  Requires PVE Version: 7.4-13"
  echo -e "\nExiting..."
  sleep 3
  exit
fi

start_routines
