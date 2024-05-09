#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
 _       ___           ______                     __
| |     / (_)_______  / ____/_  ______ __________/ /
| | /| / / / ___/ _ \/ / __/ / / / __ `/ ___/ __  / 
| |/ |/ / / /  /  __/ /_/ / /_/ / /_/ / /  / /_/ /  
|__/|__/_/_/   \___/\____/\__,_/\__,_/_/   \__,_/   
                                                    
EOF
}
header_info
echo -e "Loading..."
APP="Wireguard"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="11"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
if [[ ! -d /etc/pivpn/wireguard ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
UPD=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 2 \
  "1" "Update ${APP} LXC" ON \
  "2" "Install WGDashboard" OFF \
  3>&1 1>&2 2>&3)
header_info
if [ "$UPD" == "1" ]; then
msg_info "Updating ${APP} LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated ${APP} LXC"
exit
fi
if [ "$UPD" == "2" ]; then
  if [[ -f /etc/systemd/system/wg-dashboard.service ]]; then
    cd /etc/wgdashboard/src
    chmod u+x wgd.sh
    ./wgd.sh update
    msg_ok "Updated Successfully"
    exit 
  fi
IP=$(hostname -I | awk '{print $1}')
msg_info "Installing Python3-pip"
apt-get install -y python3-pip &>/dev/null
pip install flask &>/dev/null
pip install ifcfg &>/dev/null
pip install flask_qrcode &>/dev/null
pip install icmplib &>/dev/null
msg_ok "Installed Python3-pip"

msg_info "Installing WGDashboard"
WGDREL=$(curl -s https://api.github.com/repos/donaldzou/WGDashboard/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 2, length($2)-3) }')

git clone -b ${WGDREL} https://github.com/donaldzou/WGDashboard.git /etc/wgdashboard &>/dev/null
cd /etc/wgdashboard/src
chmod u+x wgd.sh
./wgd.sh install &>/dev/null
chmod -R 755 /etc/wireguard
msg_ok "Installed WGDashboard"

msg_info "Creating Service"
service_path="/etc/systemd/system/wg-dashboard.service"
echo "[Unit]
After=systemd-networkd.service

[Service]
WorkingDirectory=/etc/wgdashboard/src
ExecStart=/usr/bin/python3 /etc/wgdashboard/src/dashboard.py
Restart=always


[Install]
WantedBy=default.target" >$service_path
chmod 664 /etc/systemd/system/wg-dashboard.service
systemctl daemon-reload
systemctl enable wg-dashboard.service &>/dev/null
systemctl start wg-dashboard.service &>/dev/null
msg_ok "Created Service"
echo -e "WGDashboard should be reachable by going to the following URL.
         ${BL}http://${IP}:10086${CL} admin|admin \n"
exit
fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
