#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)

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

function select_storage() {
  local CLASS=$1
  local CONTENT
  local CONTENT_LABEL
  case $CLASS in
    container)
      CONTENT='rootdir'
      CONTENT_LABEL='Container'
      ;;
    template)
      CONTENT='vztmpl'
      CONTENT_LABEL='Container template'
      ;;
    *) false || die "Invalid storage class." ;;
  esac

  # Query all storage locations
  local -a MENU
  while read -r line; do
    local TAG=$(echo $line | awk '{print $1}')
    local TYPE=$(echo $line | awk '{printf "%-10s", $2}')
    local FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | awk '{printf( "%9sB", $6)}')
    local ITEM="  Type: $TYPE Free: $FREE "
    local OFFSET=2
    if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
      local MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
    fi
    MENU+=("$TAG" "$ITEM" "OFF")
  done < <(pvesm status -content $CONTENT | awk 'NR>1')

  # Select storage location
  if [ $((${#MENU[@]} / 3)) -eq 0 ]; then
    warn "'$CONTENT_LABEL' needs to be selected for at least one storage location."
    die "Unable to detect valid storage location."
  elif [ $((${#MENU[@]} / 3)) -eq 1 ]; then
    printf ${MENU[0]}
  else
    local STORAGE
    while [ -z "${STORAGE:+x}" ]; do
      STORAGE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Storage Pools" --radiolist \
        "Which storage pool you would like to use for the ${CONTENT_LABEL,,}?\n\n" \
        16 $(($MSG_MAX_LENGTH + 23)) 6 \
        "${MENU[@]}" 3>&1 1>&2 2>&3) || die "Menu aborted."
    done
    printf $STORAGE
  fi
}

function default_settings() {
  CT_TYPE="1"
  CT_ID=$NEXTID
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  PW=""
  
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
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Invalid IP address format. Please enter a valid IPv4 CIDR address" 8 58
    fi
  done
  
  # Ask for gateway
  while true; do
    GATE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Enter the gateway IP address" 8 58 --title "Gateway IP" 3>&1 1>&2 2>&3)
    if [[ "$GATE" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      break
    else
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Invalid gateway IP format. Please enter a valid IPv4 address" 8 58
    fi
  done

  # Ask for storage location for template
  TEMPLATE_STORAGE=$(select_storage "template")

  # Ask for storage location for CT disk
  DISK_STORAGE=$(select_storage "container")

  echo_default
}

function advanced_settings() {
  whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox --title "Here is an instructional tip:" "To make a selection, use the Spacebar." 8 58
  
  CT_TYPE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "CONTAINER TYPE" --radiolist "Choose Type" 10 58 2 \
    "1" "Unprivileged" ON \
    "0" "Privileged" OFF \
    3>&1 1>&2 2>&3)
  while true; do
    PW1=$(whiptail --backtitle "Proxmox VE Helper Scripts" --passwordbox "\nSet Root Password (needed for root ssh access)" 9 58 --title "PASSWORD" 3>&1 1>&2 2>&3)
    PW2=$(whiptail --backtitle "Proxmox VE Helper Scripts" --passwordbox "\nVerify Root Password" 9 58 --title "PASSWORD VERIFICATION" 3>&1 1>&2 2>&3)
  
    if [ ${#PW1} -lt 6 ]; then
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Password must be at least 6 characters long." 8 58
    elif [ "$PW1" != "$PW2" ]; then
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Passwords do not match." 8 58
    else
      PW="$PW1"
      break
    fi
  done
  
  CT_ID=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Container ID" 8 58 $NEXTID --title "CONTAINER ID" 3>&1 1>&2 2>&3)
  
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
  
  DISK_SIZE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Disk Size in GB" 8 58 $var_disk --title "DISK SIZE" 3>&1 1>&2 2>&3)
  CORE_COUNT=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Allocate CPU Cores" 8 58 $var_cpu --title "CORE COUNT" 3>&1 1>&2 2>&3)
  
  while true; do
    RAM_SIZE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Allocate RAM in MiB (minimum 1537)" 8 58 $var_ram --title "RAM" 3>&1 1>&2 2>&3)
    if [[ "$RAM_SIZE" =~ ^[0-9]+$ ]] && [ "$RAM_SIZE" -gt 1536 ]; then
      break
    else
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Invalid RAM size. Please enter a number greater than 1536." 8 58
    fi
  done
  
  BRG=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a Bridge" 8 58 vmbr0 --title "BRIDGE" 3>&1 1>&2 2>&3)

  while true; do
    NET=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a Static IPv4 CIDR Address (/24) or 'dhcp'" 8 58 dhcp --title "IP ADDRESS" 3>&1 1>&2 2>&3)
    if [ "$NET" = "dhcp" ]; then
      break
    elif [[ "$NET" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$ ]]; then
      break
    else
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox "Invalid IP address format. Please enter a valid IPv4 CIDR address or 'dhcp'" 8 58
    fi
  done

  GATE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a Gateway IP (leave blank for default)" 8 58 --title "GATEWAY IP" 3>&1 1>&2 2>&3)
  
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "IPv6" --yesno "Disable IPv6?" 10 58); then
    DISABLEIP6="yes"
  else
    DISABLEIP6="no"
  fi
  
  MTU=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set Interface MTU Size (leave blank for default)" 8 58 --title "MTU SIZE" 3>&1 1>&2 2>&3)
  SD=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a DNS Search Domain (leave blank for HOST)" 8 58 --title "DNS Search Domain" 3>&1 1>&2 2>&3)
  NS=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a DNS Server IP (leave blank for HOST)" 8 58 --title "DNS SERVER IP" 3>&1 1>&2 2>&3)
  MAC=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a MAC Address (leave blank for default)" 8 58 --title "MAC ADDRESS" 3>&1 1>&2 2>&3)
  VLAN=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set a VLAN Tag (leave blank for default)" 8 58 --title "VLAN" 3>&1 1>&2 2>&3)
  
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "SSH ACCESS" --yesno "Enable Root SSH Access?" 10 58); then
    SSH="yes"
  else
    SSH="no"
  fi
  
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "VERBOSE MODE" --yesno "Enable Verbose Mode?" 10 58); then
    VERB="yes"
  else
    VERB="no"
  fi
  
  # Ask for storage location for template
  TEMPLATE_STORAGE=$(select_storage "template")

  # Ask for storage location for CT disk
  DISK_STORAGE=$(select_storage "container")
  
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "ADVANCED SETTINGS COMPLETE" --yesno "Ready to create ${APP} LXC?" 10 58); then
    echo -e "${RD}Creating a ${APP} LXC using the above advanced settings${CL}"
  else
    clear
    header_info
    echo -e "${RD}Using Advanced Settings${CL}"
    advanced_settings
  fi
}

# Override the build_container function
function build_container() {
  if [ "$CT_TYPE" == "1" ]; then
    FEATURES="keyctl=1,nesting=1"
  else
    FEATURES="nesting=1"
  fi

  TEMP_DIR=$(mktemp -d)
  pushd $TEMP_DIR >/dev/null

  export CTID="$CT_ID"
  export PCT_OSTYPE="$var_os"
  export PCT_OSVERSION="$var_version"
  export PCT_DISK_SIZE="$DISK_SIZE"

  # Format the network configuration
  NET_CONFIG="name=eth0,bridge=$BRG,ip=$NET,gw=$GATE"

  export PCT_OPTIONS="
    -features $FEATURES
    -hostname $CT_NAME
    -tags proxmox-helper-scripts
    $SD
    $NS
    -net0 $NET_CONFIG
    -onboot 1
    -cores $CORE_COUNT
    -memory $RAM_SIZE
    -unprivileged $CT_TYPE
    -password $PW
  "

  msg_info "Updating LXC template list"
  pveam update >/dev/null
  msg_ok "Updated LXC template list"

  msg_info "Downloading CentOS 9 Stream LXC template"
  pveam download $TEMPLATE_STORAGE centos-9-stream-default_20240828_amd64.tar.xz >/dev/null
  msg_ok "Downloaded CentOS 9 Stream LXC template"

  msg_info "Creating LXC Container"
  pct create $CTID ${TEMPLATE_STORAGE}:vztmpl/centos-9-stream-default_20240828_amd64.tar.xz \
    -storage $DISK_STORAGE \
    $PCT_OPTIONS >/dev/null
  msg_ok "Created LXC Container"

  msg_info "Starting LXC Container"
  pct start $CTID >/dev/null
  msg_ok "Started LXC Container"

  msg_info "Waiting for container to finish startup"
  sleep 5
  msg_ok "Container started"

  popd >/dev/null
}

function install_freeipa() {
  local redirect=""
  if [ "$VERB" != "yes" ]; then
    redirect=">/dev/null 2>&1"
  fi

  msg_info "Updating Container OS"
  eval pct exec $CTID -- dnf update -y $redirect
  msg_ok "Updated Container OS"

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
