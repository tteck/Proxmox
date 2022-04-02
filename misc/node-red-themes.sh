#!/usr/bin/env bash
# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/node-red-themes.sh)"
set -o errexit
show_menu(){
    YW=`echo "\033[33m"`
    RD=`echo "\033[01;31m"`
    BL=`echo "\033[36m"`
    CM='\xE2\x9C\x94\033'
    GN=`echo "\033[1;92m"`
    CL=`echo "\033[m"`
echo -e "${RD} Backup your Node-Red flows before running this script!!${CL} \n "
while true; do
    read -p "This will Install Node-Red Themes. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
echo -e "${RD} Backup your Node-Red flows before installing any theme!!${CL} \n "
    printf "\n${BL}*********************************************${CL}\n"
    printf "${BL}**${YW} 1)${GN} Default Theme ${CL}\n"
    printf "${BL}**${YW} 2)${GN} Dark Theme ${CL}\n"
    printf "${BL}**${YW} 3)${GN} Dracula Theme ${CL}\n"
    printf "${BL}**${YW} 4)${GN} Midnight-Red Theme ${CL}\n"
    printf "${BL}**${YW} 5)${GN} Oled Theme ${CL}\n"
    printf "${BL}**${YW} 6)${GN} Solarized-Dark Theme ${CL}\n"
    printf "${BL}**${YW} 7)${GN} Solarized-Light Theme ${CL}\n"
    printf "${BL}*********************************************${CL}\n"
    printf "Please choose a theme from the menu and enter or ${RD}x to exit. ${CL}"
    read opt
}

option_picked(){
    msgcolor=`echo "\033[01;31m"`
    normal=`echo "\033[00;00m"`
    message=${@:-"${CL}Error: No message passed"}
    printf "${RD}${message}${CL}\n"
}

clear
show_menu
while [ "$opt" != " " ]
    do
      case $opt in
        1) clear;
            option_picked "Installing Default Theme";
            THEME=
            JS=//
            break;
        ;;
        2) clear;
            option_picked "Installing Dark Theme";
            THEME=dark
            break;
        ;;
        3) clear;
            option_picked "Installing Dracula Theme";
            THEME=dracula
            break;
        ;;
        4) clear;
            option_picked "Installing Midnight-Red Theme";
            THEME=midnight-red
            break;
        ;;
        5) clear;
            option_picked "Installing Oled Theme";
            THEME=oled
            break;
        ;;
        6) clear;
            option_picked "Installing Solarized-Dark Theme";
            THEME=solarized-dark
            break;
        ;;
        7) clear;
            option_picked "Installing Solarized-Light Theme";
            THEME=solarized-light
            break;
        ;;

        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Please choose a theme from the menu";
            show_menu;
        ;;
      esac
  done
echo -en "${GN} Installing ${THEME} Theme... "
cd /root/.node-red
if [ "${THEME}" = "" ]; then
  echo -e "${CM}${CL} \r"
  else
npm install @node-red-contrib-themes/${THEME} &>/dev/null
echo -e "${CM}${CL} \r"
fi
echo -en "${GN} Writing Settings... "
cat <<EOF > /root/.node-red/settings.js
module.exports = { uiPort: process.env.PORT || 1880,
    mqttReconnectTime: 15000,
    serialReconnectTime: 15000,
    debugMaxLength: 1000,
    functionGlobalContext: {
    },
    exportGlobalContextKeys: false,

    // Configure the logging output
    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    },

    // Customising the editor
    editorTheme: {
    ${JS}theme: "${THEME}"
    },
        projects: {
            // To enable the Projects feature, set this value to true
            enabled: false
    }
}
EOF
echo -e "${CM}${CL} \r"

echo -en "${GN} Restarting Node-Red... "
echo -e "${CM}${CL} \r"
node-red-restart
echo -en "${GN} Finished... ${CL} \n"
exit
