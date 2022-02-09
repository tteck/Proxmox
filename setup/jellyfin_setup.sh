#!/usr/bin/env bash

set -o errexit 
set -o errtrace
set -o nounset 
set -o pipefail 
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
CROSS='\033[1;31m\xE2\x9D\x8C\033[0m'
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
RETRY_NUM=5
RETRY_EVERY=3
NUM=$RETRY_NUM
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
while [ "$(hostname -I)" = "" ]; do
  1>&2 echo -e "${CROSS} \e[1;31m No Network: \e[0m $(date)"
  sleep $RETRY_EVERY
  ((NUM--))
  if [ $NUM -eq 0 ]
  then
    1>&2 echo -e "${CROSS} \e[1;31m No Network After $RETRY_NUM Tries \e[0m"
    exit 1
  fi
done
  echo -e "${CHECKMARK} \e[1;92m Network Connected: \e[0m $(hostname -I)"

echo -e "${CHECKMARK} \e[1;92m Updating Container OS... \e[0m"
apt-get update &>/dev/null
apt-get -qqy upgrade &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Dependencies... \e[0m"
apt-get update &>/dev/null
apt-get -qqy install \
    curl \
    sudo &>/dev/null
 
echo -e "${CHECKMARK} \e[1;92m Setting Up Hardware Acceleration... \e[0m"  
apt-get -y install \
    va-driver-all \
    ocl-icd-libopencl1 \
    beignet-opencl-icd &>/dev/null

/bin/chgrp video /dev/dri
/bin/chmod 755 /dev/dri
/bin/chmod 660 /dev/dri/*

echo -e "${CHECKMARK} \e[1;92m Installing Jellyfin... \e[0m"
sudo mkdir /opt/jellyfin
cd /opt/jellyfin
sudo wget https://repo.jellyfin.org/releases/server/linux/stable/combined/jellyfin_10.7.7_amd64.tar.gz &>/dev/null
sudo tar xvzf jellyfin_10.7.7_amd64.tar.gz &>/dev/null
sudo ln -s jellyfin_10.7.7 jellyfin
sudo mkdir data cache config log

echo -e "${CHECKMARK} \e[1;92m Installing FFmpeg... \e[0m"
apt-get update &>/dev/null
apt-get -y install ffmpeg &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Creating Service file jellyfin.service... \e[0m"
file_path="/opt/jellyfin/jellyfin.sh"
echo "#!/bin/bash
/opt/jellyfin/jellyfin/jellyfin 
 -d /opt/jellyfin/data 
 -C /opt/jellyfin/cache 
 -c /opt/jellyfin/config 
 -l /opt/jellyfin/log 
 --ffmpeg /usr/share/jellyfin-ffmpeg/ffmpeg" > $file_path
sudo chmod +x /opt/jellyfin/jellyfin.sh

service_path="/etc/systemd/system/jellyfin.service"
echo "[Unit]
Description=Jellyfin
After=network.target

[Service]
Type=simple
User=root
Restart=always
ExecStart=/opt/jellyfin/jellyfin.sh

[Install]
WantedBy=multi-user.target" > $service_path
sudo chmod 644 /etc/systemd/system/jellyfin.service

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
sudo systemctl enable jellyfin.service &>/dev/null
sudo systemctl start jellyfin.service &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Cleanup... \e[0m"
rm -rf /jellyfin_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
