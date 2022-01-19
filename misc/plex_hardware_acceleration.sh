#!/usr/bin/env bash

while true; do
    read -p "This will add Hardware Acceleration Support to your Plex Media Server LXC. 
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
CTID=$1
CTID_CONFIG_PATH=/etc/pve/lxc/${CTID}.conf
cat <<EOF >> $CTID_CONFIG_PATH
### Intel iGPU: ###
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.cgroup2.devices.allow: c 29:0 rwm
#lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file 0, 0
#lxc.mount.entry: /dev/dri/card0 dev/dri/card0 none bind,optional,create=file 0, 0
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir 0, 0
lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file 0, 0

### NVidia GPU: ###
#lxc.cgroup2.devices.allow: c 195:* rwm
#lxc.cgroup2.devices.allow: c 243:* rwm
#lxc.mount.entry: /dev/nvidia0 dev/nvidia0 none bind,optional,create=file
#lxc.mount.entry: /dev/nvidiactl dev/nvidiactl none bind,optional,create=file
#lxc.mount.entry: /dev/nvidia-uvm dev/nvidia-uvm none bind,optional,create=file
#lxc.mount.entry: /dev/nvidia-modeset dev/nvidia-modeset none bind,optional,create=file
#lxc.mount.entry: /dev/nvidia-uvm-tools dev/nvidia-uvm-tools none bind,optional,create=file
#lxc.cgroup2.devices.allow: c 226:0 rwm
#lxc.cgroup2.devices.allow: c 226:128 rwm
#lxc.cgroup2.devices.allow: c 29:0 rwm
#lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file 0, 0
EOF
echo -e "\e[1;33m Finished....Please Reboot the LXC to apply the changes \e[0m"

# Plex can transcode media files on the fly. By default they use the CPU.
# All Intel CPU’s since Sandy Bridge released in 2011 have hardware acceleration for H.264 built in.
# So if your CPU supports Quick Sync you can speed up transcoding and reduce load by running the 
# following in the Proxmox web shell (replace 106 with your LXC ID)
# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/plex_hardware_acceleration.sh)" -s 106
# Reboot the LXC to apply the changes

