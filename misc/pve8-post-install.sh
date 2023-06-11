#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

header_info() {
  clear
  cat <<"EOF"
    ____ _    ____________     ____             __     ____           __        ____
   / __ \ |  / / ____( __ )   / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
  / /_/ / | / / __/ / __  |  / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __ `/ / /
 / ____/| |/ / /___/ /_/ /  / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /
/_/     |___/_____/\____/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/

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

  CHOICE=$(whiptail --title "SOURCES" --menu "The package manager will use the correct sources to update and install packages on your Proxmox VE 8 server.\n \nCorrect Proxmox VE 8 sources?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Correcting Proxmox VE 8 Sources"
    cat <<EOF >/etc/apt/sources.list
deb http://ftp.debian.org/debian bookworm main contrib
deb http://ftp.debian.org/debian bookworm-updates main contrib
deb http://security.debian.org/debian-security bookworm-security main contrib
EOF
    msg_ok "Corrected Proxmox VE 8 Sources"
    ;;
  no)
    msg_error "Selected no to Correcting Proxmox VE 8 Sources"
    ;;
  esac

  CHOICE=$(whiptail --title "PVE-ENTERPRISE" --menu "The 'pve-enterprise' repository is only available to users who have purchased a Proxmox VE subscription.\n \nDisable 'pve-enterprise' repository?" 14 58 2 \
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

  CHOICE=$(whiptail --title "PVE-NO-SUBSCRIPTION" --menu "The 'pve-no-subscription' repository provides access to all of the open-source components of Proxmox VE.\n \nEnable 'pve-no-subscription' repository?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Enabling 'pve-no-subscription' repository"
    cat <<EOF >/etc/apt/sources.list.d/pve-install-repo.list
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
EOF
    msg_ok "Enabled 'pve-no-subscription' repository"
    ;;
  no)
    msg_error "Selected no to Enabling 'pve-no-subscription' repository"
    ;;
  esac

  CHOICE=$(whiptail --title "CEPH PACKAGE REPOSITORIES" --menu "The 'Ceph Package Repositories' provides access to both the 'no-subscription' and 'enterprise' repositories.\n \nEnable 'ceph package repositories?" 14 58 2 \
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

  CHOICE=$(whiptail --title "PVETEST" --menu "The 'pvetest' repository can give advanced users access to new features and updates before they are officially released.\n \nAdd (Disabled) 'pvetest' repository?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Adding 'pvetest' repository and set disabled"
    cat <<EOF >/etc/apt/sources.list.d/pvetest-for-beta.list
# deb http://download.proxmox.com/debian/pve bookworm pvetest
EOF
    msg_ok "Added 'pvetest' repository"
    ;;
  no)
    msg_error "Selected no to Adding 'pvetest' repository"
    ;;
  esac

  if [[ ! -f /etc/apt/apt.conf.d/no-nag-script ]]; then
    CHOICE=$(whiptail --title "SUBSCRIPTION NAG" --menu "This will disable the nag message reminding you to purchase a subscription every time you log in to the web interface.\n \nDisable subscription nag?" 14 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3)
    case $CHOICE in
    yes)
      whiptail --msgbox --title "Support Subscriptions" "Supporting the software's development team is essential. Check their official website's Support Subscriptions for pricing. Without their dedicated work, we wouldn't have this exceptional software." 10 58
      msg_info "Disabling subscription nag"
      echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data\.status.*{/{s/\!//;s/active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" >/etc/apt/apt.conf.d/no-nag-script
      apt --reinstall install proxmox-widget-toolkit &>/dev/null
      msg_ok "Disabled subscription nag (Delete browser cache)"
      ;;
    no)
      whiptail --msgbox --title "Support Subscriptions" "Supporting the software's development team is essential. Check their official website's Support Subscriptions for pricing. Without their dedicated work, we wouldn't have this exceptional software." 10 58
      msg_error "Selected no to Disabling subscription nag"
      ;;
    esac
  fi

  if systemctl is-active --quiet pve-ha-lrm; then
    CHOICE=$(whiptail --title "HIGH AVAILABILITY" --menu "If you plan to utilize a single node instead of a clustered environment, you can disable unnecessary high availability (HA) services, thus reclaiming system resources.\n\nIf HA becomes necessary at a later stage, the services can be re-enabled.\n\nDisable high availability?" 18 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3)
    case $CHOICE in
    yes)
      msg_info "Disabling high availability"
      systemctl stop pve-ha-lrm
      systemctl disable pve-ha-lrm &>/dev/null
      systemctl stop pve-ha-crm
      systemctl disable pve-ha-crm &>/dev/null
      systemctl stop corosync
      systemctl disable corosync &>/dev/null
      msg_ok "Disabled high availability"
      ;;
    no)
      msg_error "Selected no to Disabling high availability"
      ;;
    esac
  fi

  CHOICE=$(whiptail --title "UPDATE" --menu "\nUpdate Proxmox VE 8 now?" 11 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Updating Proxmox VE 8 (Patience)"
    apt-get update &>/dev/null
    apt-get -y dist-upgrade &>/dev/null
    msg_ok "Updated Proxmox VE 8"
    ;;
  no)
    msg_error "Selected no to Updating Proxmox VE 8"
    ;;
  esac

  CHOICE=$(whiptail --title "REBOOT" --menu "\nReboot Proxmox VE 8 now? (recommended)" 11 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Rebooting Proxmox VE 8"
    sleep 2
    msg_ok "Completed Post Install Routines"
    reboot
    ;;
  no)
    msg_error "Selected no to Rebooting Proxmox VE 8 (Reboot recommended)"
    msg_ok "Completed Post Install Routines"
    ;;
  esac
}

header_info
echo -e "\nThis script will Perform Post Install Routines.\n"
while true; do
  read -p "Start the Proxmox VE 8 Post Install Script (y/n)?" yn
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

if [ $(pveversion | grep "pve-manager/8" | wc -l) -ne 1 ]; then
  header_info
  msg_error "This version of Proxmox Virtual Environment is not supported"
  echo -e "  Requires PVE Version: 8.XX"
  echo -e "\nExiting..."
  sleep 3
  exit
fi

start_routines
