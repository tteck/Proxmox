#!/usr/bin/env bash
NEXTID=$(pvesh get /cluster/nextid)
INTEGER='^[0-9]+$'
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
CM='\xE2\x9C\x94\033'
BGN=`echo "\033[4;92m"`
GN=`echo "\033[32m"`
CL=`echo "\033[m"`
APP="Debian"

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

function pve_7() {
if [ `pveversion | grep "pve-manager/7" | wc -l` -ne 1 ]; then
        echo -e "${RD}This script requires Proxmox Virtual Environment 7.0 or greater"
        echo -e "Exiting..."
        sleep 2
        exit
fi
}

function default_settings() {
                clear
                header_info
                echo -e "${BL}Using Default Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}Unprivileged${CL} ${RD}NO DEVICE PASSTHROUGH${CL}"
                CT_TYPE="1"
		echo -e "${GN}Using CT Password ${BGN}Automatic Login${CL}"
		PW=" "
		echo -e "${GN}Using ID ${BGN}$NEXTID${CL}"
		CT_ID=$NEXTID
		echo -e "${GN}Using CT Name ${BGN}$APP${CL}"
		HN=$(echo ${APP,,} | tr -d ' ')
		echo -e "${GN}Using Disk Size ${BGN}2GB${CL}"
		SIZEDISK="2"
		echo -e "${GN}Using Storage ${BGN}local-lvm${CL}"
		STORAGETYPE="local-lvm"
		echo -e "${GN}Using ${BGN}1vCPU${CL}"
		CORE_COUNT="1"
		echo -e "${GN}Using ${BGN}512MiB${CL}${GN} RAM${CL}"
		RAM_SIZE="512"
		echo -e "${GN}Using IP Address ${BGN}DHCP${CL}"
		NET=dhcp
		echo -e "${GN}Using VLAN Tag ${BGN}NONE${CL}"
                VLAN=" "
}

function advanced_settings() {
                clear
                header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${YW}Type Privileged, or Press [ENTER] for Default: Unprivileged (${RD}NO DEVICE PASSTHROUGH${CL}${YW})"
                read CT_TYPE1
                if [ -z $CT_TYPE1 ]; then CT_TYPE1="Unprivileged" CT_TYPE="1"; 
                echo -en "${GN}Set CT Type ${BL}$CT_TYPE1${CL}"
                else
                CT_TYPE1="Privileged"
                CT_TYPE="0"
                echo -en "${GN}Set CT Type ${BL}Privileged${CL}"  
                fi;
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${YW}Set Password, or Press [ENTER] for Default: Automatic Login "
                read PW1
                if [ -z $PW1 ]; then PW1="Automatic Login" PW=" "; 
                echo -en "${GN}Set CT ${BL}$PW1${CL}"
                else
                  PW="-password $PW1"
                echo -en "${GN}Set CT Password ${BL}$PW1${CL}"

                fi;
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${YW}Enter the CT ID, or Press [ENTER] to automatically generate (${NEXTID}) "
                read CT_ID
                if [ -z $CT_ID ]; then CT_ID=$NEXTID; fi;
                echo -en "${GN}Set CT ID To ${BL}$CT_ID${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${GN}Using ID ${BGN}$CT_ID${CL}"
                echo -e "${YW}Enter CT Name (no spaces), or Press [ENTER] for Default: $APP "
                read CT_NAME
                if [ -z $CT_NAME ]; then CT_NAME=$APP; HN=$(echo ${CT_NAME,,} | tr -d ' '); fi
                if [ $CT_NAME ]; then HN=$(echo ${CT_NAME,,} | tr -d ' '); fi
                echo -en "${GN}Set CT Name To ${BL}$CT_NAME${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${GN}Using ID ${BGN}$CT_ID${CL}"
                echo -e "${GN}Using CT Name ${BGN}$CT_NAME${CL}"
                echo -e "${YW}Enter a Disk Size, or Press [ENTER] for Default: 2Gb "
                read SIZEDISK
                if [ -z $SIZEDISK ]; then SIZEDISK="2"; fi;
                if ! [[ $SIZEDISK =~ $INTEGER ]] ; then echo "ERROR! SIZEDISK MUST HAVE INTEGER NUMBER!"; exit; fi;
                echo -en "${GN}Set Disk Size To ${BL}$SIZEDISK${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${GN}Using ID ${BGN}$CT_ID${CL}"
                echo -e "${GN}Using CT Name ${BGN}$CT_NAME${CL}"
                echo -e "${GN}Using Disk Size ${BGN}$SIZEDISK${CL}"
                echo -e "${YW}Storages Available:${CL}"
                echo " "
                for stg in `pvesh get storage --noborder --noheader`
                do
                        echo -e "${BL}     - ${stg}${CL}"
                done
                echo " "
                echo -e "${YW}Enter which storage to create the CT, or Press [ENTER] for Default: local-lvm "
                read STORAGETYPE
                if [ -z $STORAGETYPE ]; then STORAGETYPE="local-lvm"; fi;
                echo -en "${GN}Set Storage To ${BL}$STORAGETYPE${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${GN}Using ID ${BGN}$CT_ID${CL}"
                echo -e "${GN}Using CT Name ${BGN}$CT_NAME${CL}"
                echo -e "${GN}Using Disk Size ${BGN}$SIZEDISK${CL}"
                echo -e "${GN}Using Storage ${BGN}$STORAGETYPE${CL}"
                echo -e "${YW}Allocate CPU cores, or Press [ENTER] for Default: 1 "
                read CORE_COUNT
                if [ -z $CORE_COUNT ]; then CORE_COUNT="1"; fi;
                echo -en "${GN}Set Cores To ${BL}$CORE_COUNT${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${GN}Using ID ${BGN}$CT_ID${CL}"
                echo -e "${GN}Using CT Name ${BGN}$CT_NAME${CL}"
                echo -e "${GN}Using Disk Size ${BGN}$SIZEDISK${CL}"
                echo -e "${GN}Using Storage ${BGN}$STORAGETYPE${CL}"
                echo -e "${GN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
                echo -e "${YW}Allocate RAM in MiB, or Press [ENTER] for Default: 512 "
                read RAM_SIZE
                if [ -z $RAM_SIZE ]; then RAM_SIZE="512"; fi;
                echo -en "${GN}Set RAM To ${BL}$RAM_SIZE${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${GN}Using ID ${BGN}$CT_ID${CL}"
                echo -e "${GN}Using CT Name ${BGN}$CT_NAME${CL}"
                echo -e "${GN}Using Disk Size ${BGN}$SIZEDISK${CL}"
                echo -e "${GN}Using Storage ${BGN}$STORAGETYPE${CL}"
                echo -e "${GN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
                echo -e "${GN}Using ${BGN}${RAM_SIZE}MiB${CL}${GN} RAM${CL}"
                echo -e "${YW}Enter a IP Address, or Press [ENTER] for Default: DHCP "
                read NET
                if [ -z $NET ]; then NET="dhcp"; fi;
                echo -en "${GN}Set IP Address To ${BL}$NET${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${GN}Using ID ${BGN}$CT_ID${CL}"
                echo -e "${GN}Using CT Name ${BGN}$CT_NAME${CL}"
                echo -e "${GN}Using Disk Size ${BGN}$SIZEDISK${CL}"
                echo -e "${GN}Using Storage ${BGN}$STORAGETYPE${CL}"
                echo -e "${GN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
                echo -e "${GN}Using ${BGN}${RAM_SIZE}MiB${CL}${GN} RAM${CL}"
                echo -e "${GN}Using IP Address ${BGN}$NET${CL}"
                echo -e "${YW}Enter a VLAN Tag, or Press [ENTER] for Default: NONE "
                read VLAN1
                if [ -z $VLAN1 ]; then VLAN1="NONE" VLAN=" "; 
                echo -en "${GN}Set VLAN Tag To ${BL}$VLAN1${CL}"
                else
                  VLAN="-tag $VLAN1"
                echo -en "${GN}Set VLAN Tag To ${BL}$VLAN1${CL}"
                fi;
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
                echo -e "${RD}Using Advanced Settings${CL}"
                echo -e "${GN}Using CT Type ${BGN}$CT_TYPE1${CL}"
                echo -e "${GN}Using CT Password ${BGN}$PW1${CL}"
                echo -e "${GN}Using ID ${BGN}$CT_ID${CL}"
                echo -e "${GN}Using CT Name ${BGN}$CT_NAME${CL}"
                echo -e "${GN}Using Disk Size ${BGN}$SIZEDISK${CL}"
                echo -e "${GN}Using Storage ${BGN}$STORAGETYPE${CL}"
                echo -e "${GN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
                echo -e "${GN}Using ${BGN}${RAM_SIZE}MiB${CL}${GN} RAM${CL}"
                echo -e "${GN}Using IP Address ${BGN}$NET${CL}"
                echo -e "${GN}Using VLAN Tag ${BGN}$VLAN1${CL}"
while true; do
    read -p "Are these settings correct(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) clear; header_info; start_script;;
        * ) echo "Please answer yes or no";;
    esac
done
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
export PCT_DISK_SIZE=$SIZEDISK
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
LXC_CONFIG=/etc/pve/lxc/${CTID}.conf
cat <<EOF >> $LXC_CONFIG
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
EOF

echo -en "${GN} Starting LXC Container... "
pct start $CTID
echo -e "${CM}${CL} \r"

alias lxc-cmd="lxc-attach -n $CTID --"

lxc-cmd bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/setup/debian-install.sh)" || exit

IP=$(pct exec $CTID ip a s dev eth0 | sed -n '/inet / s/\// /p' | awk '{print $2}')

echo -e "${GN}Successfully created ${APP} LXC to${CL} ${BL}$CTID${CL}. \n"
