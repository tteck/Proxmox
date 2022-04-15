#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
WHITE=$(tput setaf 7)
NORMAL=$(tput sgr0)
while true; do
    read -p "${YELLOW}This will Clean unused Kernel images. Proceed(y/n)?${NORMAL}" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo -e "${RED}Please answer y/n${NORMAL}";;
    esac
done
clear
current_kernel=$(uname -r)
pve=$(pveversion)
function check_root {
        if [[ $EUID -ne 0 ]]; then
                echo -e "${RED}Error: This script must be ran as the root user.\n${NORMAL}" 
                exit 1
        fi
}
function header_info {
echo -e "${RED}
  _  __                    _    _____ _                  
 | |/ /                   | |  / ____| |                 
 |   / ___ _ __ _ __   ___| | | |    | | ___  __ _ _ __  
 |  < / _ \  __|  _ \ / _ \ | | |    | |/ _ \/ _  |  _ \ 
 |   \  __/ |  | | | |  __/ | | |____| |  __/ (_| | | | |
 |_|\_\___|_|  |_| |_|\___|_|  \_____|_|\___|\__,_|_| |_|

${NORMAL}"
}
function kernel_info() {
    latest_kernel=$(dpkg --list| grep 'kernel-.*-pve' | awk '{print $2}' | tac | head -n 1)
    echo -e "${YELLOW}OS: ${GREEN}$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $0}')\r${NORMAL}"
    echo -e "${YELLOW}PVE Version: ${GREEN}$pve\n${NORMAL}"
    if [[ "$current_kernel" == *"pve"* ]]; then
      if [[ "$latest_kernel" != *"$current_kernel"* ]]; then
        echo -e "${GREEN}Latest Kernel: $latest_kernel\n${NORMAL}"
      fi
    else
        echo -e "\n${RED}ERROR: No PVE Kernel found\n${NORMAL}"
        exit 1
    fi
}

function kernel_clean() {
    kernels=$(dpkg --list| grep 'kernel-.*-pve' | awk '{print $2}' | sort -V)
    kernels_to_remove=""
    for kernel in $kernels
      do
        if [ "$(echo $kernel | grep $current_kernel)" ]; then
            break
        else
            echo -e "${RED}'$kernel' ${NORMAL}${YELLOW}has been added to the Kernel remove list\n${NORMAL}"
                    kernels_to_remove+=" $kernel"
        fi
    done
echo -e "${YELLOW}Kernel Search Complete!\n${NORMAL}"
    if [[ "$kernels_to_remove" != *"pve"* ]]; then
        echo -e "${GREEN}It appears there are no old Kernels on your system \n${NORMAL}"
    else
    read -p "${YELLOW}Would you like to remove the${RED} $(echo $kernels_to_remove | awk '{print NF}') ${NORMAL}${YELLOW}selected Kernels listed above? [y/n]: ${NORMAL}" -n 1 -r
    fi
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}\nRemoving ${NORMAL}${RED}$(echo $kernels_to_remove | awk '{print NF}') ${NORMAL}${YELLOW}old Kernels...${NORMAL}"
        /usr/bin/apt purge -y $kernels_to_remove > /dev/null 2>&1
        echo -e "${YELLOW}Finished!\n${NORMAL}"
        echo -e "${YELLOW}Updating GRUB... \n${NORMAL}"
        /usr/sbin/update-grub > /dev/null 2>&1
        echo -e "${YELLOW}Finished!\n${NORMAL}"
      else
        echo -e "${YELLOW}Exiting...\n${NORMAL}"
        sleep 1
      fi
}

function main() {
    check_root
    header_info
    kernel_info
}

while true; do
    case "$1" in
        * )
        main
        kernel_clean
        exit 1
    ;;
    esac
  shift
done
