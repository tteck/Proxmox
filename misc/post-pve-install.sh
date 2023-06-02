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


start_routines() {
  header_info
  CHOICE=$(whiptail --title "PVE-ENTERPRISE" --menu "The 'pve-enterprise' repository is only available to users who have purchased a Proxmox VE subscription.\n \nDisable 'pve-enterprise' repository?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Disabling 'pve-enterprise' repository"
    sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
    msg_ok "Disabled 'pve-enterprise' repository"
    ;;
  no)
    msg_error "Selected no to Disabling 'pve-enterprise' repository"
    ;;
  esac

  CHOICE=$(whiptail --title "SOURCES" --menu "The package manager will use the correct sources to update and install packages on your Proxmox VE 7 server.\n \nCorrect Proxmox VE 7 sources?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Correcting Proxmox VE 7 Sources"
    cat <<EOF >/etc/apt/sources.list
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
EOF
    msg_ok "Corrected Proxmox VE 7 Sources"
    ;;
  no)
    msg_error "Selected no to Correcting Proxmox VE 7 Sources"
    ;;
  esac

  CHOICE=$(whiptail --title "PVE-NO-SUBSCRIPTION" --menu "The 'pve-no-subscription' repository provides access to all of the open-source components of Proxmox VE.\n \nEnable 'pve-no-subscription' repository?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Enabling 'pve-no-subscription' repository"
    cat <<EOF >>/etc/apt/sources.list
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF
    msg_ok "Enabled 'pve-no-subscription' repository"
    ;;
  no)
    msg_error "Selected no to Enabling 'pve-no-subscription' repository"
    ;;
  esac

  CHOICE=$(whiptail --title "PVETEST" --menu "The 'pvetest' repository can give advanced users access to new features and updates before they are officially released.\n \nAdd (Disabled) 'pvetest' repository?" 14 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Adding 'pvetest' repository and set disabled"
    cat <<EOF >>/etc/apt/sources.list
# deb http://download.proxmox.com/debian/pve bullseye pvetest
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
      msg_info "Disabling subscription nag"
      echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data\.status.*{/{s/\!//;s/active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" >/etc/apt/apt.conf.d/no-nag-script
      apt --reinstall install proxmox-widget-toolkit &>/dev/null
      msg_ok "Disabled subscription nag (Delete browser cache)"
      ;;
    no)
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

  CHOICE=$(whiptail --title "UPDATE" --menu "\nUpdate Proxmox VE 7 now?" 11 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Updating Proxmox VE 7 (Patience)"
    apt-get update &>/dev/null
    apt-get -y dist-upgrade &>/dev/null
    msg_ok "Updated Proxmox VE 7"
    ;;
  no)
    msg_error "Selected no to Updating Proxmox VE 7"
    ;;
  esac

  microcode=""
  if lscpu | grep -qP 'Vendor ID:.*GenuineIntel' && lscpu | grep -qP 'Model name:.*N'; then
      CHOICE=$(whiptail --title "N-SERIES PROCESSOR DETECTED" --menu "\nTo ensure compatibility with Proxmox VE on systems equipped with N-series processors, it is recommended to install the Proxmox 6.2 kernel.\n\nInstall the Proxmox 6.2 kernel now?" 16 58 2 \
        "yes" " " \
        "no" " " 3>&1 1>&2 2>&3)
      case $CHOICE in
      yes)
        msg_info "Installing Proxmox 6.2 kernel"
        apt-get install -y pve-kernel-6.2 &>/dev/null
        microcode="need"
        msg_ok "Installed Proxmox 6.2 kernel"
        ;;
      no)
        msg_error "Selected no to Installing the Proxmox 6.2 kernel"
        ;;
      esac
  fi

  if [ "$microcode" == "need" ]; then
    CHOICE=$(whiptail --title "INTEL MICROCODE" --menu "\nMicrocode updates can fix hardware bugs, improve performance, and enhance security features of the processor.\n\nInstall the Intel Microcode now?" 16 58 2 \
      "yes" " " \
      "no" " " 3>&2 2>&1 1>&3)
    case $CHOICE in
    yes)
      msg_info "Installing Intel Microcode"
      apt-get install -y iucode-tool &>/dev/null
      wget -q http://ftp.debian.org/debian/pool/non-free-firmware/i/intel-microcode/intel-microcode_3.20230512.1_amd64.deb
      dpkg -i intel-microcode_3.20230512.1_amd64.deb &>/dev/null
      rm intel-microcode_3.20230512.1_amd64.deb
      msg_ok "Installed Intel Microcode"
      ;;
    no)
      msg_error "Selected no to Installing the Intel Microcode"
      ;;
    esac
  fi

  CHOICE=$(whiptail --title "REBOOT" --menu "\nReboot Proxmox VE 7 now? (recommended)" 11 58 2 \
    "yes" " " \
    "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Rebooting Proxmox VE 7"
    sleep 2
    msg_ok "Completed Post Install Routines"
    reboot
    ;;
  no)
    msg_error "Selected no to Rebooting Proxmox VE 7 (Reboot recommended)"
    msg_ok "Completed Post Install Routines"
    ;;
  esac
}

header_info
echo -e "\nThis script will Perform Post Install Routines.\n"
while true; do
  read -p "Start the Proxmox VE 7 Post Install Script (y/n)?" yn
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

if [ $(pveversion | grep "pve-manager/7" | wc -l) -ne 1 ]; then
  header_info
  msg_error "This version of Proxmox Virtual Environment is not supported"
  echo -e "  Requires PVE Version: 7.XX"
  echo -e "\nExiting..."
  sleep 3
  exit
fi

start_routines
