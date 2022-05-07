#!/usr/bin/env bash
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
APP="NocoDB"
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
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  exit $EXIT
}

while true; do
    read -p "This will Update ${APP}. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${YW}
  _   _                 _____  ____  
 | \ | |               |  __ \|  _ \ 
 |  \| | ___ v3___ ___ | |  | | |_) |
 |     |/ _ \ / __/ _ \| |  | |  _ < 
 | |\  | (_) | (_| (_) | |__| | |_) |
 |_| \_|\___/ \___\___/|_____/|____/ 
           UPDATE
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

msg_info "Updating ${APP}"
cd /opt/nocodb
npm uninstall -s --save nocodb &>/dev/null
npm install -s --save nocodb &>/dev/null
msg_ok "Updated ${APP}"

read -p "${APP} LXC needs to reboot to apply the update. Reboot now? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    reboot=yes
else
    reboot=no
fi

if [ "$reboot" == "yes" ]; then 
msg_info "Rebooting ${APP} LXC"
reboot
fi

if [ "$reboot" == "no" ]; then 
msg_ok "Finished Updating ${APP}. Reboot to apply the update."
fi
