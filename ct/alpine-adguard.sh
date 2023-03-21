#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/next/misc/alpine.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ___       __                           __
   /   | ____/ /___ ___  ______ __________/ /
  / /| |/ __  / __  / / / / __  / ___/ __  / 
 / ___ / /_/ / /_/ / /_/ / /_/ / /  / /_/ /  
/_/  |_\__,_/\__, /\__,_/\__,_/_/   \__,_/   
            /____/ Alpine                   
 
EOF
}
header_info
echo -e "Loading..."
APP="Alpine-AdGuard"
var_disk="0.3"
var_cpu="1"
var_ram="256"
var_os="alpine"
var_version="3.17"
varibles
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
    if [[ ! -d /opt/AdGuardHome ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
    normal=$(echo "\033[m")
    menu=$(echo "\033[36m")
    number=$(echo "\033[33m")
    fgred=$(echo "\033[31m")
    printf "\n${menu}*********************************************${normal}\n"
    printf "${menu}**${number} 1)${normal} Update LXC OS \n"
    printf "${menu}**${number} 2)${normal} Update AdGuardHome\n"
    printf "${menu}*********************************************${normal}\n"
    printf "Please choose an option from the menu, or ${fgred}x${normal} to exit."
    read opt

while [ "$opt" != "" ]; do
        case $opt in
        1)
            clear
            echo -e "${fgred}Update LXC OS${normal}"
            msg_info "Updating LXC OS"
            apk update &>/dev/null
            apk upgrade &>/dev/null
            msg_ok "Update Successfull"
            
            break
            ;;
        2)
            clear
            echo -e "${fgred}Update AdGuardHome${normal}"
            msg_info "Stopping AdguardHome"
            /opt/AdGuardHome/AdGuardHome -s stop &>/dev/null
            msg_ok "Stopped AdguardHome"

            VER=$(curl -sqI https://github.com/AdguardTeam/AdGuardHome/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}');
            msg_info "Updating AdguardHome to $VER"
            wget -q "https://github.com/AdguardTeam/AdGuardHome/releases/download/$VER/AdGuardHome_linux_amd64.tar.gz"
            tar -xvf AdGuardHome_linux_amd64.tar.gz &>/dev/null
            cp AdGuardHome/AdGuardHome /opt/AdGuardHome/AdGuardHome
            msg_ok "Updated AdguardHome"

            msg_info "Starting AdguardHome"
            /opt/AdGuardHome/AdGuardHome -s start &>/dev/null
            msg_ok "Started AdguardHome"

            msg_info "Cleaning Up"
            rm -rf AdGuardHome_linux_amd64.tar.gz AdGuardHome adguard-backup
            msg_ok "Cleaned"
            msg_ok "Update Successfull"
            
            break
            ;;
        x)
            clear
            echo -e "⚠  User exited script \n"
            exit
            ;;
        \n)
            clear
            echo -e "⚠  User exited script \n"
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
         ${BL}http://${IP}:3000${CL} \n"
