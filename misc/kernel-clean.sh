#!/bin/bash
RD=$(tput setaf 1)
GN=$(tput setaf 2)
LYW=$(tput setaf 190)
WH=$(tput setaf 7)
BRT=$(tput bold)
CL=$(tput sgr0)
UL=$(tput smul)
current_kernel=$(uname -r)
pve=$(pveversion)

while true; do
    read -p "${WH}This will Clean unused Kernel images. Proceed(y/n)?${CL}" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo -e "${RD}Please answer y/n${CL}";;
    esac
done
clear

function check_root {
        if [[ $EUID -ne 0 ]]; then
                echo -e "${RD}Error: This script must be ran as the root user.\n${CL}" 
                exit 1
        fi
}

function header_info {
echo -e "${RD}
  _  __                    _    _____ _                  
 | |/ /                   | |  / ____| |                 
 |   / ___ _ __ _ __   ___| | | |    | | ___  __ _ _ __  
 |  < / _ \  __|  _ \ / _ \ | | |    | |/ _ \/ _  |  _ \ 
 |   \  __/ |  | | | |  __/ | | |____| |  __/ (_| | | | |
 |_|\_\___|_|  |_| |_|\___|_|  \_____|_|\___|\__,_|_| |_|

${CL}"
}

function kernel_info() {
    latest_kernel=$(dpkg --list| grep 'kernel-.*-pve' | awk '{print $2}' | tac | head -n 1)
    echo -e "${LYW}PVE Version: ${UL}${WH}$pve\n${CL}"
    if [[ "$current_kernel" == *"pve"* ]]; then
      if [[ "$latest_kernel" != *"$current_kernel"* ]]; then
        echo -e "${GN}Latest Kernel: $latest_kernel\n${CL}"
      fi
    else
        echo -e "\n${RD}ERROR: No PVE Kernel Found\n${CL}"
        exit 1
    fi
}

function kernel_clean() {
    kernels=$(dpkg --list| grep 'kernel-.*-pve' | awk '{print $2}' | sort -V)
    remove_kernels=""
    for kernel in $kernels
      do
        if [ "$(echo $kernel | grep $current_kernel)" ]; then
            break
        else
            echo -e "${RD}'$kernel' ${CL}${LYW}has been added to the remove Kernel list\n${CL}"
                    remove_kernels+=" $kernel"
        fi
    done
echo -e "${LYW}Kernel Search Complete!\n${CL}"
    if [[ "$remove_kernels" != *"pve"* ]]; then
        echo -e "${BRT}${GN}It appears there are no old Kernels on your system. \n${CL}"
    else
    read -p "${LYW}Would you like to remove the${RD} $(echo $remove_kernels | awk '{print NF}') ${CL}${LYW}selected Kernels listed above? [y/n]: ${CL}" -n 1 -r
    fi
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${LYW}\nRemoving ${CL}${RD}$(echo $remove_kernels | awk '{print NF}') ${CL}${LYW}old Kernels...${CL}"
        /usr/bin/apt purge -y $remove_kernels > /dev/null 2>&1
        echo -e "${LYW}Finished!\n${CL}"
        echo -e "${LYW}Updating GRUB... \n${CL}"
        /usr/sbin/update-grub > /dev/null 2>&1
        echo -e "${LYW}Finished!\n${CL}"
      else
        echo -e "${LYW}Exiting...\n${CL}"
        sleep 2
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
