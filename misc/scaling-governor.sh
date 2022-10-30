#!/usr/bin/env bash
clear
set -e
while true; do
    read -p "View CPU Scaling Governors. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "
   _____ _____  _    _ 
  / ____|  __ \| |  | |
 | |    | |__) | |  | |
 | |    |  ___/| |  | |
 | |____| |    | |__| |
  \_____|_|     \____/ 
    Scaling Governors
"
}
show_menu(){
    CL=`echo "\033[m"`
    GN=`echo "\033[32m"`
    BL=`echo "\033[36m"`
    YW=`echo "\033[33m"`
    fgred=`echo "\033[31m"`
header_info
    CK=$(uname -r)
    IP=$(hostname -I)
#    MAC=$(cat /sys/class/net/eno1/address)
    ACSG=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
    CCSG=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    echo -e "${YW}Proxmox IP ${BL}${IP}${CL}"

    echo -e "${YW}MAC Address ${BL}${MAC}${CL}"

    echo -e "${YW}Current Kernel ${BL}${CK}${CL}"

    echo -e "\n${YW}Available CPU Scaling Governors
    ${BL}${ACSG}${CL}"
    
    echo -e "\n${YW}Current CPU Scaling Governor
    ${BL}${CCSG}${CL}"
    printf "\n ${fgred}Only Select Available CPU Scaling Governors From Above${CL}\n \n"
    printf "${BL}**${YW} 1)${GN} Switch to ${BL}conservative${CL}${GN} CPU Scaling Governor ${CL}\n"
    printf "${BL}**${YW} 2)${GN} Switch to ${BL}ondemand${CL}${GN} CPU Scaling Governor ${CL}\n"
    printf "${BL}**${YW} 3)${GN} Switch to ${BL}userspace${CL}${GN} CPU Scaling Governor ${CL}\n"
    printf "${BL}**${YW} 4)${GN} Switch to ${BL}powersave${CL}${GN} CPU Scaling Governor ${CL}\n"
    printf "${BL}**${YW} 5)${GN} Switch to ${BL}performance${CL}${GN} CPU Scaling Governor ${CL}\n"
    printf "${BL}**${YW} 6)${GN} Switch to ${BL}schedutil${CL}${GN} CPU Scaling Governor ${CL}\n"
    printf "\n ${fgred}NOTE: Settings return to default after reboot${CL}\n"
    printf "\n Please choose an option from the menu and press [ENTER] or ${fgred}x${CL} to exit."
    read opt
}
clear
show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        1) echo "conservative" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
            clear
            show_menu
        ;;
        2) echo "ondemand" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
            clear
            show_menu
        ;;
        3) echo "userspace" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
            clear
            show_menu
        ;;
        4) echo "powersave" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
            clear
            show_menu
        ;;
        5) echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
            clear
            show_menu
        ;;
        6) echo "schedutil" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
            clear
            show_menu
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            show_menu;
        ;;
      esac
    fi
  done
