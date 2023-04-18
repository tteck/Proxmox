#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
            _               _       _ _      ___          _     _                         _ 
  /\  /\___(_)_ __ ___   __| | __ _| | |    /   \__ _ ___| |__ | |__   ___   __ _ _ __ __| |
 / /_/ / _ \ | '_ ` _ \ / _` |/ _` | | |   / /\ / _` / __| '_ \| '_ \ / _ \ / _` | '__/ _` |
/ __  /  __/ | | | | | | (_| | (_| | | |  / /_// (_| \__ \ | | | |_) | (_) | (_| | | | (_| |
\/ /_/ \___|_|_| |_| |_|\__,_|\__,_|_|_| /___,' \__,_|___/_| |_|_.__/ \___/ \__,_|_|  \__,_|
                                                                                            
EOF
}
header_info
echo -e "Loading..."
APP="Heimdall Dashboard"
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
  NET=dhcp
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
if [[ ! -d /opt/Heimdall ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Stopping ${APP}"
systemctl disable heimdall.service &>/dev/null
systemctl stop heimdall
sleep 1
msg_ok "Stopped ${APP}"

msg_info "Backing up Data"
if [ -d "/opt/Heimdall-2.4.6" ]; then
  cp -R /opt/Heimdall-2.4.6/database database-backup
  cp -R /opt/Heimdall-2.4.6/public public-backup
elif [[ -d "/opt/Heimdall-2.4.7b" ]]; then
  cp -R /opt/Heimdall-2.4.7b/database database-backup
  cp -R /opt/Heimdall-2.4.7b/public public-backup
elif [[ -d "/opt/Heimdall-2.4.8" ]]; then
  cp -R /opt/Heimdall-2.4.8/database database-backup
  cp -R /opt/Heimdall-2.4.8/public public-backup
else
  cp -R /opt/Heimdall/database database-backup
  cp -R /opt/Heimdall/public public-backup
fi
sleep 1
msg_ok "Backed up Data"

RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/Heimdall/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
msg_info "Updating Heimdall Dashboard to ${RELEASE}"
curl --silent -o ${RELEASE}.tar.gz -L "https://github.com/linuxserver/Heimdall/archive/${RELEASE}.tar.gz" &>/dev/null
tar xvzf ${RELEASE}.tar.gz &>/dev/null
VER=$(curl -s https://api.github.com/repos/linuxserver/Heimdall/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 3, length($2)-4) }')

if [ ! -d "/opt/Heimdall" ]; then
  mv Heimdall-${VER} /opt/Heimdall
else
  cp -R Heimdall-${VER}/* /opt/Heimdall
fi

service_path="/etc/systemd/system/heimdall.service"
echo "[Unit]
Description=Heimdall
After=network.target
[Service]
Restart=always
RestartSec=5
Type=simple
User=root
WorkingDirectory=/opt/Heimdall
ExecStart="/usr/bin/php" artisan serve --port 7990 --host 0.0.0.0
TimeoutStopSec=30
[Install]
WantedBy=multi-user.target" >$service_path
msg_ok "Updated Heimdall Dashboard to ${RELEASE}"

msg_info "Restoring Data"
cp -R database-backup/* /opt/Heimdall/database
cp -R public-backup/* /opt/Heimdall/public
sleep 1
msg_ok "Restored Data"

msg_info "Cleanup"
if [ -d "/opt/Heimdall-2.4.6" ]; then
  rm -rf /opt/Heimdall-2.4.6
  rm -rf /opt/v2.4.6.tar.gz
elif [[ -d "/opt/Heimdall-2.4.7b" ]]; then
  rm -rf /opt/Heimdall-2.4.7b
  rm -rf /opt/v2.4.7b.tar.gz
elif [[ -d "/opt/Heimdall-2.4.8" ]]; then
  rm -rf /opt/Heimdall-2.4.8
  rm -rf /opt/v2.4.8.tar.gz
fi

rm -rf ${RELEASE}.tar.gz
rm -rf Heimdall-${VER}
rm -rf public-backup
rm -rf database-backup
rm -rf Heimdall
sleep 1
msg_ok "Cleaned"

msg_info "Starting ${APP}"
systemctl enable --now heimdall.service &>/dev/null
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
         ${BL}http://${IP}:7990${CL} \n"
