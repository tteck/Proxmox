#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
CROSS='\033[1;31m\xE2\x9D\x8C\033[0m'
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
RETRY_NUM=5
RETRY_EVERY=3
NUM=$RETRY_NUM
trap die ERR
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
    
echo -e "${CHECKMARK} \e[1;92m Installing Motion... \e[0m"
 apt-get install motion -y &>/dev/null
 systemctl stop motion &>/dev/null
 systemctl disable motion &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing FFmpeg... \e[0m"
 apt-get install ffmpeg v4l-utils -y &>/dev/null
 
echo -e "${CHECKMARK} \e[1;92m Installing Python... \e[0m"
 apt-get update &>/dev/null
 apt-get install python2 -y &>/dev/null
 curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py &>/dev/null
 python2 get-pip.py &>/dev/null
 apt-get install libffi-dev libzbar-dev libzbar0 -y &>/dev/null
 apt-get install python2-dev libssl-dev libcurl4-openssl-dev libjpeg-dev -y &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Installing MotionEye... \e[0m"
 apt-get update &>/dev/null
 sudo pip install motioneye &>/dev/null
 mkdir -p /etc/motioneye
 cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf
 mkdir -p /var/lib/motioneye
 
echo -e "${CHECKMARK} \e[1;92m Creating Service file motioneye.service... \e[0m" 
  cp /usr/local/share/motioneye/extra/motioneye.systemd-unit-local /etc/systemd/system/motioneye.service &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Customizing Container... \e[0m"
 rm /etc/motd
 rm /etc/update-motd.d/10-uname
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
 systemctl enable motioneye &>/dev/null
 systemctl start motioneye 

echo -e "${CHECKMARK} \e[1;92m Cleanup... \e[0m"
 rm -rf /motioneye_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
