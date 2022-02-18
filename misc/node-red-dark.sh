#!/usr/bin/env bash
# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/node-red-dark.sh)"
set -o errexit
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
echo -e "${RD}Backup your Node-Red flows before running this script!!${CL} \n "
while true; do
    read -p "This will install midnight-red theme. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
echo -en "${GN} Updating Container OS... "
apt-get update &>/dev/null
apt-get -qqy upgrade &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing midnight-red Theme... "
cd /root/.node-red
npm install @node-red-contrib-themes/midnight-red &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Writing Settings... "
cat <<EOF >> /root/.node-red/settings.js
    // Customising the editor
    editorTheme: {
        theme: "midnight-red"
    },
        projects: {
            // To enable the Projects feature, set this value to true
            enabled: true
    }
}
EOF
echo -e "${CM}${CL} \r"

echo -en "${GN} Restarting Node-Red... "
echo -e "${CM}${CL} \r"
node-red-restart
echo -en "${GN} Finished... ${CL} \n"
exit


