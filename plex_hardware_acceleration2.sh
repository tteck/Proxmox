#!/usr/bin/env bash

while true; do
    read -p "This will add Hardware Acceleration Support (hopefully) to your Plex Media Server LXC. 
    Did you replace 106 with your LXC ID? Proceed(y/n)?" yn
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

CHAR_DEVS+=("1:1")
CHAR_DEVS+=("4:\([3-9]\|[1-5][0-9]\|6[0-3]\)")
CHAR_DEVS+=("4:\(6[4-9]\|[7-9][0-9]\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)")
CHAR_DEVS+=("10:200")
CHAR_DEVS+=("116:.*")
CHAR_DEVS+=("166:.*")
CHAR_DEVS+=("180:\([0-9]\|1[0-5]\)")
CHAR_DEVS+=("226:.*")
CHAR_DEVS+=("29:.*")
CHAR_DEVS+=("24[0-2]:.*")

for char_dev in ${CHAR_DEVS[@]}; do
  [ ! -z "${CHAR_DEV_STRING-}" ] && CHAR_DEV_STRING+=" -o"
  CHAR_DEV_STRING+=" -regex \".*/${char_dev}\""
done

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
HOOK_SCRIPT=${HOOK_SCRIPT//$'\n'/}

CTID=$1
CTID_CONFIG_PATH=/etc/pve/lxc/${CTID}.conf
sed '/autodev/d' $CTID_CONFIG_PATH >CTID.conf
cat CTID.conf >$CTID_CONFIG_PATH

cat <<EOF >> $CTID_CONFIG_PATH
lxc.autodev: 1
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
lxc.hook.autodev: bash -c '$HOOK_SCRIPT'
EOF
echo -e "\e[1;33m Finished....Please Reboot the LXC to apply the changes \e[0m"

# Plex can transcode media files on the fly. By default they use the CPU.
# All Intel CPU’s since Sandy Bridge released in 2011 have hardware acceleration for H.264 built in.
# So if your CPU supports Quick Sync you can speed up transcoding and reduce load by running the 
# following in the Proxmox web shell (replace 106 with your LXC ID)
# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/plex_hardware_acceleration2.sh)" -s 106
# Reboot the LXC to apply the changes
