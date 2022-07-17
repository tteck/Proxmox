#!/usr/bin/env bash
VAULT=$(curl -s https://api.github.com/repos/dani-garcia/vaultwarden/releases/latest \
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
                        ${VAULT} UPDATE                                                                                                                        
${CL}"
}

update_info
while true; do
    read -p "This will Update Vaultwarden to $VAULT (set 2vCPU 2048MiB RAM Min.). Proceed(y/n)?" yn
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

echo -e "${GN} Updating (Building) to ${VAULT} (Patience)... ${CL}"
git clone https://github.com/dani-garcia/vaultwarden &>/dev/null
cd vaultwarden
cargo build --features "sqlite,mysql,postgresql" --release &>/dev/null
cp target/release/vaultwarden /opt/vaultwarden/bin/

echo -e "${GN} Starting Vaultwarden ${VAULT}... ${CL}"
systemctl start vaultwarden.service
sleep 1

echo -e "${GN} Cleaning up... ${CL}"
cd ~ && rm -rf vaultwarden

echo -e "${GN} Finished Update (set resources back to normal settings)${CL}"
