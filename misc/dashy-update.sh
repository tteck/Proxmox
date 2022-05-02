#!/usr/bin/env bash
set -e
clear
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
while true; do
    read -p "This will Update Dashy LXC. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${RD}
  _____            _           
 |  __ \          | |          
 | |  | | __ _ ___| |__  _   _ 
 | |  | |/ _  / __|  _ \| | | |
 | |__| | (_| \__ \ | | | |_| |
 |_____/ \__,_|___/_| |_|\__, |
          UPDATE          __/ |
                         |___/ 
${CL}"
}

header_info
echo -en "${GN} Stopping Dashy... "
systemctl stop dashy
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Backup conf.yml... "
cd ~
cp -R /dashy/public/conf.yml conf.yml
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Updating Dashy... "
cd /dashy
git merge &>/dev/null
git pull origin master &>/dev/null
yarn &>/dev/null
yarn build &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Restoring conf.yml... "
cd ~
cp -R conf.yml /dashy/public
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleaning... "
rm -rf conf.yml
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Starting Dashy... "
systemctl start dashy
sleep 1
echo -e "${CM}${CL} \r"

echo -e "${GN} Finished ${CL}\n"
