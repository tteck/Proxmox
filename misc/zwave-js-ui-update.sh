#!/usr/bin/env bash
RELEASE=$(curl -s https://api.github.com/repos/zwave-js/zwave-js-ui/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }') 
set -e
YW=`echo "\033[33m"`
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR="\\r\\033[K"
HOLD="-"
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
clear
cat << "EOF"
 _____                                  _______    __  ______
/__  /_      ______ __   _____         / / ___/   / / / /  _/
  / /| | /| / / __ `/ | / / _ \   __  / /\__ \   / / / // /  
 / /_| |/ |/ / /_/ /| |/ /  __/  / /_/ /___/ /  / /_/ // /   
/____/__/|__/\__,_/ |___/\___/   \____//____/   \____/___/   
                             UPDATE
                             
EOF

while true; do
    read -p "This will update ZWave JS UI to $RELEASE. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
if [ ! -d /opt/zwave-js-ui ]; then msg_error "No Zwave JS UI Install Detected!"; exit; fi

msg_info "Stopping Z-wave JS UI"
systemctl stop zwave-js-ui.service
msg_ok "Stopped Z-wave JS UI"

msg_info "Updating Z-wave JS UI"
wget https://github.com/zwave-js/zwave-js-ui/releases/download/${RELEASE}/zwave-js-ui-${RELEASE}-linux.zip &>/dev/null
unzip zwave-js-ui-${RELEASE}-linux.zip &>/dev/null
\cp -R zwave-js-ui-linux /opt/zwave-js-ui
msg_ok "Updated Z-wave JS UI"

msg_info "Updating Z-wave JS UI service file"
cat << EOF > /etc/systemd/system/zwave-js-ui.service
[Unit]
Description=zwave-js-ui
Wants=network-online.target
After=network-online.target
[Service]
User=root
WorkingDirectory=/opt/zwave-js-ui
ExecStart=/opt/zwave-js-ui/zwave-js-ui-linux
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
msg_ok "Updated Z-wave JS UI service file"

msg_info "Cleanup"
rm -rf zwave-js-ui-${RELEASE}-linux.zip zwave-js-ui-linux store
msg_ok "Cleaned"

msg_info "Starting Z-wave JS UI"
systemctl enable --now zwave-js-ui.service
msg_info "Started Z-wave JS UI"

msg_ok "Completed Successfully!\n"
