#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/next/misc/ubuntu.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"

   _____ __    _             __    _ 
  / ___// /_  (_)___v5____  / /_  (_)
  \__ \/ __ \/ / __ \/ __ \/ __ \/ / 
 ___/ / / / / / / / / /_/ / /_/ / /  
/____/_/ /_/_/_/ /_/\____/_.___/_/   
                                     
EOF
}
header_info
echo -e "Loading..."
APP="Shinobi"
var_disk="8"
var_cpu="2"
var_ram="2048"
var_os="ubuntu"
var_version="22.04"
var_version="20.04"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="0"
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
if [[ ! -d /opt/Shinobi ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating Shinobi LXC"
cd /opt/Shinobi
sh UPDATE.sh
pm2 flush
pm2 restart camera
pm2 restart cron
msg_ok "Updated Shinobi LXC"
exit
}

if command -v pveversion >/dev/null 2>&1; then
  if ! (whiptail --title "${APP} LXC" --yesno "This will create a New ${APP} LXC. Proceed?" 10 58); then
    clear
    echo -e "⚠  User exited script \n"
    exit
  fi
  install_script
fi

if ! command -v pveversion >/dev/null 2>&1 && [[ ! -d /opt/Shinobi ]]; then
  msg_error "No ${APP} Installation Found!"
  exit 
fi

if ! command -v pveversion >/dev/null 2>&1; then
  if ! (whiptail --title "${APP} LXC UPDATE" --yesno "This will update ${APP} LXC.  Proceed?" 10 58); then
    clear
    echo -e "⚠  User exited script \n"
    exit
  fi
  update_script
fi

if [ "$VERB" == "yes" ]; then set -x; fi
if [ "$CT_TYPE" == "1" ]; then
  FEATURES="nesting=1,keyctl=1"
else
  FEATURES="nesting=1"
fi
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null 
export tz=$timezone
export DISABLEIPV6=$DISABLEIP6
export APPLICATION=$APP
export VERBOSE=$VERB
export SSH_ROOT=${SSH}
export CTID=$CT_ID
export PCT_OSTYPE=$var_os
export PCT_OSVERSION=$var_version
export PCT_DISK_SIZE=$DISK_SIZE
export PCT_OPTIONS="
  -features $FEATURES
  -hostname $HN
  $SD
  $NS
  -net0 name=eth0,bridge=$BRG$MAC,ip=$NET$GATE$VLAN$MTU
  -onboot 1
  -cores $CORE_COUNT
  -memory $RAM_SIZE
  -unprivileged $CT_TYPE
  $PW
"
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/create_lxc.sh)" || exit
msg_info "Starting LXC Container"
pct start $CTID
msg_ok "Started LXC Container"
lxc-attach -n $CTID -- bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/install/$var_install.sh)" || exit
IP=$(pct exec $CTID ip a s dev eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
pct set $CTID -description "# ${APP} LXC
### https://tteck.github.io/Proxmox/
<a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/☕-Buy me a coffee-red' /></a>"
msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:8080/super${CL} \n"
