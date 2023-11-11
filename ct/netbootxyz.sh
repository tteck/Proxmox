#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
               __  __                __                  
   ____  ___  / /_/ /_  ____  ____  / /_  _  ____  ______
  / __ \/ _ \/ __/ __ \/ __ \/ __ \/ __/ | |/_/ / / /_  /
 / / / /  __/ /_/ /_/ / /_/ / /_/ / /__ _>  </ /_/ / / /_
/_/ /_/\___/\__/_.___/\____/\____/\__(_)_/|_|\__, / /___/
                                            /____/                                                                                                   
EOF
}
header_info
echo -e "Loading..."
APP="netboot.xyz"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"
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
header_info
if [[ ! -d /opt/netboot.xyz ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Stopping ${APP}"
systemctl disable netbootxyz.service &>/dev/null
systemctl stop netbootxyz
sleep 1
msg_ok "Stopped ${APP}"

msg_info "Backing up Data"
cp -R /opt/netboot.xyz/config config-backup
cp -R /opt/netboot.xyz/assets assets-backup
sleep 1
msg_ok "Backed up Data"

RELEASE=$(curl -sX GET "https://api.github.com/repos/netbootxyz/netboot.xyz/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
msg_info "Updating netboot.xyz to ${RELEASE}"
curl --silent -o ${RELEASE}.tar.gz -L "https://github.com/netbootxyz/netboot.xyz/archive/${RELEASE}.tar.gz" &>/dev/null
tar xvzf ${RELEASE}.tar.gz &>/dev/null
VER=$(curl -s https://api.github.com/repos/netbootxyz/netboot.xyz/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 2, length($2)-3) }')

if [ ! -d "/opt/netboot.xyz" ]; then
  mv netboot.xyz-${VER} /opt/netboot.xyz
else
  cp -R netboot.xyz-${VER}/* /opt/netboot.xyz
fi

service_path="/etc/systemd/system/netbootxyz.service"
echo "[Unit]
Description=netboot.xyz
After=network.target
[Service]
Restart=always
RestartSec=5
Type=simple
User=root
WorkingDirectory=/opt/netboot.xyz
ExecStart="ansible-playbook" -i inventory site.yml
TimeoutStopSec=30
[Install]
WantedBy=multi-user.target" >$service_path
msg_ok "Updated netboot.xyz to ${RELEASE}"

msg_info "Restoring Data"
cp -R config-backup/* /opt/netboot.xyz/config
cp -R assets-backup/* /opt/netboot.xyz/assets
sleep 1
msg_ok "Restored Data"

msg_info "Cleanup"
rm -rf ${RELEASE}.tar.gz
rm -rf netboot.xyz-${VER}
rm -rf config-backup
rm -rf assets-backup
sleep 1
msg_ok "Cleaned"

msg_info "Starting ${APP}"
systemctl enable --now netbootxyz.service &>/dev/null
sleep 2
msg_ok "Started ${APP}"
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:3000${CL} \n"
