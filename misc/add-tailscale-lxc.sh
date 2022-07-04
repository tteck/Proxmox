#!/usr/bin/env bash
echo -e "\e[1;33mThis script will add Tailscale to an existing LXC Container ONLY\e[0m"
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

function error_exit() {
  trap - ERR
  local reason="Unknown failure occured."
  local msg="${1:-$reason}"
  local flag="\e[1;31m‼ ERROR\e[0m $EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

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
