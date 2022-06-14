#!/usr/bin/env bash -ex
LATEST=$(curl -sL https://api.github.com/repos/louislam/uptime-kuma/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
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
    read -p "This will Update ${APP} to ${LATEST}. Proceed(y/n)?" yn
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


msg_info "Stopping ${APP}"
sudo systemctl stop uptime-kuma &>/dev/null
msg_ok "Stopped ${APP}"

cd /opt/uptime-kuma

msg_info "Pulling ${APP} ${LATEST}"
git fetch &>/dev/null
git checkout $LATEST &>/dev/null
git pull &>/dev/null
msg_ok "Pulled ${APP} ${LATEST}"

msg_info "Updating ${APP} to ${LATEST} (Patience)"
npm ci &>/dev/null
msg_ok "Updated ${APP}"

msg_info "Starting ${APP}"
sudo systemctl start uptime-kuma &>/dev/null
msg_ok "Started ${APP}"

msg_ok "Done!"
