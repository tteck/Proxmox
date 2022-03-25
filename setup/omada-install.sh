#!/usr/bin/env bash

# Shamelessly inspired by https://github.com/mbentley/docker-omada-controller/blob/master/install.sh

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

# Omada Variables
OMADA_DIR="/opt/tplink/EAPController"
OMADA_VER=5.1.7
OMADA_TAR="Omada_SDN_Controller_v${OMADA_VER}_Linux_x64.tar.gz"
OMADA_URL="https://static.tp-link.com/upload/software/2022/202203/20220322/${OMADA_TAR}"

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

echo -en "${GN} Updating Container OS... "
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing Dependencies... "
apt-get -qqy install --no-install-recommends \
    curl \
    gosu \
    mongodb-server-core \
    net-tools \
    openjdk-8-jre-headless \
    tzdata \
    wget &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Downloading Omada Controller... "
wget "${OMADA_URL}" &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Extracting Omada Controller... "
cd /tmp
tar zxvf "${OMADA_TAR}"
rm -f "${OMADA_TAR}"
cd Omada_SDN_Controller_*
echo -e "${CM}${CL} \r"
 
echo -en "${GN} Creating Install Destination... "
mkdir "${OMADA_DIR}" -p &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing Omada... "
NAMES=( bin data properties keystore lib install.sh uninstall.sh )
for NAME in "${NAMES[@]}"
do
  cp "${NAME}" "${OMADA_DIR}" -r &>/dev/null
done
echo -e "${CM}${CL} \r"

echo -en "${GN} Creating Symlinks... "
ln -sf "$(which mongod)" "${OMADA_DIR}/bin/mongod" &>/dev/null
chmod 755 "${OMADA_DIR}"/bin/* &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Setting Up Omada User... "
groupadd -g 508 omada &>/dev/null
useradd -u 508 -g 508 -d "${OMADA_DIR}" omada &>/dev/null
mkdir "${OMADA_DIR}/logs" "${OMADA_DIR}/work" &>/dev/null
chown -R omada:omada "${OMADA_DIR}/data" "${OMADA_DIR}/logs" "${OMADA_DIR}/work" &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Creating Omada Service... "
cat <<EOF > /etc/systemd/system/omada.service
[Unit]
Description=omada

[Service]
Type=simple
WorkingDirectory=/opt/tplink/EAPController/lib
ExecStart=/usr/bin/java -server -Xms128m -Xmx1024m -XX:MaxHeapFreeRatio=60 -XX:MinHeapFreeRatio=30 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/tplink/EAPController/logs/java_heapdump.hprof -Djava.awt.headless=true -cp /opt/tplink/EAPController/lib/*::/opt/tplink/EAPController/properties: com.tplink.smb.omada.starter.OmadaLinuxMain
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl start omada &>/dev/null
sudo systemctl enable omada &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleaning Up... "
apt-get autoremove >/dev/null
apt-get autoclean >/dev/null
rm -rf /tmp/* /var/lib/apt/lists/*
echo -e "${CM}${CL} \n"
