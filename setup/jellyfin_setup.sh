#!/usr/bin/env bash

set -o errexit 
set -o errtrace
set -o nounset 
set -o pipefail 
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
trap 'die "Script interrupted."' INT

function error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR:LXC] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

echo -e "${CHECKMARK} \e[1;92m Setting up Container OS... \e[0m"
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null

echo -e "${CHECKMARK} \e[1;92m Updating Container OS... \e[0m"
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Dependencies... \e[0m"
apt-get -qqy install \
    curl \
    sudo \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    git &>/dev/null
 
echo -e "${CHECKMARK} \e[1;92m Setting Up Hardware Acceleration... \e[0m"  
apt-get -y install \
    va-driver-all \
    ocl-icd-libopencl1 \
    beignet-opencl-icd &>/dev/null

/bin/chgrp video /dev/dri
/bin/chmod 755 /dev/dri
/bin/chmod 660 /dev/dri/*

echo -e "${CHECKMARK} \e[1;92m Setting Up Jellyfin Repository... \e[0m"
wget -q -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | sudo apt-key add - &>/dev/null
echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/debian bullseye main" | tee /etc/apt/sources.list.d/jellyfin.list &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Installing Jellyfin... \e[0m"
apt update &>/dev/null
apt install jellyfin -y &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Customizing Container... \e[0m"
chmod -x /etc/update-motd.d/*
touch ~/.hushlogin 
GETTY_OVERRIDE="/etc/systemd/system/container-getty@1.service.d/override.conf"
mkdir -p $(dirname $GETTY_OVERRIDE)
cat << EOF > $GETTY_OVERRIDE
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM
EOF
systemctl daemon-reload
systemctl restart $(basename $(dirname $GETTY_OVERRIDE) | sed 's/\.d//')
sudo systemctl enable jellyfin &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Cleanup... \e[0m"
rm -rf /jellyfin_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
