#!/usr/bin/env bash
set -e
PP=`echo "\e[1;35m"`
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
while true; do
    read -p "This will Update Heimdall Dashboard. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${PP}
  _    _      _               _       _ _   _____            _     _                         _ 
 | |  | |    (_)             | |     | | | |  __ \          | |   | |                       | |
 | |__| | ___ _ _ __ ___   __| | __ _| | | | |  | | __ _ ___| |__ | |__   ___   __ _ _ __ __| |
 |  __  |/ _ \ |  _   _ \ / _  |/ _  | | | | |  | |/ _  / __|  _ \|  _ \ / _ \ / _  |  __/ _  |
 | |  | |  __/ | | | | | | (_| | (_| | | | | |__| | (_| \__ \ | | | |_) | (_) | (_| | | | (_| |
 |_|  |_|\___|_|_| |_| |_|\__,_|\__,_|_|_| |_____/ \__,_|___/_| |_|_.__/ \___/ \__,_|_|  \__,_|
                  ${RD}UPDATE
${CL}"
}

header_info

echo -en "${GN} Stopping Heimdall Dashboard... "
systemctl disable heimdall.service &>/dev/null
systemctl stop heimdall
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Backing up Data... "
if [ -d "/opt/Heimdall-2.4.6" ]; then
  cp -R /opt/Heimdall-2.4.6/database database-backup
  cp -R /opt/Heimdall-2.4.6/public public-backup
  elif [[ -d "/opt/Heimdall-2.4.7b" ]]; then
  cp -R /opt/Heimdall-2.4.7b/database database-backup
  cp -R /opt/Heimdall-2.4.7b/public public-backup
  elif [[ -d "/opt/Heimdall-2.4.8" ]]; then
  cp -R /opt/Heimdall-2.4.8/database database-backup
  cp -R /opt/Heimdall-2.4.8/public public-backup
  else
  cp -R /opt/Heimdall/database database-backup
  cp -R /opt/Heimdall/public public-backup
fi
sleep 1
echo -e "${CM}${CL} \r"

RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/Heimdall/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
echo -en "${GN} Updating Heimdall Dashboard to ${RELEASE}... "
curl --silent -o ${RELEASE}.tar.gz -L "https://github.com/linuxserver/Heimdall/archive/${RELEASE}.tar.gz" &>/dev/null
tar xvzf ${RELEASE}.tar.gz &>/dev/null
VER=$(curl -s https://api.github.com/repos/linuxserver/Heimdall/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 3, length($2)-4) }')

if [ ! -d "/opt/Heimdall" ]; then
  mv Heimdall-${VER} /opt/Heimdall  
  else
  cp -R Heimdall-${VER}/* /opt/Heimdall
fi
echo -e "${CM}${CL} \r"

service_path="/etc/systemd/system/heimdall.service"
echo "[Unit]
Description=Heimdall
After=network.target

[Service]
Restart=always
RestartSec=5
Type=simple
User=root
WorkingDirectory=/opt/Heimdall
ExecStart="/usr/bin/php" artisan serve --port 7990 --host 0.0.0.0
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target" > $service_path

echo -en "${GN} Restoring Data... "
cp -R database-backup/* /opt/Heimdall/database
cp -R public-backup/* /opt/Heimdall/public
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleanup... "
if [ -d "/opt/Heimdall-2.4.6" ]; then
  rm -rf /opt/Heimdall-2.4.6
  rm -rf /opt/v2.4.6.tar.gz
  elif [[ -d "/opt/Heimdall-2.4.7b" ]]; then
  rm -rf /opt/Heimdall-2.4.7b
  rm -rf /opt/v2.4.7b.tar.gz
  elif [[ -d "/opt/Heimdall-2.4.8" ]]; then
  rm -rf /opt/Heimdall-2.4.8
  rm -rf /opt/v2.4.8.tar.gz
fi

rm -rf ${RELEASE}.tar.gz
rm -rf Heimdall-${VER}
rm -rf public-backup
rm -rf database-backup
rm -rf Heimdall
sleep 1
echo -e "${CM}${CL} \r"

echo -en "${GN} Starting Heimdall Dashboard... "
systemctl enable --now heimdall.service &>/dev/null
sleep 2
echo -e "${CM}${CL} \r"

echo -en "${GN} Finished! ${CL}\n"

