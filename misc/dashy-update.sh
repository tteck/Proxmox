#!/usr/bin/env bash
set -e
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
clear
echo -en "${GN} Stopping Dashy... "
systemctl stop dashy
echo -e "${CM}${CL} \r"

echo -en "${GN} Backup Data... "
cp -R /dashy/public public-backup
echo -e "${CM}${CL} \r"

echo -en "${GN} Updating Dashy... "
git merge
git pull origin master
yarn
yarn build
echo -e "${CM}${CL} \r"

echo -en "${GN} Restoring Data... "
cp -R public-backup/* /dashy/public
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleaning... "
rm -rf public-backup
echo -e "${CM}${CL} \r"

echo -en "${GN} Starting Dashy... "
systemctl start dashy
echo -e "${CM}${CL} \r"

echo -e "${GN} Finished ${CL}\n"
