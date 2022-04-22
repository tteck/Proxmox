#!/usr/bin/env bash -ex
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
APP="Uptime Kuma"
while true; do
    read -p "This will Update ${APP} LXC. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${DGN}
  _    _       _   _                  _  __                     
 | |  | |     | | (_)                | |/ /                     
 | |  | |_v3_ | |_ _ _ __ ___   ___  | ' /_   _ _ __ ___   __ _ 
 | |  | |  _ \| __| |  _   _ \ / _ \ |  <| | | |  _   _ \ / _  |
 | |__| | |_) | |_| | | | | | |  __/ | . \ |_| | | | | | | (_| |
  \____/| .__/ \__|_|_| |_| |_|\___| |_|\_\__,_|_| |_| |_|\__,_|
        | |                                                     
        |_|  UPDATE                                                   
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


msg_info "Stopping Uptime Kuma"
sudo systemctl stop uptime-kuma &>/dev/null
msg_ok "Stopped Uptime Kuma"

cd /opt/uptime-kuma

msg_info "Pulling Uptime Kuma"
git fetch &>/dev/null
git checkout master &>/dev/null
git pull &>/dev/null
msg_ok "Pulled Uptime Kuma"

msg_info "Updating Uptime Kuma (Patience)"
npm ci &>/dev/null
msg_ok "Updated Uptime Kuma"

msg_info "Starting Uptime Kuma"
sudo systemctl start uptime-kuma &>/dev/null
msg_ok "Started Uptime Kuma"

msg_ok "Done!"
