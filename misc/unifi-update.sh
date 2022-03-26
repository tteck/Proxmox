#!/usr/bin/env bash
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
APP="UniFi Update"
while true; do
    read -p "This will run ${APP}. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${RD}
  _    _       _ ______ _ 
 | |  | |     (_)  ____(_)
 | |  | |_ __  _| |__   _ 
 | |  | |  _ \| |  __| | |
 | |__| | | | | | |    | |
  \____/|_| |_|_|_|    |_|
          UPDATE
${CL}"
}

header_info
sleep 3
wget -qL https://get.glennr.nl/unifi/update/unifi-update.sh && bash unifi-update.sh

