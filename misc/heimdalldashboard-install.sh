#!/usr/bin/env bash
set -e
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
while true; do
    read -p "This will Update Heimdall Dashboard. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${PP}
  _    _      _               _       _ _   _____            _     _                         _ 
 | |  | |    (_)             | |     | | | |  __ \          | |   | |                       | |
 | |__| | ___ _ _ __ ___   __| | __ _| | | | |  | | __ _ ___| |__ | |__   ___   __ _ _ __ __| |
 |  __  |/ _ \ |  _   _ \ / _  |/ _  | | | | |  | |/ _  / __|  _ \|  _ \ / _ \ / _  |  __/ _  |
 | |  | |  __/ | | | | | | (_| | (_| | | | | |__| | (_| \__ \ | | | |_) | (_) | (_| | | | (_| |
 |_|  |_|\___|_|_| |_| |_|\__,_|\__,_|_|_| |_____/ \__,_|___/_| |_|_.__/ \___/ \__,_|_|  \__,_|
                  ${RD}UPDATE
${CL}"
}

header_info

echo -en "${GN} Stopping Heimdall Dashboard... "
systemctl stop heimdall
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Backing up Data... "
cp -R /opt/Heimdall/database database-backup
cp -R /opt/Heimdall/public public-backup
sleep 1
echo -e "${CM}${CL} \r"

RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/Heimdall/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
echo -en "${GN} Updating Heimdall Dashboard to ${RELEASE}... "
curl --silent -o ${RELEASE}.tar.gz -L "https://github.com/linuxserver/Heimdall/archive/${RELEASE}.tar.gz" &>/dev/null
tar xvzf ${RELEASE}.tar.gz &>/dev/null
VER=$(curl -s https://api.github.com/repos/linuxserver/Heimdall/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 3, length($2)-4) }')
cp -R Heimdall-${VER}/* /opt/Heimdall
echo -e "${CM}${CL} \r"

echo -en "${GN} Restoring Data... "
cp -R database-backup/* /opt/Heimdall/database
cp -R public-backup/* /opt/Heimdall/public
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleanup... "
rm -rf ${RELEASE}.tar.gz
rm -rf Heimdall-${VER}
rm -rf public-backup
rm -rf database-backup
rm -rf Heimdall
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Starting Heimdall Dashboard... "
systemctl start heimdall
sleep 2
echo -e "${CM}${CL} \r"

echo -en "${GN} Finished! ${CL}\n"
