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
APP="CrowdSec"
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
    read -p "This will Install ${APP}. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${BL}
   _____                      _  _____           
  / ____|                    | |/ ____|          
 | |     _ __ _____      ____| | (___   ___  ___ 
 | | v3 |  __/ _ \ \ /\ / / _  |\___ \ / _ \/ __|
 | |____| | | (_) \ V  V / (_| |____) |  __/ (__ 
  \_____|_|  \___/ \_/\_/ \__ _|_____/ \___|\___|
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

msg_info "Setting up ${APP} Repository"
apt-get update &>/dev/null
apt-get install -y gnupg &>/dev/null
curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash &>/dev/null
msg_ok "Setup ${APP} Repository"

msg_info "Installing ${APP}"
apt-get update &>/dev/null
apt-get install -y crowdsec &>/dev/null
msg_ok "Installed ${APP}"

msg_info "Installing ${APP} Common Bouncer"
apt-get install -y crowdsec-firewall-bouncer-iptables &>/dev/null
msg_ok "Installed ${APP} Common Bouncer"

msg_ok "Completed Successfully!\n"
