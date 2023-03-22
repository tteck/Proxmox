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

function update_script() {
    header_info
    PS3="Please choose an option from the menu, or enter q to exit: "
    options=("Update Vaultwarden" "View Admin Token" "Exit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Update Vaultwarden")
                clear
                echo "Updating Vaultwarden..."
                apk update &>/dev/null
                apk upgrade &>/dev/null
                break
                ;;
            "View Admin Token")
                clear
                echo "Viewing the Admin Token..."
                token=$(awk -F'"' '/ADMIN_TOKEN/{print $2}' /etc/conf.d/vaultwarden)
                if [ -n "$token" ]; then
                    echo "Admin Token: $token"
                else
                    echo "Failed to retrieve the Admin Token."
                fi
                break
                ;;
            "Exit")
                exit
                ;;
            *) echo "Invalid option. Please choose an option from the menu.";;
        esac
    done
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8000${CL} \n"
