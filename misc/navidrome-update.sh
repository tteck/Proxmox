#!/usr/bin/env bash
RELEASE=$(curl -s https://api.github.com/repos/navidrome/navidrome/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 3, length($2)-4) }')

RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
function update_info {
cat << "EOF"
    _   __            _     __                        
   / | / /___ __   __(_)___/ /________  ____ ___  ___ 
  /  |/ / __  / | / / / __  / ___/ __ \/ __  __ \/ _ \
 / /|  / /_/ /| |/ / / /_/ / /  / /_/ / / / / / /  __/
/_/ |_/\__,_/ |___/_/\__,_/_/   \____/_/ /_/ /_/\___/ 
                    UPDATE
            
EOF
}
update_info
while true; do
    read -p "This will Update Navidrome to v$RELEASE. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
sleep 2
echo -e "${GN} Stopping Navidrome... ${CL}"
systemctl stop navidrome.service
sleep 1

echo -e "${GN} Updating to v${RELEASE}... ${CL}"
wget https://github.com/navidrome/navidrome/releases/download/v${RELEASE}/navidrome_${RELEASE}_Linux_x86_64.tar.gz -O Navidrome.tar.gz &>/dev/null
tar -xvzf Navidrome.tar.gz -C /opt/navidrome/ &>/dev/null

echo -e "${GN} Cleaning up... ${CL}"
rm Navidrome.tar.gz

echo -e "${GN} Starting Navidrome... ${CL}"
systemctl start navidrome.service
sleep 1
echo -e "${GN} Finished Update ${CL}"
