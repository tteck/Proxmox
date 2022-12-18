#!/usr/bin/env bash
clear
if command -v pveversion >/dev/null 2>&1; then echo -e "⚠️  Can't Run from the Proxmox Shell"; exit; fi
set -e
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
BGN=$(echo "\033[4;92m")
GN=$(echo "\033[1;92m")
DGN=$(echo "\033[32m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
  cat <<"EOF"
                                _           _     _              _       ___               
  /\  /\___  _ __ ___   ___    /_\  ___ ___(_)___| |_ __ _ _ __ | |_    / __\___  _ __ ___ 
 / /_/ / _ \| '_ ` _ \ / _ \  //_\\/ __/ __| / __| __/ _` | '_ \| __|  / /  / _ \| '__/ _ \
/ __  / (_) | | | | | |  __/ /  _  \__ \__ \ \__ \ || (_| | | | | |_  / /__| (_) | | |  __/
\/ /_/ \___/|_| |_| |_|\___| \_/ \_/___/___/_|___/\__\__,_|_| |_|\__| \____/\___/|_|  \___|
                                     UPDATE
EOF
function msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}
function msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}
msg_info "Stopping Home Assistant"
systemctl stop homeassistant 
msg_ok "Stopped Home Assistant"

read -r -p "Use the Beta Branch? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
  BR="--pre "
else
  BR=""
fi
msg_info "Updating Home Assistant"
source /srv/homeassistant/bin/activate 
pip install ${BR}--upgrade homeassistant &>/dev/null
msg_ok "Updated Home Assistant"
set +e
msg_info "Setting Dependency Versions"
DIR=/srv/homeassistant/lib/python3.10
if [ -d "$DIR" ]; then
sed -i "s/dbus-fast==1.75.0/dbus-fast==1.82.0/g" /srv/homeassistant/lib/python3.10/site-packages/homeassistant/package_constraints.txt
sed -i "s/dbus-fast==1.75.0/dbus-fast==1.82.0/g" /srv/homeassistant/lib/python3.10/site-packages/homeassistant/components/bluetooth/manifest.json
sed -i "s/bleak==0.19.2/bleak==0.19.5/g" /srv/homeassistant/lib/python3.10/site-packages/homeassistant/package_constraints.txt
sed -i "s/bleak==0.19.2/bleak==0.19.5/g" /srv/homeassistant/lib/python3.10/site-packages/homeassistant/components/bluetooth/manifest.json
else
sed -i "s/dbus-fast==1.75.0/dbus-fast==1.82.0/g" /srv/homeassistant/lib/python3.9/site-packages/homeassistant/package_constraints.txt
sed -i "s/dbus-fast==1.75.0/dbus-fast==1.82.0/g" /srv/homeassistant/lib/python3.9/site-packages/homeassistant/components/bluetooth/manifest.json
sed -i "s/bleak==0.19.2/bleak==0.19.5/g" /srv/homeassistant/lib/python3.9/site-packages/homeassistant/package_constraints.txt
sed -i "s/bleak==0.19.2/bleak==0.19.5/g" /srv/homeassistant/lib/python3.9/site-packages/homeassistant/components/bluetooth/manifest.json
fi
msg_ok "Set Dependency Versions"
set -e
msg_info "Starting Home Assistant"
systemctl start homeassistant
msg_ok "Started Home Assistant"
msg_ok "Update Successful"
