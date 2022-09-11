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
APP="Homepage"
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
cat << "EOF"
    __  __                                          
   / / / /___  ____ ___  ___  ____  ____ _____ ____ 
  / /_/ / __ \/ __ `__ \/ _ \/ __ \/ __ `/ __ `/ _ \
 / __  / /_/ / / / / / /  __/ /_/ / /_/ / /_/ /  __/
/_/ /_/\____/_/ /_/ /_/\___/ .___/\__,_/\__, /\___/ 
                          /_/  UPDATE  /____/       
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
if ! command -v pnpm >/dev/null 2>&1; then
  npm install -g pnpm &>/dev/null
fi
cd /opt/homepage 
systemctl stop homepage 
git pull --force &>/dev/null
pnpm install &>/dev/null
pnpm build &>/dev/null
systemctl start homepage
msg_ok "Updated ${APP}"
