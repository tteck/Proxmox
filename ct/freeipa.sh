#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/install.func) # Can be removed after proper freeipa_intall.sh implementation

function header_info {
clear
cat <<"EOF"
    ______              _____ ____  _ ___
   / ____/_______  ___  /  _/ / __ \//   |
  / /_  / ___/ _ \/ _ \ / // / /_/ // /| |
 / __/ / /  /  __/  __// // / ____// ___ |
/_/   /_/   \___/\___/___/_/_/    /_/  |_|

EOF
}
header_info
echo -e "Loading..."
APP="FreeIPA"
var_disk="8"
var_cpu="2"
var_ram="2048"
var_os="centos"
var_version="9"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  
  # Ask for full hostname (including domain) and validate domain
  while true; do
    CT_NAME=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Enter the full hostname (e.g., freeipa.example.com)" 8 58 --title "HOSTNAME" 3>&1 1>&2 2>&3)
    DOMAIN=$(echo "$CT_NAME" | cut -d. -f2-)
    if [[ "$DOMAIN" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
      local tld=$(echo "$DOMAIN" | rev | cut -d. -f1 | rev)
      if [[ ! "$tld" =~ ^[0-9]+$ ]]; then
        break
      fi
    fi
    whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Invalid domain format. Please use a fully qualified domain name (e.g., example.com, sub.example.com)." 8 58
  done

  # Ask for static IP
  while true; do
    NET=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a Static IPv4 CIDR Address (e.g., 192.168.1.100/24)" 8 58 --title "IP ADDRESS" 3>&1 1>&2 2>&3)
    if [[ "$NET" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$ ]]; then
      break
    else
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "$NET is an invalid IPv4 CIDR address. Please enter a valid IPv4 CIDR address" 8 58
    fi
  done

  # Ask for gateway
  while true; do
    GATE1=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Enter gateway IP address" 8 58 --title "Gateway IP" 3>&1 1>&2 2>&3)
    if [ -z "$GATE1" ]; then
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Gateway IP address cannot be empty" 8 58
    elif [[ ! "$GATE1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Invalid IP address format" 8 58
    else
      GATE=",gw=$GATE1"
      echo -e "${DGN}Using Gateway IP Address: ${BGN}$GATE1${CL}"
      break
    fi
  done
 
 echo_default
}

function install_freeipa() {
  local redirect=""
  if [ "$VERB" != "yes" ]; then
    redirect=">/dev/null 2>&1"
  fi

  msg_info "Updating Container OS"
  eval pct exec $CTID -- dnf update -y $redirect
  msg_ok "Updated Container OS"
  
motd_ssh
  customize

  msg_info "Installing FreeIPA Server"
  eval pct exec $CTID -- dnf install -y freeipa-server freeipa-server-dns $redirect
  msg_ok "Installed FreeIPA Server"

  msg_info "Configuring FreeIPA"
  
  SERVER_NAME=$(echo "$CT_NAME" | cut -d. -f1)
  REALM=$(echo "${DOMAIN}" | tr '[:lower:]' '[:upper:]')
  
  eval pct exec $CTID -- hostnamectl set-hostname $CT_NAME $redirect
  eval pct exec $CTID -- bash -c "'echo '127.0.0.1 $CT_NAME $SERVER_NAME' >> /etc/hosts'" $redirect
  
  eval pct exec $CTID -- ipa-server-install \
    --realm=$REALM \
    --domain=$DOMAIN \
    --ds-password="changeme" \
    --admin-password="changeme" \
    --hostname=$CT_NAME \
    --setup-dns \
    --no-forwarders \
    --no-ntp \
    --unattended $redirect
  
  if [ $? -ne 0 ]; then
    msg_error "FreeIPA installation failed. Please check the logs in the container at /var/log/ipaserver-install.log"
    exit 1
  fi
  
  msg_ok "Configured FreeIPA"

  msg_info "Starting FreeIPA services"
  eval pct exec $CTID -- systemctl enable --now ipa $redirect
  msg_ok "Started FreeIPA services"
}

start
build_container
description
install_freeipa

msg_ok "Completed Successfully!\n"
echo -e "${APP} should now be setup and reachable by going to the following URL.
         ${BL}https://${CT_NAME}${CL} \n"
echo -e "FreeIPA admin password: ${BL}$DEFAULT_PW${CL}"
echo -e "It's highly recommended to change this password immediately after your first login.\n"
echo -e "To change the admin password, follow these steps:"
echo -e "1. SSH into the FreeIPA container: ${BL}pct enter $CTID${CL}"
echo -e "2. Authenticate as the admin user: ${BL}kinit admin${CL}"
echo -e "3. Change the password: ${BL}ipa passwd admin${CL}"
echo -e "4. Follow the prompts to set a new, strong password.\n"
echo -e "Remember to update any services or clients that may be using the admin account.\n"
