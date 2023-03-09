#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

header_info() {
clear
cat <<EOF
   __________  __  __
  / ____/ __ \/ / / /
 / /   / /_/ / / / / 
/ /___/ ____/ /_/ /  
\____/_/    \____/   
Scaling Governors
EOF
}
while true; do
    header_info
    read -p "View CPU Scaling Governors. Proceed(y/n)?" yn
    case $yn in
    [Yy]*) break ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
done
show_menu() {
    header_info
    echo -e "\nProxmox IP \033[36m$(hostname -I)\033[m"
    echo -e "Current Kernel \033[36m$(uname -r)\033[m\n"
    available_governors=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
    echo -e "Available CPU Scaling Governors\n\033[36m${available_governors}\033[m\n"
    echo -e "Current CPU Scaling Governor\n\033[36m$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)\033[m\n"
    options=""
    i=1
    for governor in $available_governors
    do
        options+="** ${i}) \033[36m${governor}\033[m CPU Scaling Governor\n"
        ((i=i+1))
    done
    echo -e "${options}"
    echo -e "\033[31mNOTE: Settings return to default after reboot\033[m\n"
    read -p "Please choose an option from the menu and press [ENTER] or x to exit." opt
}
show_menu
while [[ "$opt" != "" ]]; do
    num_governors=$(echo "$available_governors" | wc -w)
    if [[ $opt -gt 0 ]] && [[ $opt -le $num_governors ]]; then
        governor=$(echo "$available_governors" | cut -d' ' -f $opt)
        echo "${governor}" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    elif [[ $opt == "x" ]] || [[ $opt == "\n" ]]; then
        exit
    else
        show_menu
    fi
    show_menu
done
