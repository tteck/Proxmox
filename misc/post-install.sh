#!/usr/bin/env bash -ex
set -euo pipefail
shopt -s inherit_errexit nullglob
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
BGN=`echo "\033[4;92m"`
GN=`echo "\033[1;92m"`
DGN=`echo "\033[32m"`
CL=`echo "\033[m"`
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

echo -e "\e[1;33m This script will Perform Post Install Routines. PVE7 ONLY \e[0m"
while true; do
    read -p "Start the PVE7 Post Install Script (y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
if [ `pveversion | grep "pve-manager/7" | wc -l` -ne 1 ]; then
        echo -e "This script requires Proxmox Virtual Environment 7.0 or greater"
        echo -e "Exiting..."
        sleep 2
        exit
fi
function header_info {
echo -e "${RD}
  _______      ________ ______   _____          _     _____           _        _ _ 
 |  __ \ \    / /  ____|____  | |  __ \        | |   |_   _|         | |      | | |
 | |__) \ \  / /| |__      / /  | |__) |__  ___| |_    | |  _ __  ___| |_ __ _| | |
 |  ___/ \ \/ / |  __| v3 / /   |  ___/ _ \/ __| __|   | | |  _ \/ __| __/ _  | | |
 | |      \  /  | |____  / /    | |  | (_) \__ \ |_   _| |_| | | \__ \ || (_| | | |
 |_|       \/   |______|/_/     |_|   \___/|___/\__| |_____|_| |_|___/\__\__,_|_|_|
${CL}"
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

clear
header_info
read -r -p "Disable Enterprise Repository? <y/n> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Disabling Enterprise Repository"
sleep 2
sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/pve-enterprise.list
msg_ok "Disabled Enterprise Repository"
fi

read -r -p "Add/Correct PVE7 Sources (sources.list)? <y/n> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Adding or Correcting PVE7 Sources"
cat <<EOF > /etc/apt/sources.list
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
EOF
sleep 2
msg_ok "Added or Corrected PVE7 Sources"
fi

read -r -p "Enable No-Subscription Repository? <y/n> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Enabling No-Subscription Repository"
cat <<EOF >> /etc/apt/sources.list
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF
sleep 2
msg_ok "Enabled No-Subscription Repository"
fi

read -r -p "Add (Disabled) Beta/Test Repository? <y/n> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Adding Beta/Test Repository and set disabled"
cat <<EOF >> /etc/apt/sources.list
# deb http://download.proxmox.com/debian/pve bullseye pvetest
EOF
sleep 2
msg_ok "Added Beta/Test Repository"
fi

read -r -p "Disable Subscription Nag? <y/n> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Disabling Subscription Nag"
echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" > /etc/apt/apt.conf.d/no-nag-script
apt --reinstall install proxmox-widget-toolkit &>/dev/null
msg_ok "Disabled Subscription Nag"
fi

read -r -p "Update Proxmox VE 7 now? <y/n> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
msg_info "Updating Proxmox VE 7"
apt-get update &>/dev/null
apt-get -y dist-upgrade &>/dev/null
msg_ok "Updated Proxmox VE 7 (Reboot Recommended)"
fi

sleep 2
msg_ok "Finished Post Install Routines"
