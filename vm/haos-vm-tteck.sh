#!/usr/bin/env bash
echo -e "Loading..."
GEN_MAC=$(echo '00 60 2f'$(od -An -N3 -t xC /dev/urandom) | sed -e 's/ /:/g' | tr '[:lower:]' '[:upper:]')
NEXTID=$(pvesh get /cluster/nextid)
STABLE=$(curl -s https://raw.githubusercontent.com/home-assistant/version/master/stable.json | grep "ova" | awk '{print substr($2, 2, length($2)-3) }')
BETA=$(curl -s https://raw.githubusercontent.com/home-assistant/version/master/beta.json | grep "ova" | awk '{print substr($2, 2, length($2)-3) }')
DEV=$(curl -s https://raw.githubusercontent.com/home-assistant/version/master/dev.json | grep "ova" | awk '{print substr($2, 2, length($2)-3) }')
LATEST=$(curl -s https://api.github.com/repos/home-assistant/operating-system/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
HA=`echo "\033[1;34m"`
RD=`echo "\033[01;31m"`
BGN=`echo "\033[4;92m"`
GN=`echo "\033[1;92m"`
DGN=`echo "\033[32m"`
CL=`echo "\033[m"`
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
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
if [ `pveversion | grep "pve-manager/7" | wc -l` -ne 1 ]; then
        echo "⚠ This version of Proxmox Virtual Environment is not supported"
        echo "Requires PVE Version: 7.XX"
        echo "Exiting..."
        sleep 3
        exit
fi
if (whiptail --title "HOME ASSISTANT OS VM" --yesno "This will create a New Home Assistant OS VM. Proceed?" 10 58); then
    echo "User selected Yes"
else
    clear
    echo -e "⚠ User exited script \n"
    exit
fi
function header_info {
cat <<"EOF"
    __  __                        ___              _      __              __     ____  _____
   / / / /___  ____ ___  ___ v4  /   |  __________(_)____/ /_____ _____  / /_   / __ \/ ___/
  / /_/ / __ \/ __ `__ \/ _ \   / /| | / ___/ ___/ / ___/ __/ __ `/ __ \/ __/  / / / /\__ \ 
 / __  / /_/ / / / / / /  __/  / ___ |(__  |__  ) (__  ) /_/ /_/ / / / / /_   / /_/ /___/ / 
/_/ /_/\____/_/ /_/ /_/\___/  /_/  |_/____/____/_/____/\__/\__,_/_/ /_/\__/   \____//____/  

EOF
}
function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}
function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}
function msg_error() {
    local msg="$1"
    echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

function default_settings() {
        echo -e "${DGN}Using HAOS Version: ${BGN}${STABLE}${CL}"
        BRANCH=${STABLE}
        echo -e "${DGN}Using Virtual Machine ID: ${BGN}$NEXTID${CL}"
        VMID=$NEXTID
        echo -e "${DGN}Using Hostname: ${BGN}haos${STABLE}${CL}"
        HN=haos${STABLE}
        echo -e "${DGN}Allocated Cores: ${BGN}2${CL}"
        CORE_COUNT="2"
        echo -e "${DGN}Allocated RAM: ${BGN}4096${CL}"
        RAM_SIZE="4096"
        echo -e "${DGN}Using Bridge: ${BGN}vmbr0${CL}"
        BRG="vmbr0"
        echo -e "${DGN}Using MAC Address: ${BGN}$GEN_MAC${CL}"
        MAC=$GEN_MAC
        echo -e "${DGN}Using VLAN: ${BGN}Default${CL}"
        VLAN=""
        echo -e "${DGN}Start VM when completed: ${BGN}yes${CL}"
        START_VM="yes"
        echo -e "${BL}Creating a HAOS VM using the above default settings${CL}"
}
function advanced_settings() {
BRANCH=$(whiptail --title "HAOS VERSION" --radiolist "Choose Version" --cancel-button Exit-Script 10 58 4 \
"$STABLE" "Stable" ON \
"$BETA" "Beta" OFF \
"$DEV" "Dev" OFF \
"$LATEST" "Latest" OFF \
3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then echo -e "${DGN}Using HAOS Version: ${BGN}$BRANCH${CL}"; fi
VMID=$(whiptail --inputbox "Set Virtual Machine ID" 8 58 $NEXTID --title "VIRTUAL MACHINE ID" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $VMID ]; then VMID="$NEXTID"; echo -e "${DGN}Virtual Machine: ${BGN}$VMID${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Virtual Machine ID: ${BGN}$VMID${CL}"; fi;
fi
VM_NAME=$(whiptail --inputbox "Set Hostname" 8 58 haos${BRANCH} --title "HOSTNAME" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $VM_NAME ]; then HN="haos${BRANCH}"; echo -e "${DGN}Using Hostname: ${BGN}$HN${CL}";
else
  if [ $exitstatus = 0 ]; then HN=$(echo ${VM_NAME,,} | tr -d ' '); echo -e "${DGN}Using Hostname: ${BGN}$HN${CL}"; fi;
fi
CORE_COUNT=$(whiptail --inputbox "Allocate CPU Cores" 8 58 2 --title "CORE COUNT" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $CORE_COUNT ]; then CORE_COUNT="2"; echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}"; fi;
fi
RAM_SIZE=$(whiptail --inputbox "Allocate RAM in MiB" 8 58 4096 --title "RAM" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $RAM_SIZE ]; then RAM_SIZE="4096"; echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}"; fi;
fi
BRG=$(whiptail --inputbox "Set a Bridge" 8 58 vmbr0 --title "BRIDGE" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $BRG ]; then BRG="vmbr0"; echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}";
else
  if [ $exitstatus = 0 ]; then echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}"; fi;
fi
MAC1=$(whiptail --inputbox "Set a MAC Address" 8 58 $GEN_MAC --title "MAC ADDRESS" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ -z $MAC1 ]; then MAC="$GEN_MAC"; echo -e "${DGN}Using MAC Address: ${BGN}$MAC${CL}";
else
 if [ $exitstatus = 0 ]; then MAC="$MAC1"; echo -e "${DGN}Using MAC Address: ${BGN}$MAC1${CL}"; fi
fi
VLAN1=$(whiptail --inputbox "Set a Vlan(leave blank for default)" 8 58 --title "VLAN" --cancel-button Exit-Script 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
  if [ -z $VLAN1 ]; then VLAN1="Default" VLAN="";
    echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
else
    VLAN=",tag=$VLAN1"
    echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
  fi  
fi
if (whiptail --title "START VIRTUAL MACHINE" --yesno "Start VM when completed?" 10 58); then
    echo -e "${DGN}Start VM when completed: ${BGN}yes${CL}"
    START_VM="yes"
else
    echo -e "${DGN}Start VM when completed: ${BGN}no${CL}"
    START_VM="no"
fi
if (whiptail --title "ADVANCED SETTINGS COMPLETE" --yesno "Ready to create HAOS ${BRANCH} VM?" --no-button Do-Over 10 58); then
    echo -e "${RD}Creating a HAOS VM using the above advanced settings${CL}"
else
  clear
  header_info
  echo -e "${RD}Using Advanced Settings${CL}"
  advanced_settings
fi
}
function start_script() {
if (whiptail --title "SETTINGS" --yesno "Use Default Settings?" --no-button Advanced 10 58); then
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
STORAGE_MENU+=( "$TAG" "$ITEM" "OFF" )
done < <(pvesm status -content images | awk 'NR>1')
VALID=$(pvesm status -content images | awk 'NR>1')
if [ -z "$VALID" ]; then
msg_error "Unable to detect a valid storage location."
  exit
elif [ $((${#STORAGE_MENU[@]}/3)) -eq 1 ]; then
  STORAGE=${STORAGE_MENU[0]}
else
  while [ -z "${STORAGE:+x}" ]; do
    STORAGE=$(whiptail --title "Storage Pools" --radiolist \
    "Which storage pool you would like to use for the HAOS VM?\n\n" \
    16 $(($MSG_MAX_LENGTH + 23)) 6 \
    "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit
  done
fi
msg_ok "Using ${CL}${BL}$STORAGE${CL} ${GN}for Storage Location."
msg_ok "Virtual Machine ID is ${CL}${BL}$VMID${CL}."
msg_info "Getting URL for Home Assistant ${BRANCH} Disk Image"
if [ "$BRANCH" == "$DEV" ]; then 
URL=https://os-builds.home-assistant.io/${BRANCH}/haos_ova-${BRANCH}.qcow2.xz
else
URL=https://github.com/home-assistant/operating-system/releases/download/${BRANCH}/haos_ova-${BRANCH}.qcow2.xz
fi
sleep 2
msg_ok "${CL}${BL}${URL}${CL}"
wget -q --show-progress $URL
echo -en "\e[1A\e[0K"
FILE=$(basename $URL)
msg_ok "Downloaded ${CL}${BL}haos_ova-${BRANCH}.qcow2.xz${CL}"
msg_info "Extracting KVM Disk Image"
unxz $FILE
STORAGE_TYPE=$(pvesm status -storage $STORAGE | awk 'NR>1 {print $2}')
case $STORAGE_TYPE in
  nfs|dir)
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
msg_ok "Extracted KVM Disk Image"
msg_info "Creating HAOS VM"
qm create $VMID -agent 1 -tablet 0 -localtime 1 -bios ovmf -cores $CORE_COUNT -memory $RAM_SIZE -name $HN -net0 virtio,bridge=$BRG,macaddr=$MAC$VLAN \
  -onboot 1 -ostype l26 -scsihw virtio-scsi-pci
pvesm alloc $STORAGE $VMID $DISK0 4M 1>&/dev/null
qm importdisk $VMID ${FILE%.*} $STORAGE ${DISK_IMPORT:-} 1>&/dev/null
qm set $VMID \
  -efidisk0 ${DISK0_REF},efitype=4m,size=4M \
  -scsi0 ${DISK1_REF},discard=on,size=32G,ssd=1 >/dev/null
qm set $VMID \
  -boot order=scsi0 >/dev/null
qm set $VMID -description "# Home Assistant OS
### https://github.com/tteck/Proxmox
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/D1D7EP4GF)" >/dev/null
msg_ok "Created HAOS VM ${CL}${BL}(${HN})"
if [ "$START_VM" == "yes" ]; then
msg_info "Starting Home Assistant OS VM"
qm start $VMID
msg_ok "Started Home Assistant OS VM"
fi
msg_ok "Completed Successfully!\n"
