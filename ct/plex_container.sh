#!/usr/bin/env bash

while true; do
    read -p "This will create a New Plex Media Server LXC Container. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
set -o errexit  
set -o errtrace
set -o nounset  
set -o pipefail 
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
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
  if [ ! -z ${MOUNT+x} ]; then
    pct unmount $CTID
  fi
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
function load_module() {
  if ! $(lsmod | grep -Fq $1); then
    modprobe $1 &>/dev/null || \
      die "Failed to load '$1' module."
  fi
  MODULES_PATH=/etc/modules
  if ! $(grep -Fxq "$1" $MODULES_PATH); then
    echo "$1" >> $MODULES_PATH || \
      die "Failed to add '$1' module to load at boot."
  fi
}
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null

wget -qL https://raw.githubusercontent.com/tteck/Proxmox/main/setup/plex_setup.sh

load_module overlay

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
done < <(pvesm status -content rootdir | awk 'NR>1')
if [ $((${#STORAGE_MENU[@]}/3)) -eq 0 ]; then
  warn "'Container' needs to be selected for at least one storage location."
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
info "Using '$STORAGE' for Storage Location."

CTID=$(pvesh get /cluster/nextid)
info "Container ID is $CTID."

echo -e "${CHECKMARK} \e[1;92m Updating LXC Template List... \e[0m"
pveam update >/dev/null
echo -e "${CHECKMARK} \e[1;92m Downloading LXC Template... \e[0m"
OSTYPE=ubuntu
OSVERSION=${OSTYPE}-20.04
mapfile -t TEMPLATES < <(pveam available -section system | sed -n "s/.*\($OSVERSION.*\)/\1/p" | sort -t - -k 2 -V)
TEMPLATE="${TEMPLATES[-1]}"
pveam download local $TEMPLATE >/dev/null ||
  die "A problem occured while downloading the LXC template."

STORAGE_TYPE=$(pvesm status -storage $STORAGE | awk 'NR>1 {print $2}')
case $STORAGE_TYPE in
  dir|nfs)
    DISK_EXT=".raw"
    DISK_REF="$CTID/"
    ;;
  zfspool)
    DISK_PREFIX="subvol"
    DISK_FORMAT="subvol"
    ;;
esac
DISK=${DISK_PREFIX:-vm}-${CTID}-disk-0${DISK_EXT-}
ROOTFS=${STORAGE}:${DISK_REF-}${DISK}

echo -e "${CHECKMARK} \e[1;92m Creating LXC Container... \e[0m"
DISK_SIZE=8G
pvesm alloc $STORAGE $CTID $DISK $DISK_SIZE --format ${DISK_FORMAT:-raw} >/dev/null
if [ "$STORAGE_TYPE" == "zfspool" ]; then
  warn "Some containers may not work properly due to ZFS not supporting 'fallocate'."
else
  mkfs.ext4 $(pvesm path $ROOTFS) &>/dev/null
fi
ARCH=$(dpkg --print-architecture)
HOSTNAME=plex
TEMPLATE_STRING="local:vztmpl/${TEMPLATE}"
pct create $CTID $TEMPLATE_STRING -arch $ARCH -features nesting=1 \
  -hostname $HOSTNAME -net0 name=eth0,bridge=vmbr0,ip=dhcp -onboot 1 -cores 2 -memory 2048\
  -ostype $OSTYPE -rootfs $ROOTFS,size=$DISK_SIZE -storage $STORAGE >/dev/null

LXC_CONFIG=/etc/pve/lxc/${CTID}.conf
cat <<EOF >> $LXC_CONFIG
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.cgroup2.devices.allow: c 29:0 rwm
lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
lxc.mount.entry: /dev/dri/renderD128 dev/renderD128 none bind,optional,create=file
EOF

MOUNT=$(pct mount $CTID | cut -d"'" -f 2)
ln -fs $(readlink /etc/localtime) ${MOUNT}/etc/localtime
pct unmount $CTID && unset MOUNT

echo -e "${CHECKMARK} \e[1;92m Starting LXC Container... \e[0m"
pct start $CTID
pct push $CTID plex_setup.sh /plex_setup.sh -perms 755
pct exec $CTID /plex_setup.sh

IP=$(pct exec $CTID ip a s dev eth0 | sed -n '/inet / s/\// /p' | awk '{print $2}')
info "Successfully Created Plex Media Server LXC to $CTID."
echo -e "\e[1;92m Plex Media Server should be reachable by going to the following URL.
             http://${IP}:32400/web
\e[0m"
