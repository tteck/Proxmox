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
PY=$(ls /srv/homeassistant/lib/)
IP=$(hostname -I | awk '{print $1}')
if [[ "$PY" == "python3.9" ]]; then echo -e "⚠️  Python 3.9 is deprecated and will be removed in Home Assistant 2023.2"; fi
sleep 2
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

read -r -p "  Use the Beta Branch? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
  BR="--pre "
else
  BR=""
fi
msg_info "Updating Home Assistant"
source /srv/homeassistant/bin/activate 
pip install ${BR}--upgrade homeassistant &>/dev/null
msg_ok "Updated Home Assistant"

msg_info "Setting Dependency Versions"
sed -i "s/dbus-fast==1.75.0/dbus-fast==1.83.1/g" /srv/homeassistant/lib/$PY/site-packages/homeassistant/package_constraints.txt
sed -i "s/dbus-fast==1.75.0/dbus-fast==1.83.1/g" /srv/homeassistant/lib/$PY/site-packages/homeassistant/components/bluetooth/manifest.json
sed -i "s/bleak==0.19.2/bleak==0.19.5/g" /srv/homeassistant/lib/$PY/site-packages/homeassistant/package_constraints.txt
sed -i "s/bleak==0.19.2/bleak==0.19.5/g" /srv/homeassistant/lib/$PY/site-packages/homeassistant/components/bluetooth/manifest.json
msg_ok "Set Dependency Versions"

msg_info "Starting Home Assistant"
systemctl start homeassistant
msg_ok "Started Home Assistant"
msg_ok "Update Successful"
echo -e "\n  Go to http://${IP}:8123 \n"
