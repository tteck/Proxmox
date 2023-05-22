#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
#         Jon Spriggs (jontheniceguy)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Based on work from https://i12bretro.github.io/tutorials/0405.html

function header_info {
  cat <<"EOF"
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------

EOF
}
clear
header_info
echo -e "Loading..."
GEN_MAC=$(echo '00 60 2f'$(od -An -N3 -t xC /dev/urandom) | sed -e 's/ /:/g' | tr '[:lower:]' '[:upper:]')
GEN_MAC_LAN=$(echo '00 60 2e'$(od -An -N3 -t xC /dev/urandom) | sed -e 's/ /:/g' | tr '[:lower:]' '[:upper:]')
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
function send_line_to_vm() {
  echo -e "${DGN}Sending line: ${YW}$1${CL}"
  for ((i=0; i<${#1}; i++)); do
    character=${1:i:1}
    case $character in
      " ") character="spc";;
      "-") character="minus";;
      "=") character="equal";;
      ",") character="comma";;
      ".") character="dot";;
      "/") character="slash";;
      "'") character="apostrophe";;
      ";") character="semicolon";;
      '\') character="backslash";;
      '`') character="grave_accent";;
      "[") character="bracket_left";;
      "]") character="bracket_right";;
      "_") character="shift-minus";;
      "+") character="shift-equal";;
      "?") character="shift-slash";;
      "<") character="shift-comma";;
      ">") character="shift-dot";;
      '"') character="shift-apostrophe";;
      ":") character="shift-semicolon";;
      "|") character="shift-backslash";;
      "~") character="shift-grave_accent";;
      "{") character="shift-bracket_left";;
      "}") character="shift-bracket_right";;
      "A") character="shift-a";;
      "B") character="shift-b";;
      "C") character="shift-c";;
      "D") character="shift-d";;
      "E") character="shift-e";;
      "F") character="shift-f";;
      "G") character="shift-g";;
      "H") character="shift-h";;
      "I") character="shift-i";;
      "J") character="shift-j";;
      "K") character="shift-k";;
      "L") character="shift-l";;
      "M") character="shift-m";;
      "N") character="shift-n";;
      "O") character="shift-o";;
      "P") character="shift-p";;
      "Q") character="shift-q";;
      "R") character="shift-r";;
      "S") character="shift-s";;
      "T") character="shift-t";;
      "U") character="shift-u";;
      "V") character="shift-v";;
      "W") character="shift-w";;
      "X") character="shift=x";;
      "Y") character="shift-y";;
      "Z") character="shift-z";;
      "!") character="shift-1";;
      "@") character="shift-2";;
      "#") character="shift-3";;
      '$') character="shift-4";;
      "%") character="shift-5";;
      "^") character="shift-6";;
      "&") character="shift-7";;
      "*") character="shift-8";;
      "(") character="shift-9";;
      ")") character="shift-0";;
    esac
    qm sendkey $VMID "$character"
  done
  qm sendkey $VMID ret
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
if (whiptail --title "OpenWRT VM" --yesno "This will create a New OpenWRT VM. Proceed?" 10 58); then
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
  echo -e "${DGN}Using Hostname: ${BGN}openwrt${CL}"
  HN=openwrt
  echo -e "${DGN}Allocated Cores: ${BGN}1${CL}"
  CORE_COUNT="1"
  echo -e "${DGN}Allocated RAM: ${BGN}256${CL}"
  RAM_SIZE="256"
  echo -e "${DGN}Using WAN Bridge: ${BGN}vmbr0${CL}"
  BRG="vmbr0"
  echo -e "${DGN}Using WAN VLAN: ${BGN}Default${CL}"
  VLAN=""
  echo -e "${DGN}Using WAN MAC Address: ${BGN}$GEN_MAC${CL}"
  MAC=$GEN_MAC
  echo -e "${DGN}Using LAN MAC Address: ${BGN}$GEN_MAC_LAN${CL}"
  LAN_MAC=$GEN_MAC_LAN
  echo -e "${DGN}Using LAN Bridge: ${BGN}vmbr0${CL}"
  LAN_BRG="vmbr0"
  echo -e "${DGN}Using LAN VLAN: ${BGN}999${CL}"
  LAN_VLAN=",tag=999"
  echo -e "${DGN}Using Interface MTU Size: ${BGN}Default${CL}"
  MTU=""
  echo -e "${DGN}Start VM when completed: ${BGN}yes${CL}"
  START_VM="yes"
  echo -e "${BL}Creating a OpenWRT VM using the above default settings${CL}"
}
function advanced_settings() {
  VMID=$(whiptail --inputbox "Set Virtual Machine ID" 8 58 $NEXTID --title "VIRTUAL MACHINE ID" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Using Virtual Machine ID: ${BGN}$VMID${CL}"
  else
    exit
  fi
  VM_NAME=$(whiptail --inputbox "Set Hostname" 8 58 openwrt --title "HOSTNAME" 3>&1 1>&2 2>&3)
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
  RAM_SIZE=$(whiptail --inputbox "Allocate RAM in MiB" 8 58 256 --title "RAM" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}"
  else
    exit
  fi
  BRG=$(whiptail --inputbox "Set a WAN Bridge" 8 58 vmbr0 --title "BRIDGE" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}"
  else
    exit
  fi
  LAN_BRG=$(whiptail --inputbox "Set a LAN Bridge" 8 58 vmbr0 --title "BRIDGE" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Using Bridge: ${BGN}$LAN_BRG${CL}"
  else
    exit
  fi
  MAC1=$(whiptail --inputbox "Set a WAN MAC Address" 8 58 $GEN_MAC --title "MAC ADDRESS" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    MAC="$MAC1"
    echo -e "${DGN}Using WAN MAC Address: ${BGN}$MAC1${CL}"
  else
    exit
  fi
  MAC2=$(whiptail --inputbox "Set a LAN MAC Address" 8 58 $GEN_MAC --title "MAC ADDRESS" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    LAN_MAC="$MAC2"
    echo -e "${DGN}Using LAN MAC Address: ${BGN}$MAC2${CL}"
  else
    exit
  fi
  VLAN1=$(whiptail --inputbox "Set a WAN VLAN tag(leave blank for default)" 8 58 --title "VLAN" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    if [ -z $VLAN1 ]; then
      VLAN1="Default" VLAN=""
      echo -e "${DGN}Using WAN VLAN tag: ${BGN}$VLAN1${CL}"
    else
      VLAN=",tag=$VLAN1"
      echo -e "${DGN}Using WAN VLAN tag: ${BGN}$VLAN1${CL}"
    fi
  fi
  VLAN2=$(whiptail --inputbox "Set a LAN VLAN tag(leave blank for default)" 8 58 --title "VLAN" 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    if [ -z $VLAN2 ]; then
      VLAN2="Default" LAN_VLAN=""
      echo -e "${DGN}Using LAN VLAN tag: ${BGN}$VLAN2${CL}"
    else
      LAN_VLAN=",tag=$VLAN2"
      echo -e "${DGN}Using LAN VLAN tag: ${BGN}$VLAN2${CL}"
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
  if (whiptail --title "START VIRTUAL MACHINE" --yesno "Start OpenWRT VM when completed?" 10 58); then
    echo -e "${DGN}Start OpenWRT VM when completed: ${BGN}yes${CL}"
    START_VM="yes"
  else
    echo -e "${DGN}Start OpenWRT VM when completed: ${BGN}no${CL}"
    START_VM="no"
  fi
  if (whiptail --title "ADVANCED SETTINGS COMPLETE" --yesno "Ready to create OpenWRT VM?" 10 58); then
    echo -e "${RD}Creating OpenWRT VM using the above advanced settings${CL}"
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
      "Which storage pool you would like to use for the OpenWRT VM?\n\n" \
      16 $(($MSG_MAX_LENGTH + 23)) 6 \
      "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit
  done
fi
msg_ok "Using ${CL}${BL}$STORAGE${CL} ${GN}for Storage Location."
msg_ok "Virtual Machine ID is ${CL}${BL}$VMID${CL}."
msg_info "Getting URL for OpenWRT Disk Image"

regex='<strong>Current Stable Release - OpenWrt ([^/]*)<\/strong>' && response=$(curl -s https://openwrt.org) && [[ $response =~ $regex ]] && stableVersion="${BASH_REMATCH[1]}"
URL=https://downloads.openwrt.org/releases/$stableVersion/targets/x86/64/openwrt-$stableVersion-x86-64-generic-ext4-combined.img.gz

sleep 2
msg_ok "${CL}${BL}${URL}${CL}"
wget -q --show-progress $URL
echo -en "\e[1A\e[0K"
FILE=$(basename $URL)
msg_ok "Downloaded ${CL}${BL}$FILE${CL}"
gunzip -f $FILE >/dev/null 2>/dev/null || true
NEWFILE="${FILE%.*}"
FILE="$NEWFILE"
mv $FILE ${FILE%.*}
qemu-img resize -f raw ${FILE%.*} 512M >/dev/null 2>/dev/null
msg_ok "Resized ${CL}${BL}$FILE${CL}"
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
msg_ok "Extracted OpenWRT Disk Image"
msg_info "Creating OpenWRT VM"
qm create $VMID -cores $CORE_COUNT -memory $RAM_SIZE -name $HN \
  -onboot 1 -ostype l26 -scsihw virtio-scsi-pci --tablet 0
pvesm alloc $STORAGE $VMID $DISK0 4M 1>&/dev/null
qm importdisk $VMID ${FILE%.*} $STORAGE ${DISK_IMPORT:-} 1>&/dev/null
qm set $VMID \
  -scsi0 ${DISK1_REF},size=512M \
  -boot order=scsi0 \
  -description "# OpenWRT VM
### https://github.com/tteck/Proxmox
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/D1D7EP4GF)" >/dev/null
msg_ok "OpenWRT VM ${CL}${BL}(${HN})"
msg_info "Pre-configuring network interfaces"
qm start $VMID
sleep 15
send_line_to_vm ""
send_line_to_vm "uci delete network.@device[0]"
send_line_to_vm "uci set network.wan=interface"
send_line_to_vm "uci set network.wan.device=eth0"
send_line_to_vm "uci set network.wan.proto=dhcp"
send_line_to_vm "uci delete network.lan"
send_line_to_vm "uci set network.lan=interface"
send_line_to_vm "uci set network.lan.device=eth1"
send_line_to_vm "uci set network.lan.proto=static"
send_line_to_vm "uci set network.lan.ipaddr=192.0.2.1"
send_line_to_vm "uci set network.lan.netmask=255.255.255.0"
send_line_to_vm "uci set firewall.@zone[1].input='ACCEPT'"
send_line_to_vm "uci set firewall.@zone[1].forward='ACCEPT'"
send_line_to_vm "uci commit"
send_line_to_vm "halt"
msg_ok "Pre-configured network interfaces"
until qm status $VMID | grep -q "stopped"
do
  sleep 2
done
msg_info "Adding bridge interface"
qm set $VMID \
  -net0 virtio,bridge=$BRG,macaddr=$MAC$VLAN$MTU \
  -net1 virtio,bridge=${LAN_BRG},macaddr=${LAN_MAC}${LAN_VLAN}$MTU >/dev/null 2>/dev/null
msg_ok "Added bridge interface"
if [ "$START_VM" == "yes" ]; then
  msg_info "Starting OpenWRT VM"
  qm start $VMID
  msg_ok "Started OpenWRT VM"
fi
VLAN_FINISH=""
if [ "$VLAN" == "" ] && [ "$LAN_VLAN" != "999" ]; then
  VLAN_FINISH=" Please remember to adjust the VLAN tags to suit your network."
fi
msg_ok "Completed Successfully!\n${VLAN_FINISH:-}"
