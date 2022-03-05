#!/bin/bash
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
while true; do
    read -p "This will Clean unused Kernel images. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
current_kernel=$(uname -r)
function check_root {
        if [[ $EUID -ne 0 ]]; then
                printf "[!] Error: this script must be ran as the root user.\n" 
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
function kernel_info {
        latest_kernel=$(dpkg --list| grep 'pve-kernel-.*-pve' | awk '{print $2}' | tac | head -n 1)
        printf "OS: $(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $0}')\n"
        printf "Current Kernel: pve-kernel-$current_kernel\n"
        if [[ "$current_kernel" == *"pve"* ]]; then
                if [[ "$latest_kernel" != *"$current_kernel"* ]]; then
                        printf "Latest Kernel: $latest_kernel\n"
                fi
        else
                printf "___________________________________________\n\n"
                printf "[!] Warning, you're not running a PVE Kernel\n"
                        exit 1
        fi
}
function kernel_clean {
        kernels=$(dpkg --list| grep 'pve-kernel-.*-pve' | awk '{print $2}' | sort -V)
        kernels_to_remove=""
        for kernel in $kernels
        do
                if [ "$(echo $kernel | grep $current_kernel)" ]; then
                        break
                else
                        printf "\"$kernel\" has been added to the Kernel remove list\n"
                        kernels_to_remove+=" $kernel"
                fi
        done
        printf "Kernel Search Complete!\n"
        if [[ "$kernels_to_remove" != *"pve"* ]]; then
                printf "It appears there are no old Kernels on your system \n"
        else
                        read -p "[!] Would you like to remove the $(echo $kernels_to_remove | awk '{print NF}') selected Kernels listed above? [y/n]: " -n 1 -r
                        printf "\n"
        fi
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                        printf "Removing $(echo $kernels_to_remove | awk '{print NF}') old Kernels..."
                        /usr/bin/apt purge -y $kernels_to_remove > /dev/null 2>&1
                        printf "Finished!\n"
                        printf "Updating GRUB... \n"
                        /usr/sbin/update-grub > /dev/null 2>&1
                        printf "Finished!\n"
                else
                        printf "\nExiting...\n"
                fi
}
function main {
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
