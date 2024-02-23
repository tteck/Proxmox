#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
  ______                __                
 /_  __/___ _____  ____/ /___  ____  _____
  / / / __ `/ __ \/ __  / __ \/ __ \/ ___/
 / / / /_/ / / / / /_/ / /_/ / /_/ / /    
/_/  \__,_/_/ /_/\__,_/\____/\____/_/     
                                        
EOF
}
header_info
echo -e "Loading..."
APP="Tandoor"
var_disk="10"
var_cpu="2"
var_ram="1024"
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
if [[ ! -d /opt/tandoor ]]; then 
	msg_error "No ${APP} Installation Found!"; 
	exit; 
fi
msg_info "Updating ${APP} LXC"
if cd /opt/tandoor && git pull | grep -q 'Already up to date'; then
    msg_error "There is currently no update path available."
else
    export $(cat /opt/tandoor/.env | grep "^[^#]" | xargs)
    /opt/tandoor/bin/pip3 install -r requirements.txt >/dev/null 2>&1
    /opt/tandoor/bin/python3 manage.py migrate >/dev/null 2>&1
    /opt/tandoor/bin/python3 manage.py collectstatic --no-input >/dev/null 2>&1
    /opt/tandoor/bin/python3 manage.py collectstatic_js_reverse >/dev/null 2>&1
    cd /opt/tandoor/vue
    yarn install >/dev/null 2>&1
    yarn build >/dev/null 2>&1
    sudo systemctl restart gunicorn_tandoor
fi
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:8002${CL} \n"