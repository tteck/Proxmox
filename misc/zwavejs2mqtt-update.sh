#!/usr/bin/env bash
set -e
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR

function error_exit() {
  trap - ERR
  local reason="Unknown failure occured."
  local msg="${1:-$reason}"
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  exit $EXIT
}

echo -en "${GN} Updating Zwavejs2MQTT... "
systemctl stop zwavejs2mqtt.service
cd /opt/zwavejs2mqtt
curl -s https://api.github.com/repos/zwave-js/zwavejs2mqtt/releases/latest | grep "browser_download_url.*zip" | cut -d : -f 2,3 | tr -d \" | wget -i - &>/dev/null
unzip -o zwavejs2mqtt-v*.zip zwavejs2mqtt &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Checking Service... "
SERVICE=/etc/systemd/system/zwavejs2mqtt.service
cat <<EOF > $SERVICE
[Unit]
Description=ZWavejs2MQTT
Wants=network-online.target
After=network-online.target
[Service]
User=root
WorkingDirectory=/opt/zwavejs2mqtt
ExecStart=/opt/zwavejs2mqtt/zwavejs2mqtt
[Install]
WantedBy=multi-user.target
EOF
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleanup... "
rm zwavejs2mqtt-v*.zip
systemctl --system daemon-reload
systemctl start zwavejs2mqtt.service
systemctl enable zwavejs2mqtt.service &>/dev/null
echo -e "${CM}${CL} \n"

echo -e "${GN} Finished ${CL}"

