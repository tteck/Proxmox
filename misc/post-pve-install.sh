#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

header_info() {
  clear
  cat <<"EOF"
    ____ _    _____________   ____             __     ____           __        ____
   / __ \ |  / / ____/__  /  / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
  / /_/ / | / / __/    / /  / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __  / / / 
 / ____/| |/ / /___   / /  / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /  
/_/     |___/_____/  /_/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/   
 
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

exit_script() {
  clear
  echo -e "⚠  User exited script \n"
  exit
}

start_routines() {
  header_info    
  CHOICE=$(
    whiptail --title "Proxmox VE 7 Post Install" --menu "\nDisable Enterprise Repository?" 11 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    exit_script
  fi
  case $CHOICE in
  yes)
    msg_info "Disabling Enterprise Repository"
    sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
    msg_ok "Disabled Enterprise Repository"
    ;;
  no)
    msg_error "Selected no to Disabling Enterprise Repository"
    ;;
  esac

  CHOICE=$(
    whiptail --title "Proxmox VE 7 Post Install" --menu "\nAdd/Correct PVE7 Sources (sources.list)?" 11 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    exit_script
  fi
  case $CHOICE in
  yes)
    msg_info "Adding or Correcting PVE7 Sources"
    cat <<EOF >/etc/apt/sources.list
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
EOF
    msg_ok "Added or Corrected PVE7 Sources"
    ;;
  no)
    msg_error "Selected no to Correcting PVE7 Sources"
    ;;
  esac

  CHOICE=$(
    whiptail --title "Proxmox VE 7 Post Install" --menu "\nEnable No-Subscription Repository?" 11 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    exit_script
  fi
  case $CHOICE in
  yes)
    msg_info "Enabling No-Subscription Repository"
    cat <<EOF >>/etc/apt/sources.list
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF
    msg_ok "Enabled No-Subscription Repository"
    ;;
  no)
    msg_error "Selected no to Enabling No-Subscription Repository"
    ;;
  esac

  CHOICE=$(
    whiptail --title "Proxmox VE 7 Post Install" --menu "\nAdd (Disabled) Beta/Test Repository?" 11 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    exit_script
  fi
  case $CHOICE in
  yes)
    msg_info "Adding Beta/Test Repository and set disabled"
    cat <<EOF >>/etc/apt/sources.list
# deb http://download.proxmox.com/debian/pve bullseye pvetest
EOF
    msg_ok "Added Beta/Test Repository"
    ;;
  no)
    msg_error "Selected no to Adding Beta/Test Repository"
    ;;
  esac

  CHOICE=$(
    whiptail --title "Proxmox VE 7 Post Install" --menu "\nDisable Subscription Nag?" 11 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    exit_script
  fi
  case $CHOICE in
  yes)
    msg_info "Disabling Subscription Nag"
    echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data\.status.*{/{s/\!//;s/active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" >/etc/apt/apt.conf.d/no-nag-script
    apt --reinstall install proxmox-widget-toolkit &>/dev/null
    msg_ok "Disabled Subscription Nag (Delete browser cache)"
    ;;
  no)
    msg_error "Selected no to Disabling Subscription Nag"
    ;;
  esac

  CHOICE=$(
    whiptail --title "Proxmox VE 7 Post Install" --menu "\nUpdate Proxmox VE 7 now?" 11 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    exit_script
  fi
  case $CHOICE in
  yes)
    msg_info "Updating Proxmox VE 7 (Patience)"
    apt-get update &>/dev/null
    apt-get -y dist-upgrade &>/dev/null
    msg_ok "Updated Proxmox VE 7 (Reboot Recommended)"
    ;;
  no)
    msg_error "Selected no to Updating Proxmox VE 7"
    ;;
  esac

  CHOICE=$(
    whiptail --title "Proxmox VE 7 Post Install" --menu "\nReboot Proxmox VE 7 now?" 11 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    exit_script
  fi
  case $CHOICE in
  yes)
    msg_info "Rebooting Proxmox VE 7"
    sleep 2
    msg_ok "Completed Post Install Routines"
    reboot
    ;;
  no)
    msg_error "Selected no to Rebooting Proxmox VE 7"
    msg_ok "Completed Post Install Routines"
    ;;
  esac
}

header_info
echo -e "\nThis script will Perform Post Install Routines.\n"
while true; do
  read -p "Start the PVE7 Post Install Script (y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit_script ;;
  *) echo "Please answer yes or no." ;;
  esac
done

if ! command -v pveversion >/dev/null 2>&1; then
  header_info
  msg_error "\n No PVE Detected!\n"
  exit
fi

if [ $(pveversion | grep "pve-manager/7" | wc -l) -ne 1 ]; then
  header_info
  msg_error "This version of Proxmox Virtual Environment is not supported"
  echo -e "  Requires PVE Version: 7.XX"
  echo -e "\nExiting..."
  sleep 3
  exit
fi

start_routines
