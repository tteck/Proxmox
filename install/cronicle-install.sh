#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
$STD apt-get install -y make
$STD apt-get install -y g++
$STD apt-get install -y gcc
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_16.x)
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing Cronicle Primary Server"
LATEST=$(curl -sL https://api.github.com/repos/jhuckaby/Cronicle/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
IP=$(hostname -I | awk '{print $1}')
mkdir -p /opt/cronicle
cd /opt/cronicle
$STD tar zxvf <(curl -fsSL https://github.com/jhuckaby/Cronicle/archive/${LATEST}.tar.gz) --strip-components 1
$STD npm install
$STD node bin/build.js dist
sed -i "s/localhost:3012/${IP}:3012/g" /opt/cronicle/conf/config.json
$STD /opt/cronicle/bin/control.sh setup
$STD /opt/cronicle/bin/control.sh start
$STD cp /opt/cronicle/bin/cronicled.init /etc/init.d/cronicled
chmod 775 /etc/init.d/cronicled
$STD update-rc.d cronicled defaults
msg_ok "Installed Cronicle Primary Server"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
