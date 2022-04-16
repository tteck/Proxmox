#!/usr/bin/env bash
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
APP="Debian"
NSAPP=$(echo ${APP,,} | tr -d ' ')
while true; do
    read -p "This will create a New ${APP} LXC. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${RD}
  _____       _     _             
 |  __ \     | |   (_)            
 | |  | | ___| |__  _  __ _ _ __  
 | |  | |/ _ \  _ \| |/ _  |  _ \ 
 | |__| |  __/ |_) | | (_| | | | |
 |_${YW}v3${RD}__/ \___|_.__/|_|\__,_|_| |_|
${CL}"
}

header_info

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
        clear
        header_info
        echo -e "${BL}Using Default Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}Unprivileged${CL} ${RD}NO DEVICE PASSTHROUGH${CL}"
        CT_TYPE="1"
	    echo -e "${DGN}Using CT Password ${BGN}Automatic Login${CL}"
		PW=" "
		echo -e "${DGN}Using ID ${BGN}$NEXTID${CL}"
		CT_ID=$NEXTID
		echo -e "${DGN}Using CT Name ${BGN}$NSAPP${CL}"
		HN=$NSAPP
		echo -e "${DGN}Using Disk Size ${BGN}2GB${CL}"
		DISK_SIZE="2"
		echo -e "${DGN}Using ${BGN}1vCPU${CL}"
		CORE_COUNT="1"
		echo -e "${DGN}Using ${BGN}512MiB${CL}${GN} RAM${CL}"
		RAM_SIZE="512"
		echo -e "${DGN}Using IP Address ${BGN}DHCP${CL}"
		NET=dhcp
		echo -e "${DGN}Using VLAN Tag ${BGN}NONE${CL}"
        VLAN=" "
}

function advanced_settings() {
        clear
        header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${YW}Type Privileged, or Press [ENTER] for Default: Unprivileged (${RD}NO DEVICE PASSTHROUGH${CL}${YW})"
        read CT_TYPE1
        if [ -z $CT_TYPE1 ]; then CT_TYPE1="Unprivileged" CT_TYPE="1"; 
        echo -en "${DGN}Set CT Type ${BL}$CT_TYPE1${CL}"
        else
        CT_TYPE1="Privileged"
        CT_TYPE="0"
        echo -en "${DGN}Set CT Type ${BL}Privileged${CL}"  
        fi;
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${YW}Set Password, or Press [ENTER] for Default: Automatic Login "
        read PW1
        if [ -z $PW1 ]; then PW1="Automatic Login" PW=" "; 
        echo -en "${DGN}Set CT ${BL}$PW1${CL}"
        else
          PW="-password $PW1"
        echo -en "${DGN}Set CT Password ${BL}$PW1${CL}"
        fi;
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${DGN}Using CT Password ${BGN}$PW1${CL}"
        echo -e "${YW}Enter the CT ID, or Press [ENTER] to automatically generate (${NEXTID}) "
        read CT_ID
        if [ -z $CT_ID ]; then CT_ID=$NEXTID; fi;
        echo -en "${DGN}Set CT ID To ${BL}$CT_ID${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${DGN}Using CT Password ${BGN}$PW1${CL}"
        echo -e "${DGN}Using ID ${BGN}$CT_ID${CL}"
        echo -e "${YW}Enter CT Name (no-spaces), or Press [ENTER] for Default: $NSAPP "
        read CT_NAME
        if [ -z $CT_NAME ]; then
           HN=$NSAPP
        else
           HN=$(echo ${CT_NAME,,} | tr -d ' ')
        fi
        echo -en "${DGN}Set CT Name To ${BL}$HN${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${DGN}Using CT Password ${BGN}$PW1${CL}"
        echo -e "${DGN}Using ID ${BGN}$CT_ID${CL}"
        echo -e "${DGN}Using CT Name ${BGN}$HN${CL}"
        echo -e "${YW}Enter a Disk Size, or Press [ENTER] for Default: 2Gb "
        read DISK_SIZE
        if [ -z $DISK_SIZE ]; then DISK_SIZE="2"; fi;
        if ! [[ $DISK_SIZE =~ $INTEGER ]] ; then echo "ERROR! DISK SIZE MUST HAVE INTEGER NUMBER!"; exit; fi;
        echo -en "${DGN}Set Disk Size To ${BL}$DISK_SIZE${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${DGN}Using CT Password ${BGN}$PW1${CL}"
        echo -e "${DGN}Using ID ${BGN}$CT_ID${CL}"
        echo -e "${DGN}Using CT Name ${BGN}$HN${CL}"
        echo -e "${DGN}Using Disk Size ${BGN}$DISK_SIZE${CL}"
        echo -e "${YW}Allocate CPU cores, or Press [ENTER] for Default: 1 "
        read CORE_COUNT
        if [ -z $CORE_COUNT ]; then CORE_COUNT="1"; fi;
        echo -en "${DGN}Set Cores To ${BL}$CORE_COUNT${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${DGN}Using CT Password ${BGN}$PW1${CL}"
        echo -e "${DGN}Using ID ${BGN}$CT_ID${CL}"
        echo -e "${DGN}Using CT Name ${BGN}$HN${CL}"
        echo -e "${DGN}Using Disk Size ${BGN}$DISK_SIZE${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
        echo -e "${YW}Allocate RAM in MiB, or Press [ENTER] for Default: 512 "
        read RAM_SIZE
        if [ -z $RAM_SIZE ]; then RAM_SIZE="512"; fi;
        echo -en "${DGN}Set RAM To ${BL}$RAM_SIZE${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${DGN}Using CT Password ${BGN}$PW1${CL}"
        echo -e "${DGN}Using ID ${BGN}$CT_ID${CL}"
        echo -e "${DGN}Using CT Name ${BGN}$HN${CL}"
        echo -e "${DGN}Using Disk Size ${BGN}$DISK_SIZE${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}MiB${CL}${GN} RAM${CL}"
        echo -e "${YW}Enter a IP Address, or Press [ENTER] for Default: DHCP "
        read NET
        if [ -z $NET ]; then NET="dhcp"; fi;
        echo -en "${DGN}Set IP Address To ${BL}$NET${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${DGN}Using CT Password ${BGN}$PW1${CL}"
        echo -e "${DGN}Using ID ${BGN}$CT_ID${CL}"
        echo -e "${DGN}Using CT Name ${BGN}$HN${CL}"
        echo -e "${DGN}Using Disk Size ${BGN}$DISK_SIZE${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}MiB${CL}${GN} RAM${CL}"
        echo -e "${DGN}Using IP Address ${BGN}$NET${CL}"
        echo -e "${YW}Enter a VLAN Tag, or Press [ENTER] for Default: NONE "
        read VLAN1
        if [ -z $VLAN1 ]; then VLAN1="NONE" VLAN=" "; 
        echo -en "${DGN}Set VLAN Tag To ${BL}$VLAN1${CL}"
        else
          VLAN="-tag $VLAN1"
        echo -en "${DGN}Set VLAN Tag To ${BL}$VLAN1${CL}"
        fi;
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using CT Type ${BGN}$CT_TYPE1${CL}"
        echo -e "${DGN}Using CT Password ${BGN}$PW1${CL}"
        echo -e "${DGN}Using ID ${BGN}$CT_ID${CL}"
        echo -e "${DGN}Using CT Name ${BGN}$HN${CL}"
        echo -e "${DGN}Using Disk Size ${BGN}$DISK_SIZE${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}MiB${CL}${GN} RAM${CL}"
        echo -e "${DGN}Using IP Address ${BGN}$NET${CL}"
        echo -e "${DGN}Using VLAN Tag ${BGN}$VLAN1${CL}"

read -p "Are these settings correct(y/n)? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    advanced_settings
fi
}

function start_script() {
		echo -e "${YW}Type Advanced, or Press [ENTER] for Default Settings "
		read SETTINGS
		if [ -z $SETTINGS ]; then default_settings; 
		else
		advanced_settings 
		fi;
}

start_script

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
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  [ ! -z ${CTID-} ] && cleanup_ctid
  exit $EXIT
}

function warn() {
  local REASON="\e[97m$1\e[39m"
  local FLAG="\e[93m[WARNING]\e[39m"
  msg "$FLAG $REASON"
}

function info() {
  local REASON="$1"
  local FLAG="\e[36m[INFO]\e[39m"
  msg "$FLAG $REASON"
}

function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

function cleanup_ctid() {
  if $(pct status $CTID &>/dev/null); then
    if [ "$(pct status $CTID | awk '{print $2}')" == "running" ]; then
      pct stop $CTID
    fi
    pct destroy $CTID
  elif [ "$(pvesm list $STORAGE --vmid $CTID)" != "" ]; then
    pvesm free $ROOTFS
  fi
}

function cleanup() {
  popd >/dev/null
  rm -rf $TEMP_DIR
}

if [ "$CT_TYPE" == "1" ]; then 
 FEATURES="nesting=1,keyctl=1"
 else
 FEATURES="nesting=1"
 fi

TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null

export CTID=$CT_ID
export PCT_OSTYPE=debian
export PCT_OSVERSION=11
export PCT_DISK_SIZE=$DISK_SIZE
export PCT_OPTIONS="
  -features $FEATURES
  -hostname $HN
  -net0 name=eth0,bridge=vmbr0,ip=$NET
  $VLAN
  -onboot 1
  -cores $CORE_COUNT
  -memory $RAM_SIZE
  -unprivileged $CT_TYPE
  $PW
"
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/create_lxc.sh)" || exit

STORAGE_TYPE=$(pvesm status -storage $(pct config $CTID | grep rootfs | awk -F ":" '{print $2}') | awk 'NR>1 {print $2}')
if [ "$STORAGE_TYPE" == "zfspool" ]; then
  warn "Some applications may not work properly due to ZFS not supporting 'fallocate'."
fi

msg_info "Starting LXC Container"
pct start $CTID
msg_ok "Started LXC Container"

alias lxc-cmd="lxc-attach -n $CTID --"

lxc-cmd bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/setup/debian-install.sh)" || exit

IP=$(pct exec $CTID ip a s dev eth0 | sed -n '/inet / s/\// /p' | awk '{print $2}')

echo -e "${GN}Successfully created ${APP} LXC to${CL} ${BL}$CTID${CL}. \n"
