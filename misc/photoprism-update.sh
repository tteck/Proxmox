#!/usr/bin/env bash
set -e
RELEASE=$(curl -s https://api.github.com/repos/photoprism/photoprism/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 2, length($2)-4) }') \

YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
PP=`echo "\e[1;35m"`

while true; do
    read -p "Update PhotoPrism LXC. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${PP}
  _____  _           _        _____      _               
 |  __ \| |         | |      |  __ \    (_)              
 | |__) | |__   ___ | |_ ___ | |__) | __ _ ___ _ __ ___  
 |  ___/|  _ \ / _ \| __/ _ \|  ___/  __| / __|  _   _ \ 
 | |    | | | | (_) | || (_) | |   | |  | \__ \ | | | | |
 |_|    |_| |_|\___/ \__\___/|_|   |_|  |_|___/_| |_| |_|
             ${RD} UPDATE
${CL}"
}

header_info
show_menu(){
    printf "    ${YW} 1)${GN} Release Branch ${CL}\n"
    printf "    ${YW} 2)${YW} Develop Branch ${CL}\n"

    printf "Please choose a Install Branch and hit enter or ${RD}x${CL} to exit."
    read opt
}

option_picked(){
    message1=${@:-"${CL}Error: No message passed"}
    printf " ${YW}${message1}${CL}\n"
}
show_menu
while [ "$opt" != " " ]
    do
      case $opt in
        1) clear;
            header_info;
            option_picked "Using Release Branch";
            BR="release"
            break;
        ;;
        2) clear;
            header_info;
            option_picked "Using Develop Branch";
            BR="develop"
            break;
        ;;

        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Please choose a Install Branch from the menu";
            show_menu;
        ;;
      esac
  done

echo -en "${GN} Stopping PhotoPrism... "
sudo systemctl stop photoprism
echo -e "${CM}${CL} \r"

echo -en "${GN} Cloning PhotoPrism ${BR} branch... "
git clone https://github.com/photoprism/photoprism.git &>/dev/null
cd photoprism
git checkout ${BR} &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Building PhotoPrism ${BR} branch... "
sudo make all &>/dev/null
sudo ./scripts/build.sh prod /opt/photoprism/bin/photoprism &>/dev/null
sudo cp -a assets/ /opt/photoprism/assets/ &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleaning... "
cd ~
rm -rf photoprism
echo -e "${CM}${CL} \r"

echo -en "${GN} Starting PhotoPrism... "
sudo systemctl start photoprism
echo -e "${CM}${CL} \n"

echo -e "${GN} Finished ${CL} \n "


