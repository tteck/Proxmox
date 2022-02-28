#!/bin/sh
VWRELEASE=$(curl -s https://api.github.com/repos/dani-garcia/bw_web_builds/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 2, length($2)-3) }') \

RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
function update_info {
echo -e "${BL}
 __      __         _ _                         _            
 \ \    / /        | | |                       | |           
  \ \  / /_ _ _   _| | |___      ____ _ _ __ __| | ___ _ __  
   \ \/ / _  | | | | | __\ \ /\ / / _  |  __/ _  |/ _ \  _ \ 
    \  / (_| | |_| | | |_ \ V  V / (_| | | | (_| |  __/ | | |
     \/ \__,_|\__,_|_|\__| \_/\_/ \__,_|_|  \__,_|\___|_| |_|
                            UPDATE                                                                                                                        
${CL}"
}

update_info
while true; do
    read -p "This will Update Vaultwarden to $VWRELEASE. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
update_info

echo -e "${GN} Updating to ${VWRELEASE}... ${CL}"
wget https://github.com/dani-garcia/bw_web_builds/releases/download/$VWRELEASE/bw_web_$VWRELEASE.tar.gz &>/dev/null
tar -xzf bw_web_$VWRELEASE.tar.gz &>/dev/null
cp -R web-vault /var/lib/vaultwarden/ &>/dev/null

echo -e "${GN} Cleanup... ${CL}"
rm -r bw_web_$VWRELEASE.tar.gz web-vault
sleep 2
echo -e "${GN} Finished Update, Please Reboot Vaultwarden ${CL}"
while true; do
    read -p "Reboot Now? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
reboot
