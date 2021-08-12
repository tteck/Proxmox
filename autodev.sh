#!/usr/bin/env bash

# Setup script environment
set -o errexit  #Exit immediately if a pipeline returns a non-zero status
set -o errtrace #Trap ERR from shell functions, command substitutions, and commands from subshell
set -o nounset  #Treat unset variables as an error
set -o pipefail #Pipe will exit with last non-zero status if applicable
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
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}
function cleanup() {
  popd >/dev/null
  rm -rf $TEMP_DIR
}
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null

# Array of device types to enable in container
#CHAR_DEVS+=(major:minor)
CHAR_DEVS+=("1:1") #mem (physical memory access)
CHAR_DEVS+=("4:\([3-9]\|[1-5][0-9]\|6[0-3]\)") #tty* (virtual console, minor 3-63)
CHAR_DEVS+=("4:\(6[4-9]\|[7-9][0-9]\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)") #ttyS* (UART serial port, minor 64-255)
CHAR_DEVS+=("10:200") #net/tun (TAP/TUN network device)
CHAR_DEVS+=("116:.*") #(ALSA devices)
CHAR_DEVS+=("166:.*") #ttyACM* (ACM USB modems)
CHAR_DEVS+=("180:\([0-9]\|1[0-5]\)") #usb/hiddev* (UPS devices, minor 0-15)
CHAR_DEVS+=("188:.*") #ttyUSB* (USB serial converters)
CHAR_DEVS+=("189:.*") #bus/usb/* (USB serial converters - alternate devices)

# Proccess char device string
for char_dev in ${CHAR_DEVS[@]}; do
  [ ! -z "${CHAR_DEV_STRING-}" ] && CHAR_DEV_STRING+=" -o"
  CHAR_DEV_STRING+=" -regex \".*/${char_dev}\""
done

# Store autodev hook script in variable
read -r -d '' HOOK_SCRIPT <<- EOF || true
for char_dev in \$(find /sys/dev/char -regextype sed $CHAR_DEV_STRING); do
  dev="/dev/\$(sed -n "/DEVNAME/ s/^.*=\(.*\)$/\1/p" \${char_dev}/uevent)";
  mkdir -p \$(dirname \${LXC_ROOTFS_MOUNT}\${dev});
  for link in \$(udevadm info --query=property \$dev | sed -n "s/DEVLINKS=//p"); do
    mkdir -p \${LXC_ROOTFS_MOUNT}\$(dirname \$link);
    cp -dpR \$link \${LXC_ROOTFS_MOUNT}\${link};
  done;
  cp -dpR \$dev \${LXC_ROOTFS_MOUNT}\${dev};
done;
EOF
HOOK_SCRIPT=${HOOK_SCRIPT//$'\n'/} #Remove newline char from variable

# Remove autodev settings
CTID=$1
CTID_CONFIG_PATH=/etc/pve/lxc/${CTID}.conf
sed '/autodev/d' $CTID_CONFIG_PATH >CTID.conf
cat CTID.conf >$CTID_CONFIG_PATH

# Add autodev settings
cat <<EOF >> $CTID_CONFIG_PATH
lxc.autodev: 1
lxc.hook.autodev: bash -c '$HOOK_SCRIPT'
EOF