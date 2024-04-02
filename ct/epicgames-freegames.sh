#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/remz1337/Proxmox/remz/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster), remz1337
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ______      _                                            ______                                              
   / ____/___  (_)________ _____ _____ ___  ___  _____      / ____/_______  ___  ____ _____ _____ ___  ___  _____
  / __/ / __ \/ / ___/ __ `/ __ `/ __ `__ \/ _ \/ ___/_____/ /_  / ___/ _ \/ _ \/ __ `/ __ `/ __ `__ \/ _ \/ ___/
 / /___/ /_/ / / /__/ /_/ / /_/ / / / / / /  __(__  )_____/ __/ / /  /  __/  __/ /_/ / /_/ / / / / / /  __(__  ) 
/_____/ .___/_/\___/\__, /\__,_/_/ /_/ /_/\___/____/     /_/   /_/   \___/\___/\__, /\__,_/_/ /_/ /_/\___/____/  
     /_/           /____/                                                     /____/                           

EOF
}
header_info
echo -e "Loading..."
APP="Epicgames-Freegames"
var_disk="4"
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
header_info
if [[ ! -f /etc/systemd/system/epicgames-freegames.timer ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP} LXC"
RELEASE=$(curl -s https://api.github.com/repos/claabs/epicgames-freegames-node/releases/latest | grep "tarball_url" | awk '{print substr($2, 2, length($2)-3)}')
#mkdir -p /opt/epicgames-freegames
wget -qO epicgames-freegames.tar.gz "${RELEASE}"
tar -xzf epicgames-freegames.tar.gz -C /opt/epicgames-freegames --strip-components 1 --overwrite
rm -rf epicgames-freegames.tar.gz
npm install --prefix /opt/epicgames-freegames
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} is configured to be accessed by local tunnel. Please update the configuration to use a reverse proxy with the following URL.
         ${BL}http://${IP}:3000${CL} \n"