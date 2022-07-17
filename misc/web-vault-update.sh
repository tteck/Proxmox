#!/usr/bin/env bash
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
 __          __  _                            _ _   
 \ \        / / | |                          | | |  
  \ \  /\  / /__| |__ ________   ____ _ _   _| | |_ 
   \ \/  \/ / _ \  _ \______\ \ / / _  | | | | | __|
    \  /\  /  __/ |_) |      \ V / (_| | |_| | | |_ 
     \/  \/ \___|_.__/        \_/ \__,_|\__,_|_|\__|
                   ${VWRELEASE} UPDATE                                                                                                                        
${CL}"
}
update_info
while true; do
    read -p "This will Update Web-Vault to $VWRELEASE. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
sleep 2
echo -e "${GN} Stopping Vaultwarden... ${CL}"
systemctl stop vaultwarden.service
sleep 1

echo -e "${GN} Updating to ${VWRELEASE}... ${CL}"
curl -fsSLO https://github.com/dani-garcia/bw_web_builds/releases/download/$VWRELEASE/bw_web_$VWRELEASE.tar.gz &>/dev/null
if [ -d "/var/lib/vaultwarden" ]; then
tar -xzf bw_web_$VWRELEASE.tar.gz -C /var/lib/vaultwarden/ &>/dev/null
else 
tar -zxf bw_web_$VWRELEASE.tar.gz -C /opt/vaultwarden/ &>/dev/null
fi

echo -e "${GN} Cleaning up... ${CL}"
rm bw_web_$VWRELEASE.tar.gz

echo -e "${GN} Starting Vaultwarden... ${CL}"
systemctl start vaultwarden.service
sleep 1
echo -e "${GN} Finished Update ${CL}"
