#!/usr/bin/env bash
echo -e "Loading..."
APP="Debian"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="11"
NSAPP=$(echo ${APP,,} | tr -d ' ')
var_install="${NSAPP}-install"
NEXTID=$(pvesh get /cluster/nextid)
INTEGER='^[0-9]+$'
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
BGN=`echo "\033[4;92m"`
GN=`echo "\033[1;92m"`
DGN=`echo "\033[32m"`
CL=`echo "\033[m"`
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
function error_exit() {
  trap - ERR
  local reason="Unknown failure occurred."
  local msg="${1:-$reason}"
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  exit $EXIT
}
if (whiptail --title "${APP} LXC" --yesno "This will create a New ${APP} LXC. Proceed?" 10 58); then
    echo "User selected Yes"
else
    clear
    echo -e "⚠ User exited script \n"
    exit
fi
function header_info {
echo -e "${RD}
    ____  __________  _______    _   __
   / __ \/ ____/ __ )/  _/   |  / | / /
  / / / / __/ / __  |/ // /| | /  |/ / 
 / /_/ / /_v4/ /_/ // // ___ |/ /|  /  
/_____/_____/_____/___/_/  |_/_/ |_/   
${CL}"
}
function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}
function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}
function PVE_CHECK() {
    PVE=$(pveversion | grep "pve-manager/7" | wc -l)
if [[ $PVE != 1 ]]; then
   echo -e "${RD}This script requires Proxmox Virtual Environment 7.0 or greater${CL}"
   echo -e "Exiting..."
   sleep 2
   exit
fi
}
function default_settings() {
		echo -e "${DGN}Using Container Type: ${BGN}Unprivileged${CL} ${RD}NO DEVICE PASSTHROUGH${CL}"
		CT_TYPE="1"
		echo -e "${DGN}Using Root Password: ${BGN}Automatic Login${CL}"
		PW=""
		echo -e "${DGN}Using Container ID: ${BGN}$NEXTID${CL}"
		CT_ID=$NEXTID
		echo -e "${DGN}Using Hostname: ${BGN}$NSAPP${CL}"
		HN=$NSAPP
		echo -e "${DGN}Using Disk Size: ${BGN}$var_disk${CL}${DGN}GB${CL}"
		DISK_SIZE="$var_disk"
		echo -e "${DGN}Allocated Cores ${BGN}$var_cpu${CL}"
		CORE_COUNT="$var_cpu"
		echo -e "${DGN}Allocated Ram ${BGN}$var_ram${CL}"
		RAM_SIZE="$var_ram"
		echo -e "${DGN}Using Bridge: ${BGN}vmbr0${CL}"
		BRG="vmbr0"
		echo -e "${DGN}Using Static IP Address: ${BGN}dhcp${CL}"
		NET=dhcp
		echo -e "${DGN}Using Gateway Address: ${BGN}Default${CL}"
		GATE=""
		echo -e "${DGN}Using MAC Address: ${BGN}Default${CL}"
		MAC=""
    echo -e "${DGN}Using VLAN Tag: ${BGN}Default${CL}"
    VLAN=""
		echo -e "${BL}Creating a ${APP} LXC using the above default settings${CL}"
}
function advanced_settings() {
CT_TYPE=$(whiptail --title "CONTAINER TYPE" --radiolist --cancel-button Exit-Script "Choose Type" 8 58 2 \
"1" "Unprivileged" ON \
"0" "Privileged" OFF \
3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo -e "${DGN}Using Container Type: ${BGN}$CT_TYPE${CL}"
fi
PW1=$(whiptail --inputbox "Set Root Password" 8 58  --title "PASSWORD(leave blank for automatic login)" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
  if [ -z $PW1 ]; then PW1="Automatic Login" PW=" ";
    echo -e "${DGN}Using Root Password: ${BGN}$PW1${CL}"
else
    PW="-password $PW1"
    echo -e "${DGN}Using Root Password: ${BGN}$PW1${CL}"
  fi
fi
CT_ID=$(whiptail --inputbox "Set Container ID" 8 58 $NEXTID --title "CONTAINER ID" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $CT_ID ]; then CT_ID="$NEXTID"; echo -e "${DGN}Container ID: ${BGN}$CT_ID${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Using Container ID: ${BGN}$CT_ID${CL}"; fi;
fi
CT_NAME=$(whiptail --inputbox "Set Hostname" 8 58 $NSAPP --title "HOSTNAME" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $CT_NAME ]; then HN="$NSAPP"; echo -e "${DGN}Using Hostname: ${BGN}$HN${CL}";
else
  if [ $exitstatus = 0 ]; then HN=$(echo ${CT_NAME,,} | tr -d ' '); echo -e "${DGN}Using Hostname: ${BGN}$HN${CL}"; fi;
fi
DISK_SIZE=$(whiptail --inputbox "Set Disk Size in GB" 8 58 $var_disk --title "DISK SIZE" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $DISK_SIZE ]; then DISK_SIZE="$var_disk"; echo -e "${DGN}Using Disk Size: ${BGN}$DISK_SIZE${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Using Disk Size: ${BGN}$DISK_SIZE${CL}"; fi;
    if ! [[ $DISK_SIZE =~ $INTEGER ]] ; then echo -e "${RD}⚠ DISK SIZE MUST BE A INTEGER NUMBER!${CL}"; advanced_settings; fi;
fi
CORE_COUNT=$(whiptail --inputbox "Allocate CPU Cores" 8 58 $var_cpu --title "CORE COUNT" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $CORE_COUNT ]; then CORE_COUNT="$var_cpu"; echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}"; fi;
fi
RAM_SIZE=$(whiptail --inputbox "Allocate RAM in MiB" 8 58 $var_ram --title "RAM" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $RAM_SIZE ]; then RAM_SIZE="$var_ram"; echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}"; fi;
fi
BRG=$(whiptail --inputbox "Set a Bridge" 8 58 vmbr0 --title "BRIDGE" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $BRG ]; then BRG="vmbr0"; echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}"; fi;
fi
NET=$(whiptail --inputbox "Set a Static IPv4 CIDR Address(/24)" 8 58 dhcp --title "IP ADDRESS" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $NET ]; then NET="dhcp"; echo -e "${DGN}Using IP Address: ${BGN}$NET${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Using IP Address: ${BGN}$NET${CL}"; fi;
fi
GATE1=$(whiptail --inputbox "Set a Gateway IP (mandatory if Static IP was used)" 8 58  --title "GATEWAY IP" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
  if [ -z $GATE1 ]; then GATE1="Default" GATE="";
    echo -e "${DGN}Using Gateway IP Address: ${BGN}$GATE1${CL}"
else
    GATE=",gw=$GATE1"
    echo -e "${DGN}Using Gateway IP Address: ${BGN}$GATE1${CL}"
  fi
fi
MAC1=$(whiptail --inputbox "Set a MAC Address(leave blank for default)" 8 58  --title "MAC ADDRESS" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
  if [ -z $MAC1 ]; then MAC1="Default" MAC="";
    echo -e "${DGN}Using MAC Address: ${BGN}$MAC1${CL}"
else
    MAC=",hwaddr=$MAC1"
    echo -e "${DGN}Using MAC Address: ${BGN}$MAC1${CL}"
  fi
fi
VLAN1=$(whiptail --inputbox "Set a Vlan(leave blank for default)" 8 58  --title "VLAN" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
  if [ -z $VLAN1 ]; then VLAN1="Default" VLAN="";
    echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
else
    VLAN=",tag=$VLAN1"
    echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
  fi  
fi
if (whiptail --title "ADVANCED SETTINGS COMPLETE" --yesno "Ready to create ${APP} LXC?" --no-button Do-Over 10 58); then
    echo -e "${RD}Creating a ${APP} LXC using the above advanced settings${CL}"
else
  clear
  header_info
  echo -e "${RD}Using Advanced Settings${CL}"
  advanced_settings
fi
}
function start_script() {
if (whiptail --title "SETTINGS" --yesno "Use Default Settings?" --no-button Advanced 10 58); then
  header_info
  echo -e "${BL}Using Default Settings${CL}"
  default_settings
else
  header_info
  echo -e "${RD}Using Advanced Settings${CL}"
  advanced_settings
fi
}
clear
start_script
if [ "$CT_TYPE" == "1" ]; then 
 FEATURES="nesting=1,keyctl=1"
 else
 FEATURES="nesting=1"
 fi
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null
export CTID=$CT_ID
export PCT_OSTYPE=$var_os
export PCT_OSVERSION=$var_version
export PCT_DISK_SIZE=$DISK_SIZE
export PCT_OPTIONS="
  -features $FEATURES
  -hostname $HN
  -net0 name=eth0,bridge=$BRG$MAC,ip=$NET$GATE$VLAN
  -onboot 1
  -cores $CORE_COUNT
  -memory $RAM_SIZE
  -unprivileged $CT_TYPE
  $PW
"
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/create_lxc.sh)" || exit
msg_info "Starting LXC Container"
pct start $CTID
msg_ok "Started LXC Container"
lxc-attach -n $CTID -- bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/setup/$var_install.sh)" || exit
IP=$(pct exec $CTID ip a s dev eth0 | sed -n '/inet / s/\// /p' | awk '{print $2}')
pct set $CTID -description "# ${APP} ${var_version} LXC
### https://tteck.github.io/Proxmox/
<a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/☕-Buy me a coffee-red' /></a>"
msg_ok "Completed Successfully!\n"
