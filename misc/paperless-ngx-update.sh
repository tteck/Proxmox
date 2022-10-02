#!/usr/bin/env bash
clear
RELEASE=$(curl -s https://api.github.com/repos/paperless-ngx/paperless-ngx/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
YW=`echo "\033[33m"`
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
RETRY_NUM=10
RETRY_EVERY=3
NUM=$RETRY_NUM
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR="\\r\\033[K"
HOLD="-"
set -e

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

function msg_error() {
    local msg="$1"
    echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

cat << "EOF"
    ____                        __                                     
   / __ \____ _____  ___  _____/ /__  __________    ____  ____ __  __
  / /_/ / __ `/ __ \/ _ \/ ___/ / _ \/ ___/ ___/___/ __ \/ __ `/ |/_/
 / ____/ /_/ / /_/ /  __/ /  / /  __(__  |__  )___/ / / / /_/ />  <  
/_/    \__,_/ .___/\___/_/  /_/\___/____/____/   /_/ /_/\__, /_/|_|  
           /_/           UPDATE                        /____/        
EOF

while true; do
    read -p "This will Update Paperless-ngx to $RELEASE. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
sleep 2
msg_info "Stopping Paperless-ngx"
systemctl stop paperless-consumer paperless-webserver paperless-scheduler
sleep 1
msg_ok "Stopped Paperless-ngx"

msg_info "Updating to ${RELEASE}"
wget https://github.com/paperless-ngx/paperless-ngx/releases/download/$RELEASE/paperless-ngx-$RELEASE.tar.xz &>/dev/null
tar -xf paperless-ngx-$RELEASE.tar.xz &>/dev/null
cp -r /opt/paperless/paperless.conf paperless-ngx/
cp -r paperless-ngx/* /opt/paperless/
cd /opt/paperless
sed -i -e 's|-e git+https://github.com/paperless-ngx/django-q.git|git+https://github.com/paperless-ngx/django-q.git|' /opt/paperless/requirements.txt
pip install -r requirements.txt &>/dev/null
cd /opt/paperless/src
/usr/bin/python3 manage.py migrate &>/dev/null
msg_ok "Updated to ${RELEASE}"

msg_info "Cleaning up"
cd ~
rm paperless-ngx-$RELEASE.tar.xz
rm -rf paperless-ngx
msg_ok "Cleaned"

msg_info "Starting Paperless-ngx"
systemctl start paperless-consumer paperless-webserver paperless-scheduler
sleep 1
msg_ok "Finished Update"
echo -e "\n${BL}It may take a minute or so for Paperless-ngx to become available.${CL}\n"
