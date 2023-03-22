#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/next/misc/alpine.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
 _    __            ____                          __         
| |  / /___ ___  __/ / /__      ______ __________/ /__v5____ 
| | / / __ `/ / / / / __/ | /| / / __ `/ ___/ __  / _ \/ __ \
| |/ / /_/ / /_/ / / /_ | |/ |/ / /_/ / /  / /_/ /  __/ / / /
|___/\__,_/\__,_/_/\__/ |__/|__/\__,_/_/   \__,_/\___/_/ /_/ 
 Alpine                                                 

EOF
}
header_info
echo -e "Loading..."
APP="Alpine-Vaultwarden"
var_disk="0.3"
var_cpu="1"
var_ram="256"
var_os="alpine"
var_version="3.17"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW="-password alpine"
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
    normal=$(echo "\033[m")
    menu=$(echo "\033[36m")
    number=$(echo "\033[33m")
    fgred=$(echo "\033[31m")
    printf "\n${menu}*********************************************${normal}\n"
    printf "${menu}**${number} 1)${normal} Update Vaultwarden \n"
    printf "${menu}**${number} 2)${normal} View Admin Token\n"
    printf "\n${menu}*********************************************${normal}\n"
    printf "Please choose an option from the menu, or ${fgred}x${normal} to exit."
    read opt

while [ "$opt" != "" ]; do
        case $opt in
        1)
            clear
            echo -e "${fgred}Update Vaultwarden${normal}"
            apk update &>/dev/null
            apk upgrade &>/dev/null
            
            break
            ;;
        2)
            clear
            echo -e "${fgred}View the Admin Token${normal}"
            cat /etc/conf.d/vaultwarden | grep "ADMIN_TOKEN" | awk '{print substr($2, 7) }'
            
            break
            ;;
        x)
            exit
            ;;
        \n)
            exit
            ;;
        *)
            clear
            echo -e "Please choose an option from the menu"
            update_script
            ;;
        esac
done
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8000${CL} \n"
