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

while true; do
    read -p "This will create a New Home Assistant OS VM. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear

function header_info {
echo -e "${BL}
        _    _          ____   _____ 
       | |  | |   /\   / __ \ / ____|
       | |__| |  /  \ | |  | | (___  
       |  __  | / /\ \| |  | |\___ \ 
       | |  | |/ ____ \ |__| |____) |
       |_|  |_/_/    \_\____/|_____/ 
                               
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
		echo -e "${DGN}Using ID ${BGN}$NEXTID${CL}"
		VM_ID=$NEXTID
		echo -e "${DGN}Using Disk Size ${BGN}32GB${CL}"
		DISK_SIZE="32G"
		echo -e "${DGN}Using ${BGN}2vCPU${CL}"
		CORE_COUNT="2"
		echo -e "${DGN}Using ${BGN}4096MiB${CL}${GN} RAM${CL}"
		RAM_SIZE="4096"
}
function advanced_settings() {
        clear
        header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${YW}Enter the VM ID, or Press [ENTER] to automatically generate (${NEXTID}) "
        read VM_ID
        if [ -z $VM_ID ]; then VM_ID=$NEXTID; fi;
        echo -en "${DGN}Set VM ID To ${BL}$VM_ID${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using ID ${BGN}$VM_ID${CL}"
        echo -e "${YW}Enter a Disk Size, or Press [ENTER] for Default: 32Gb "
        read DISK_SIZE
        if [ -z $DISK_SIZE ]; then DISK_SIZE="32"; fi;
        if ! [[ $DISK_SIZE =~ $INTEGER ]] ; then echo "ERROR! DISK SIZE MUST HAVE INTEGER NUMBER!"; exit; fi;
        echo -en "${DGN}Set Disk Size To ${BL}$DISK_SIZE${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using ID ${BGN}$VM_ID${CL}"
        echo -e "${DGN}Using Disk Size ${BGN}$DISK_SIZE${CL}"
        echo -e "${YW}Allocate CPU cores, or Press [ENTER] for Default: 2 "
        read CORE_COUNT
        if [ -z $CORE_COUNT ]; then CORE_COUNT="2"; fi;
        echo -en "${DGN}Set Cores To ${BL}$CORE_COUNT${CL}"
echo -e " ${CM}${CL} \r"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using ID ${BGN}$VM_ID${CL}"
        echo -e "${DGN}Using Disk Size ${BGN}$DISK_SIZE${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
        echo -e "${YW}Allocate RAM in MiB, or Press [ENTER] for Default: 4096 "
        read RAM_SIZE
        if [ -z $RAM_SIZE ]; then RAM_SIZE="4096"; fi;
        echo -en "${DGN}Set RAM To ${BL}$RAM_SIZE${CL}"
echo -e " ${CM}${CL} \n"
sleep 1
clear
header_info
        echo -e "${RD}Using Advanced Settings${CL}"
        echo -e "${DGN}Using ID ${BGN}$VM_ID${CL}"
        echo -e "${DGN}Using Disk Size ${BGN}$DISK_SIZE${CL}"
        echo -e "${DGN}Using ${BGN}${CORE_COUNT}vCPU${CL}"
        echo -e "${DGN}Using ${BGN}${RAM_SIZE}MiB${CL}${GN} RAM${CL}"

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
  [ ! -z ${VMID-} ] && cleanup_vmid
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
  warn "'Disk image' needs to be selected for at least one storage location."
  die "Unable to detect valid storage location."
elif [ $((${#STORAGE_MENU[@]}/3)) -eq 1 ]; then
  STORAGE=${STORAGE_MENU[0]}
else
  while [ -z "${STORAGE:+x}" ]; do
    STORAGE=$(whiptail --title "Storage Pools" --radiolist \
    "Which storage pool you would like to use for the container?\n\n" \
    16 $(($MSG_MAX_LENGTH + 23)) 6 \
    "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit
  done
fi
msg_ok "Using ${CL}${BL}$STORAGE${CL} ${GN}for Storage Location."
msg_ok "Virtual Machine ID is ${CL}${BL}$VM_ID${CL}."
msg_info "Getting URL for Latest Home Assistant Disk Image"
RELEASE_TYPE=qcow2
URL=$(cat<<EOF | python3
import requests
url = "https://api.github.com/repos/home-assistant/operating-system/releases"
r = requests.get(url).json()
if "message" in r:
    exit()
for release in r:
    if release["prerelease"]:
        continue
    for asset in release["assets"]:
        if asset["name"].find("$RELEASE_TYPE") != -1:
            image_url = asset["browser_download_url"]
            print(image_url)
            exit()
EOF
)
if [ -z "$URL" ]; then
  die "Github has returned an error. A rate limit may have been applied to your connection."
fi
msg_ok "Found URL for Latest Home Assistant Disk Image"
msg_ok "${CL}${BL}${URL}${CL}"
wget -q --show-progress $URL
echo -en "\e[1A\e[0K"
FILE=$(basename $URL)
msg_ok "Downloaded ${RELEASE_TYPE} Disk Image"
msg_info "Extracting Disk Image"
case $FILE in
  *"gz") gunzip -f $FILE ;;
  *"zip") gunzip -f -S .zip $FILE ;;
  *"xz") xz -d $FILE ;;
  *) die "Unable to handle file extension '${FILE##*.}'.";;
esac
STORAGE_TYPE=$(pvesm status -storage $STORAGE | awk 'NR>1 {print $2}')
case $STORAGE_TYPE in
  btrfs|nfs|dir)
        DISK_EXT=".qcow2"
        DISK_REF="$VM_ID/"
        IMPORT_OPT="-format qcow2"
esac
for i in {0,1}; do
  disk="DISK$i"
  eval DISK${i}=vm-${VM_ID}-disk-${i}${DISK_EXT:-}
  eval DISK${i}_REF=${STORAGE}:${DISK_REF:-}${!disk}
done
msg_ok "Extracted Disk Image"

msg_info "Creating HAOS VM"
VM_NAME=$(sed -e "s/\_//g" -e "s/.${RELEASE_TYPE}.*$//" <<< $FILE)
qm create $VM_ID -agent 1 -bios ovmf -cores ${CORE_COUNT} -memory ${RAM_SIZE} -name $VM_NAME -net0 virtio,bridge=vmbr0 \
  -onboot 1 -ostype l26 -scsihw virtio-scsi-pci
pvesm alloc $STORAGE $VM_ID $DISK0 128 1>&/dev/null
qm importdisk $VM_ID ${FILE%.*} $STORAGE ${IMPORT_OPT:-} 1>&/dev/null
qm set $VM_ID \
  -efidisk0 ${DISK0_REF},size=128K \
  -scsi0 ${DISK1_REF},size=${DISK_SIZE}G >/dev/null
qm set $VM_ID \
  -boot order=scsi0 >/dev/null
set +o errtrace
(
msg_ok "Created HAOS VM ${CL}${BL}${VM_NAME}"

msg_info "Adding Serial Port and Configuring Console"
trap '
  warn "Unable to configure serial port. VM is still functional."
  if [ "$(qm config $VM_ID | sed -n ''/serial0/p'')" != "" ]; then
    qm set $VM_ID --delete serial0 >/dev/null
  fi
  exit
  ' ERR
msg_ok "Added Serial Port and Configured Console"
  if [ "$(command -v kpartx)" = "" ]; then
    msg_info "Installing kpartx"
    apt-get update >/dev/null
    apt-get -qqy install kpartx &>/dev/null
    msg_ok "Installed kpartx"
  fi
  DISK1_PATH="$(pvesm path $DISK1_REF)"
  DISK1_PART1="$(kpartx -al $DISK1_PATH | awk 'NR==1 {print $1}')"
  DISK1_PART1_PATH="/dev/mapper/$DISK1_PART1"
  TEMP_MOUNT="${TEMP_DIR}/mnt"
  trap '
    findmnt $TEMP_MOUNT >/dev/null && umount $TEMP_MOUNT
    command -v kpartx >/dev/null && kpartx -d $DISK1_PATH
  ' EXIT
  kpartx -a $DISK1_PATH
  mkdir $TEMP_MOUNT
  mount $DISK1_PART1_PATH $TEMP_MOUNT
  sed -i 's/$/ console=ttyS0/' ${TEMP_MOUNT}/cmdline.txt
  qm set $VMID -serial0 socket >/dev/null
)
msg_info "Starting Home Assistant OS VM"
qm start $VM_ID
msg_ok "Started Home Assistant OS VM"

msg_ok "Completed Successfully!\n"
