#!/usr/bin/env bash

set -o errexit 
set -o errtrace 
set -o nounset 
set -o pipefail 
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
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

CROSS='\033[1;31m\xE2\x9D\x8C\033[0m'
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
RETRY_NUM=10
RETRY_EVERY=3
NUM=$RETRY_NUM

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
echo -en "${GN} Network Connected: ${BL}$(hostname -I)${CL} "
echo -e "${CM}${CL} \r"
OPTIONS_PATH='/options.conf'
cat >$OPTIONS_PATH <<'EOF'
IPv4dev=eth0
install_user=root
VPN=wireguard
pivpnNET=10.6.0.0
subnetClass=24
ALLOWED_IPS="0.0.0.0/0, ::0/0"
pivpnMTU=1420
pivpnPORT=51820
pivpnDNS1=1.1.1.1
pivpnDNS2=8.8.8.8
pivpnHOST=
pivpnPERSISTENTKEEPALIVE=25
UNATTUPG=1
EOF

echo -en "${GN} Updating Container OS... "
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing Dependencies... "
apt-get install -y curl &>/dev/null
apt-get install -y sudo &>/dev/null
apt-get install -y gunicorn &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing WireGuard (using pivpn.io)... "
curl -s -L https://install.pivpn.io > install.sh 
chmod +x install.sh
./install.sh --unattended options.conf &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing pip3... "
apt-get install python3-pip -y &>/dev/null
pip install flask &>/dev/null
pip install ifcfg &>/dev/null
pip install flask_qrcode &>/dev/null
pip install icmplib &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing WGDashboard... "
git clone -b v3.0.5 https://github.com/donaldzou/WGDashboard.git /ect/wgdashboard &>/dev/null
cd /ect/wgdashboard/src
sudo chmod u+x wgd.sh
sudo ./wgd.sh install &>/dev/null
sudo chmod -R 755 /etc/wireguard
echo -e "${CM}${CL} \r"

echo -en "${GN} Creating wg-dashboard.service... "
service_path="/etc/systemd/system/wg-dashboard.service"
echo "[Unit]
After=netword.service

[Service]
WorkingDirectory=/ect/wgdashboard/src
ExecStart=/usr/bin/python3 /ect/wgdashboard/src/dashboard.py
Restart=always


[Install]
WantedBy=default.target" > $service_path
sudo chmod 664 /etc/systemd/system/wg-dashboard.service
sudo systemctl daemon-reload
sudo systemctl enable wg-dashboard.service &>/dev/null
sudo systemctl start wg-dashboard.service
echo -e "${CM}${CL} \r"

PASS=$(grep -w "root" /etc/shadow | cut -b6);
  if [[ $PASS != $ ]]; then
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
echo -e "${CM}${CL} \r"
  fi

echo -en "${GN} Cleanup... "
apt-get autoremove >/dev/null
apt-get autoclean >/dev/null
rm -rf /var/{cache,log}/* /var/lib/apt/lists/*
echo -e "${CM}${CL} \n"
