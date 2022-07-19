#!/usr/bin/env bash
GEN_MAC=$(echo '00 60 2f'$(od -An -N3 -t xC /dev/urandom) | sed -e 's/ /:/g' | tr '[:lower:]' '[:upper:]')
NEXTID=$(pvesh get /cluster/nextid)
RELEASE=$(curl -sX GET "https://api.github.com/repos/home-assistant/operating-system/releases" | awk '/tag_name/{print $4;exit}' FS='[""]')
STABLE="8.2"
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

while true; do
    read -p "This will create a New PiMox Home Assistant OS VM. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear

function header_info {
echo -e "${YW}

  _____ _        _    _          ____   _____ 
 |  __ (_)      | |  | |   /\   / __ \ / ____|
 | |__) | ______| |__| |  /  \ | |  | | (___  
 |  ___/ |__v3__|  __  | / /\ \| |  | |\___ \ 
 | |   | |      | |  | |/ ____ \ |__| |____) |
 |_|   |_|      |_|  |_/_/    \_\____/|_____/ 
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
function default_settings() {
        clear
        header_info
        echo -e "${BL}Using Default Settings${CL}"
		echo -e "${DGN}Using Version ${BGN}${STABLE}${CL}"
		BRANCH=${STABLE}
		echo -e "${DGN}Using VM ID ${BGN}$NEXTID${CL}"
		VMID=$NEXTID
		echo -e "${DGN}Using VM Name ${BGN}pi-haos${STABLE}${CL}"
		VM_NAME=pi-haos${STABLE}
	        echo -e "${DGN}Using ${BGN}2${CL}${DGN}vCPU${CL}"
	        CORE_COUNT="2"
 	        echo -e "${DGN}Using ${BGN}4096${CL}${DGN}MiB RAM${CL}"
	        RAM_SIZE="4096"
	        echo -e "${DGN}Using Bridge ${BGN}vmbr0${CL}"
	        BRG="vmbr0"
	        echo -e "${DGN}Using MAC Address ${BGN}$GEN_MAC${CL}"
		MAC=$GEN_MAC
	        echo -e "${DGN}Using VLAN Tag ${BGN}NONE${CL}"
	        VLAN=""
		echo -e "${DGN}Start VM when completed ${BGN}yes${CL}"
		START_VM="yes"

}
function advanced_settings() {
        clear
        header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${YW}Type Latest for Version ${RELEASE}, or Press [ENTER] for Stable Version ${STABLE} "
        read BRANCH
        if [ -z $BRANCH ]; then BRANCH=$STABLE; 
        else
          BRANCH=$RELEASE; fi;
	echo -en "${DGN}Set Version To ${BL}$BRANCH${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
	clear
        header_info
        echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${YW}Enter the VM ID, or Press [ENTER] to automatically generate (${NEXTID}) "
        read VMID
        if [ -z $VMID ]; then VMID=$NEXTID; fi;
	echo -en "${DGN}Set VM ID To ${BL}$VMID${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${DGN}Using VM ID ${BGN}$VMID${CL}"
        echo -e "${YW}Enter VM Name (no-spaces), or Press [ENTER] for Default: pi-haos${BRANCH} "
        read VMNAME
        if [ -z $VMNAME ]; then
           VM_NAME=pi-haos${BRANCH}
        else
           VM_NAME=$(echo ${VMNAME,,} | tr -d ' ')
        fi
        echo -en "${DGN}Set CT Name To ${BL}$VM_NAME${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${DGN}Using VM ID ${BGN}$VMID${CL}"
        echo -e "${DGN}Using VM Name ${BGN}$VM_NAME${CL}"
        echo -e "${YW}Allocate CPU cores, or Press [ENTER] for Default: 2 "
        read CORE_COUNT
        if [ -z $CORE_COUNT ]; then CORE_COUNT="2"; fi;
        echo -en "${DGN}Set Cores To ${BL}${CORE_COUNT}${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${DGN}Using VM ID ${BGN}$VMID${CL}"
        echo -e "${DGN}Using VM Name ${BGN}$VM_NAME${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}${CL}${DGN}vCPU${CL}"
        echo -e "${YW}Allocate RAM in MiB, or Press [ENTER] for Default: 4096 "
        read RAM_SIZE
        if [ -z $RAM_SIZE ]; then RAM_SIZE="4096"; fi;
        echo -en "${DGN}Set RAM To ${BL}$RAM_SIZE${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${DGN}Using VM ID ${BGN}$VMID${CL}"
        echo -e "${DGN}Using VM Name ${BGN}$VM_NAME${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}${CL}${DGN}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}${CL}${DGN}MiB RAM${CL}"
        echo -e "${YW}Enter a Bridge, or Press [ENTER] for Default: vmbr0 "
        read BRG
        if [ -z $BRG ]; then BRG="vmbr0"; fi;
        echo -en "${DGN}Set Bridge To ${BL}$BRG${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${DGN}Using VM ID ${BGN}$VMID${CL}"
        echo -e "${DGN}Using VM Name ${BGN}$VM_NAME${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}${CL}${DGN}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}${CL}${DGN}MiB RAM${CL}"
	echo -e "${DGN}Using Bridge ${BGN}${BRG}${CL}"
        echo -e "${YW}Enter a Valid MAC Address, or Press [ENTER] for Generated MAC: $GEN_MAC "
        read MAC
        if [ -z $MAC ]; then MAC=$GEN_MAC; fi;
        echo -en "${DGN}Set MAC Address To ${BL}$MAC${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${DGN}Using VM ID ${BGN}$VMID${CL}"
        echo -e "${DGN}Using VM Name ${BGN}$VM_NAME${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}${CL}${DGN}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}${CL}${DGN}MiB RAM${CL}"
	echo -e "${DGN}Using Bridge ${BGN}${BRG}${CL}"
        echo -e "${DGN}Using MAC Address ${BGN}$MAC${CL}"
        echo -e "${YW}Enter a VLAN Tag, or Press [ENTER] for Default: NONE "
        read VLAN1
        if [ -z $VLAN1 ]; then VLAN1="NONE" VLAN=""; 
        echo -en "${DGN}Set VLAN Tag To ${BL}$VLAN1${CL}"
        else
          VLAN=",tag=$VLAN1"
        echo -en "${DGN}Set VLAN Tag To ${BL}$VLAN1${CL}"
        fi;
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
	echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${DGN}Using VM ID ${BGN}$VMID${CL}"
        echo -e "${DGN}Using VM Name ${BGN}$VM_NAME${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}${CL}${DGN}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}${CL}${DGN}MiB${CL}"
	echo -e "${DGN}Using Bridge ${BGN}${BRG}${CL}"
        echo -e "${DGN}Using MAC Address ${BGN}$MAC${CL}"
        echo -e "${DGN}Using VLAN Tag ${BGN}$VLAN1${CL}"
        echo -e "${YW}Start VM when completed, or Press [ENTER] for Default: yes "
        read START_VM
        if [ -z $START_VM ]; then START_VM="yes"; 
        else
          START_VM="no"; fi;
        echo -en "${DGN}Starting VM when completed ${BL}$START_VM${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
	echo -e "${DGN}Using Version ${BGN}$BRANCH${CL}"
        echo -e "${DGN}Using VM ID ${BGN}$VMID${CL}"
        echo -e "${DGN}Using VM Name ${BGN}$VM_NAME${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}${CL}${DGN}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}${CL}${DGN}MiB${CL}"
	echo -e "${DGN}Using Bridge ${BGN}${BRG}${CL}"
        echo -e "${DGN}Using MAC Address ${BGN}$MAC${CL}"
        echo -e "${DGN}Using VLAN Tag ${BGN}$VLAN1${CL}"
	echo -e "${DGN}Start VM when completed ${BGN}$START_VM${CL}"

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

while read -r line; do
  TAG=$(echo $line | awk '{print $1}')
  TYPE=$(echo $line | awk '{printf "%-10s", $2}')
  FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | awk '{printf( "%9sB", $6)}')
  ITEM="  Type: $TYPE Free: $FREE "
  OFFSET=2
  if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
    MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
  fi
  STORAGE_MENU+=( "$TAG" "$ITEM" "OFF" )
done < <(pvesm status -content images | awk 'NR>1')
if [ $((${#STORAGE_MENU[@]}/3)) -eq 0 ]; then
  echo -e "'Disk image' needs to be selected for at least one storage location."
  die "Unable to detect valid storage location."
elif [ $((${#STORAGE_MENU[@]}/3)) -eq 1 ]; then
  STORAGE=${STORAGE_MENU[0]}
else
  while [ -z "${STORAGE:+x}" ]; do
    STORAGE=$(whiptail --title "Storage Pools" --radiolist \
    "Which storage pool you would like to use for the Pi-HAOS VM?\n\n" \
    16 $(($MSG_MAX_LENGTH + 23)) 6 \
    "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit
  done
fi
msg_ok "Using ${CL}${BL}$STORAGE${CL} ${GN}for Storage Location."
msg_ok "Virtual Machine ID is ${CL}${BL}$VMID${CL}."
msg_info "Getting URL for Home Assistant ${BRANCH} Disk Image"
URL=https://github.com/home-assistant/operating-system/releases/download/${BRANCH}/haos_generic-aarch64-${BRANCH}.img.xz
sleep 2
msg_ok "${CL}${BL}${URL}${CL}"
wget -q --show-progress $URL
echo -en "\e[1A\e[0K"
FILE=$(basename $URL)
msg_ok "Downloaded ${CL}${BL}haos_generic-aarch64-${BRANCH}.img.xz${CL}"
msg_info "Extracting Disk Image"
unxz $FILE
STORAGE_TYPE=$(pvesm status -storage $STORAGE | awk 'NR>1 {print $2}')
case $STORAGE_TYPE in
  btrfs|nfs|dir)
    DISK_EXT=".raw"
    DISK_REF="$VMID/"
    DISK_IMPORT="-format raw"
esac
for i in {0,1}; do
  disk="DISK$i"
  eval DISK${i}=vm-${VMID}-disk-${i}${DISK_EXT:-}
  eval DISK${i}_REF=${STORAGE}:${DISK_REF:-}${!disk}
done
msg_ok "Extracted Disk Image"

msg_info "Creating Pi-HAOS VM"
qm create $VMID -agent 1 -bios ovmf -cores $CORE_COUNT -memory $RAM_SIZE -name $VM_NAME -net0 virtio,bridge=$BRG,macaddr=$MAC$VLAN \
  -onboot 1 -ostype l26 -scsihw virtio-scsi-pci
pvesm alloc $STORAGE $VMID $DISK0 4M 1>&/dev/null
qm importdisk $VMID ${FILE%.*} $STORAGE ${DISK_IMPORT:-} 1>&/dev/null
qm set $VMID \
  -efidisk0 ${DISK0_REF},efitype=4m,size=4M \
  -scsi0 ${DISK1_REF},size=32G >/dev/null
qm set $VMID \
  -boot order=scsi0 >/dev/null
#qm resize $VMID scsi0 +26G >/dev/null
qm set $VMID -description "# Home Assistant OS
### https://github.com/tteck/Proxmox" >/dev/null

msg_ok "Created Pi-HAOS VM ${CL}${BL}${VM_NAME}"

if [ "$START_VM" == "yes" ]; then
msg_info "Starting Home Assistant OS VM"
qm start $VMID
msg_ok "Started Home Assistant OS VM"
fi
msg_ok "Completed Successfully!\n"
