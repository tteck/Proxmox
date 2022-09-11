#!/usr/bin/env bash
VWRELEASE=$(curl -s https://api.github.com/repos/zadam/trilium/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 3, length($2)-4) }')

RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
function update_info {
cat << "EOF"
  ______     _ ___               
 /_  __/____(_) (_)_  ______ ___ 
  / / / ___/ / / / / / / __ `__ \
 / / / /  / / / / /_/ / / / / / /
/_/ /_/  /_/_/_/\__,_/_/ /_/ /_/ 
            UPDATE
            
EOF
}
update_info
while true; do
    read -p "This will Update Trilium to v$VWRELEASE. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
sleep 2
echo -e "${GN} Stopping Trilium... ${CL}"
systemctl stop trilium.service
sleep 1

echo -e "${GN} Updating to v${VWRELEASE}... ${CL}"
wget -q https://github.com/zadam/trilium/releases/download/v$VWRELEASE/trilium-linux-x64-server-$VWRELEASE.tar.xz

tar -xzf trilium-linux-x64-server-$VWRELEASE.tar.xz -C /opt/trilium &>/dev/null

echo -e "${GN} Cleaning up... ${CL}"
rm trilium-linux-x64-server-$VWRELEASE.tar.xz

echo -e "${GN} Starting Trilium... ${CL}"
systemctl start trilium.service
sleep 1
echo -e "${GN} Finished Update ${CL}"
