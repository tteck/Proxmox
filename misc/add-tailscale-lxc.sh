#!/usr/bin/env bash
echo -e "\e[1;33m This script will add Tailscale to an existing LXC Container ONLY\e[0m"
while true; do
    read -p "Did you replace 106 with your LXC ID? Proceed(y/n)?" yn
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

CTID=$1
CTID_CONFIG_PATH=/etc/pve/lxc/${CTID}.conf
cat <<EOF >> $CTID_CONFIG_PATH
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
EOF

msg "⏳ Installing Tailscale..."
lxc-attach -n $CTID -- bash -c "$(curl -fsSL https://tailscale.com/install.sh)" &>/dev/null || exit
msg "⌛ Installed Tailscale"
sleep 2
msg "\e[1;32m ✔ Completed Successfully!\e[0m"
msg "\e[1;31m Reboot ${CTID} LXC to apply the changes, then run tailscale up in the LXC console\e[0m"
