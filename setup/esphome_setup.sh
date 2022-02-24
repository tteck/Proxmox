#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
CROSS='\033[1;31m\xE2\x9D\x8C\033[0m'
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
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

echo -en "${GN} Setting up Container OS... "
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
while [ "$(hostname -I)" = "" ]; do
  1>&2 echo -en "${CROSS}${RD}  No Network! "
  sleep $RETRY_EVERY
  ((NUM--))
  if [ $NUM -eq 0 ]
  then
    1>&2 echo -e "${CROSS}${RD}  No Network After $RETRY_NUM Tries${CL}"    
    exit 1
  fi
done
echo -e "${CM}${CL} \r"

echo -en "${GN} Updating Container OS... "
apt-get update &>/dev/null
apt-get -qqy upgrade &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing Dependencies... "
apt-get update &>/dev/null
apt-get -qqy install \
    curl \
    sudo &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing pip3... "
apt-get install python3-pip -y &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing ESPHome... "
pip3 install esphome &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing ESPHome Dashboard... "
pip3 install tornado esptool &>/dev/null

service_path="/etc/systemd/system/esphomeDashboard.service"
echo "[Unit]
Description=ESPHome Dashboard
After=network.target
[Service]
ExecStart=/usr/local/bin/esphome /root/config/ dashboard
Restart=always
User=root
[Install]
WantedBy=multi-user.target" > $service_path
systemctl enable esphomeDashboard.service &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Customizing Container... "
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
systemctl start esphomeDashboard
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleanup... "
rm -rf /esphome_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
echo -e "${CM}${CL} \r"
