#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  cat <<"EOF"
    __  ____ __              __  _ __      ____              __            ____  _____
   /  |/  (_) /___________  / /_(_) /__   / __ \____  __  __/ /____  _____/ __ \/ ___/
  / /|_/ / / //_/ ___/ __ \/ __/ / //_/  / /_/ / __ \/ / / / __/ _ \/ ___/ / / /\__ \ 
 / /  / / /  < / /  / /_/ / /_/ /  <    / _  _/ /_/ / /_/ / /_/  __/ /  / /_/ /___/ / 
/_/  /_/_/_/|_/_/   \____/\__/_/_/|_|  /_/ |_|\____/\__,_/\__/\___/_/   \____//____/  
 
EOF
}
clear
header_info
echo -e "Loading..."
GEN_MAC=$(echo '00 60 2f'$(od -An -N3 -t xC /dev/urandom) | sed -e 's/ /:/g' | tr '[:lower:]' '[:upper:]')
NEXTID=$(pvesh get /cluster/nextid)
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
HA=$(echo "\033[1;34m")
RD=$(echo "\033[01;31m")
BGN=$(echo "\033[4;92m")
GN=$(echo "\033[1;92m")
DGN=$(echo "\033[32m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
trap cleanup EXIT
function error_exit() {
  trap - ERR
  local reason="Unknown failure occurred."
  local msg="${1:-$reason}"
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  [ ! -z ${VMID-} ] && cleanup_vmid
  exit $EXIT
}
function cleanup_vmid() {
  if $(qm status $VMID &>/dev/null); then
    if [ "$(qm status $VMID | awk '{print $2}')" == "running" ]; then
      qm stop $VMID
    fi
    qm destroy $VMID
  fi
}
function cleanup() {
  popd >/dev/null
  rm -rf $TEMP_DIR
}
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null
if [ $(pveversion | grep "pve-manager/7" | wc -l) -ne 1 ]; then
  echo "⚠ This version of Proxmox Virtual Environment is not supported"
  echo "Requires PVE Version: 7.XX"
  echo "Exiting..."
  sleep 3
  exit
fi
if (whiptail --title "Mikrotik RouterOS VM" --yesno "This will create a New Mikrotik RouterOS VM. Proceed?" 10 58); then
  echo "User selected Yes"
else
  clear
  echo -e "⚠ User exited script \n"
  exit
fi

function msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}
function msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}
function default_settings() {
  echo -e "${DGN}Using Virtual Machine ID: ${BGN}$NEXTID${CL}"
  VMID=$NEXTID
  echo -e "${DGN}Using Hostname: ${BGN}mikrotik-routeros${CL}"
  HN=mikrotik-routeros
  echo -e "${DGN}Allocated Cores: ${BGN}1${CL}"
  CORE_COUNT="1"
  echo -e "${DGN}Allocated RAM: ${BGN}1024${CL}"
  RAM_SIZE="1024"
  echo -e "${DGN}Using Bridge: ${BGN}vmbr0${CL}"
  BRG="vmbr0"
  echo -e "${DGN}Using MAC Address: ${BGN}$GEN_MAC${CL}"
  MAC=$GEN_MAC
  echo -e "${DGN}Using VLAN: ${BGN}Default${CL}"
  VLAN=""
  echo -e "${DGN}Using Interface MTU Size: ${BGN}Default${CL}"
  MTU=""
  echo -e "${DGN}Start VM when completed: ${BGN}no${CL}"
  START_VM="no"
  echo -e "${BL}Creating a Mikrotik RouterOS VM using the above default settings${CL}"
}
function advanced_settings() {
  VMID=$(whiptail --inputbox "Set Virtual Machine ID" 8 58 $NEXTID --title "VIRTUAL MACHINE ID" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Using Virtual Machine ID: ${BGN}$VMID${CL}"
  else
    exit
  fi
  VM_NAME=$(whiptail --inputbox "Set Hostname" 8 58 Mikrotik-RouterOS --title "HOSTNAME" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    HN=$(echo ${VM_NAME,,} | tr -d ' ')
    echo -e "${DGN}Using Hostname: ${BGN}$HN${CL}"
  else
    exit
  fi
  CORE_COUNT=$(whiptail --inputbox "Allocate CPU Cores" 8 58 1 --title "CORE COUNT" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}"
  else
    exit
  fi
  RAM_SIZE=$(whiptail --inputbox "Allocate RAM in MiB" 8 58 1024 --title "RAM" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}"
  else
    exit
  fi
  BRG=$(whiptail --inputbox "Set a Bridge" 8 58 vmbr0 --title "BRIDGE" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}"
  else
    exit
  fi
  MAC1=$(whiptail --inputbox "Set a MAC Address" 8 58 $GEN_MAC --title "MAC ADDRESS" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    MAC="$MAC1"
    echo -e "${DGN}Using MAC Address: ${BGN}$MAC1${CL}"
  else
    exit
  fi
  VLAN1=$(whiptail --inputbox "Set a Vlan(leave blank for default)" 8 58 --title "VLAN" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    if [ -z $VLAN1 ]; then
      VLAN1="Default" VLAN=""
      echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
    else
      VLAN=",tag=$VLAN1"
      echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
    fi
  fi
  MTU1=$(whiptail --inputbox "Set Interface MTU Size (leave blank for default)" 8 58 --title "MTU SIZE" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    if [ -z $MTU1 ]; then
      MTU1="Default" MTU=""
      echo -e "${DGN}Using Interface MTU Size: ${BGN}$MTU1${CL}"
    else
      MTU=",mtu=$MTU1"
      echo -e "${DGN}Using Interface MTU Size: ${BGN}$MTU1${CL}"
    fi
  fi
  if (whiptail --title "START VIRTUAL MACHINE" --yesno "Start Mikrotik RouterOS VM when completed?" 10 58); then
    echo -e "${DGN}Start Mikrotik RouterOS VM when completed: ${BGN}yes${CL}"
    START_VM="yes"
  else
    echo -e "${DGN}Start Mikrotik RouterOS VM when completed: ${BGN}no${CL}"
    START_VM="no"
  fi
  if (whiptail --title "ADVANCED SETTINGS COMPLETE" --yesno "Ready to create Mikrotik RouterOS VM?" 10 58); then
    echo -e "${RD}Creating Mikrotik RouterOS VM using the above advanced settings${CL}"
  else
    clear
    header_info
    echo -e "${RD}Using Advanced Settings${CL}"
    advanced_settings
  fi
}
function start_script() {
  if (whiptail --title "SETTINGS" --yesno "Use Default Settings?" 10 58); then
    clear
    header_info
    echo -e "${BL}Using Default Settings${CL}"
    default_settings
  else
    clear
    header_info
    echo -e "${RD}Using Advanced Settings${CL}"
    advanced_settings
  fi
}
start_script
msg_info "Validating Storage"
while read -r line; do
  TAG=$(echo $line | awk '{print $1}')
  TYPE=$(echo $line | awk '{printf "%-10s", $2}')
  FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | awk '{printf( "%9sB", $6)}')
  ITEM="  Type: $TYPE Free: $FREE "
  OFFSET=2
  if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
    MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
  fi
  STORAGE_MENU+=("$TAG" "$ITEM" "OFF")
done < <(pvesm status -content images | awk 'NR>1')
VALID=$(pvesm status -content images | awk 'NR>1')
if [ -z "$VALID" ]; then
  echo -e "\n${RD}⚠ Unable to detect a valid storage location.${CL}"
  echo -e "Exiting..."
  exit
elif [ $((${#STORAGE_MENU[@]} / 3)) -eq 1 ]; then
  STORAGE=${STORAGE_MENU[0]}
else
  while [ -z "${STORAGE:+x}" ]; do
    STORAGE=$(whiptail --title "Storage Pools" --radiolist \
      "Which storage pool you would like to use for the Mikrotik RouterOS VM?\n\n" \
      16 $(($MSG_MAX_LENGTH + 23)) 6 \
      "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit
  done
fi
msg_ok "Using ${CL}${BL}$STORAGE${CL} ${GN}for Storage Location."
msg_ok "Virtual Machine ID is ${CL}${BL}$VMID${CL}."
msg_info "Getting URL for Mikrotik RouterOS Disk Image"

URL=https://download.mikrotik.com/routeros/7.7/install-image-7.7.zip

sleep 2
msg_ok "${CL}${BL}${URL}${CL}"
wget -q --show-progress $URL
echo -en "\e[1A\e[0K"
FILE=$(basename $URL)
msg_ok "Downloaded ${CL}${BL}$FILE${CL}"
msg_info "Extracting Mikrotik RouterOS Disk Image"
gunzip -f -S .zip $FILE
STORAGE_TYPE=$(pvesm status -storage $STORAGE | awk 'NR>1 {print $2}')
case $STORAGE_TYPE in
nfs | dir)
  DISK_EXT=".qcow2"
  DISK_REF="$VMID/"
  DISK_IMPORT="-format qcow2"
  ;;
btrfs)
  DISK_EXT=".raw"
  DISK_REF="$VMID/"
  DISK_FORMAT="subvol"
  DISK_IMPORT="-format raw"
  ;;
esac
for i in {0,1}; do
  disk="DISK$i"
  eval DISK${i}=vm-${VMID}-disk-${i}${DISK_EXT:-}
  eval DISK${i}_REF=${STORAGE}:${DISK_REF:-}${!disk}
done
msg_ok "Extracted Mikrotik RouterOS Disk Image"
msg_info "Creating Mikrotik RouterOS VM"
qm create $VMID -bios ovmf -cores $CORE_COUNT -memory $RAM_SIZE -name $HN -net0 virtio,bridge=$BRG,macaddr=$MAC$VLAN$MTU \
  -onboot 1 -ostype l26 -scsihw virtio-scsi-pci
pvesm alloc $STORAGE $VMID $DISK0 4M 1>&/dev/null
qm importdisk $VMID ${FILE%.*} $STORAGE ${DISK_IMPORT:-} 1>&/dev/null
qm set $VMID \
  -efidisk0 ${DISK0_REF},efitype=4m,size=4M \
  -scsi0 ${DISK1_REF},size=2G \
  -boot order=scsi0 \
  -description "# Mikrotik RouterOS VM
### https://github.com/tteck/Proxmox
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/D1D7EP4GF)" >/dev/null
msg_ok "Mikrotik RouterOS VM ${CL}${BL}(${HN})"
if [ "$START_VM" == "yes" ]; then
  msg_info "Starting Mikrotik RouterOS VM"
  qm start $VMID
  msg_ok "Started Mikrotik RouterOS VM"
fi
msg_ok "Completed Successfully!\n"
