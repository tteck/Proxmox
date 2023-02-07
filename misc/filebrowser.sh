#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
    cat <<"EOF"
    _______ __     ____                                   
   / ____(_) /__  / __ )_________ _      __________  _____
  / /_  / / / _ \/ __  / ___/ __ \ | /| / / ___/ _ \/ ___/
 / __/ / / /  __/ /_/ / /  / /_/ / |/ |/ (__  )  __/ /    
/_/   /_/_/\___/_____/_/   \____/|__/|__/____/\___/_/     
                                                          
EOF
}
IP=$(hostname -I | awk '{print $1}')
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
APP="FileBrowser"
hostname="$(hostname)"
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
clear
header_info
while true; do
    read -p "This will Install ${APP} on $hostname. Proceed(y/n)?" yn
    case $yn in
    [Yy]*) break ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
done
clear
header_info
function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_info "Installing ${APP}"
bash <(curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh) &>/dev/null
filebrowser config init -a '0.0.0.0' &>/dev/null
filebrowser config set -a '0.0.0.0' &>/dev/null
filebrowser users add admin changeme --perm.admin &>/dev/null
msg_ok "Installed ${APP} on $hostname"

msg_info "Creating Service"
service_path="/etc/systemd/system/filebrowser.service"
echo "[Unit]
Description=Filebrowser
After=network-online.target

[Service]
User=root
WorkingDirectory=/root/
ExecStart=/usr/local/bin/filebrowser -r /

[Install]
WantedBy=default.target" >$service_path

systemctl enable --now filebrowser.service &>/dev/null
msg_ok "Created Service"

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://$IP:8080${CL} \n"
