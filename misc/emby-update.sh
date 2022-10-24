#!/usr/bin/env bash
LATEST=$(curl -sL https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
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
APP="Emby"
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
cat << "EOF"
    ______          __         
   / ____/___ ___  / /_  __  __
  / __/ / __  __ \/ __ \/ / / /
 / /___/ / / / / / /_/ / /_/ / 
/_____/_/ /_/ /_/_.___/\__, /  
         UPDATE       /____/   
EOF
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

msg_info "Updating ${APP}"
wget https://github.com/MediaBrowser/Emby.Releases/releases/download/${LATEST}/emby-server-deb_${LATEST}_amd64.deb &>/dev/null
systemctl stop emby-server
dpkg -i emby-server-deb_${LATEST}_amd64.deb &>/dev/null
systemctl start emby-server
rm emby-server-deb_${LATEST}_amd64.deb
msg_ok "Updated ${APP}"
