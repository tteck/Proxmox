#!/usr/bin/env bash -ex
set -euo pipefail
shopt -s inherit_errexit nullglob
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
BGN=`echo "\033[4;92m"`
GN=`echo "\033[1;92m"`
DGN=`echo "\033[32m"`
CL=`echo "\033[m"`
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
PARTY="🎉"
current_kernel=$(uname -r)
pve=$(pveversion)

while true; do
    read -p "This will Clean Unused Kernel Images, USE AT YOUR OWN RISK. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo -e "${RD}Please answer y/n${CL}";;
    esac
done
clear

function header_info {
echo -e "${RD}
  _  __                    _    _____ _                  
 | |/ /                   | |  / ____| |                 
 |   / ___ _ __ _ __   ___| | | |    | | ___  __ _ _ __  
 |  < / _ \  __|  _ \ / _ \ | | |    | |/ _ \/ _  |  _ \ 
 |   \  __/ |  | | | |  __/ | | |____| |  __/ (_| | | | |
 |_|\_\___|_|  |_| |_|\___|_|v3\_____|_|\___|\__,_|_| |_|

${CL}"
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

function check_root() {
        if [[ $EUID -ne 0 ]]; then
                echo -e "${CROSS}${RD}Error: This script must be ran as the root user.\n${CL}" 
                exit 1
        else
            header_info
            edge_kernel
            kernel_info
            kernel_clean
        fi
}

function edge_kernel() {
    if [[ "$current_kernel" == *"edge"* ]]; then
         echo -e "\n${CROSS} ${RD}ERROR:${CL} Proxmox ${BL}${current_kernel}${CL} Kernel Active"
         echo -e "\nAn Active PVE Kernel is required to use Kernel Clean\n"
         exit 1
    fi
}

function kernel_info() {
    latest_kernel=$(dpkg --list| grep 'kernel-.*-pve' | awk '{print $2}' | tac | head -n 1)
    echo -e "${YW}PVE Version: ${BL}$pve\n${CL}"
    if [[ "$current_kernel" == *"pve"* ]]; then
      if [[ "$latest_kernel" != *"$current_kernel"* ]]; then
        echo -e "${GN}Latest Kernel: $latest_kernel\n${CL}"
      fi
    else
        echo -e "\n${CROSS} ${RD}ERROR: No PVE Kernel Found\n${CL}"
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
            echo -e "${BL}'$kernel' ${CL}${YW}has been added to the remove Kernel list\n${CL}"
                    remove_kernels+=" $kernel"
        fi
    done
msg_ok "Kernel Search Completed\n"
    if [[ "$remove_kernels" != *"pve"* ]]; then
        echo -e "${PARTY}  ${GN}It appears there are no old Kernels on your system. \n${CL}"
        msg_info "Exiting"
        sleep 2
        msg_ok "Done"
    else
    read -p "Would you like to remove the $(echo $remove_kernels | awk '{print NF}') selected Kernels listed above? [y/n]: " -n 1 -r
        echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        msg_info "Removing ${CL}${RD}$(echo $remove_kernels | awk '{print NF}') ${CL}${YW}old Kernels${CL}"
        /usr/bin/apt purge -y $remove_kernels > /dev/null 2>&1
        msg_ok "Successfully Removed Kernels"
        msg_info "Updating GRUB"
        /usr/sbin/update-grub > /dev/null 2>&1
        msg_ok "Successfully Updated GRUB"
        msg_info "Exiting"
        sleep 2
        msg_ok "Done"
      else
        msg_info "Exiting"
        sleep 2
        msg_ok "Done"
      fi
    fi
}

check_root
