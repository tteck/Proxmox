#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
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
msg_ok "Installed Dependencies"

msg_info "Installing Node.js (Patience)"
$STD apt-get install -y npm
$STD npm cache clean -f
$STD npm install -g n
$STD n 16.20.1
$STD npm install -g pnpm
ln -sf /usr/local/bin/node /usr/bin/node
msg_ok "Installed Node.js"

msg_info "Installing Yarn"
$STD npm install -g yarn
ln -sf /usr/local/bin/yarn /usr/bin/yarn
msg_ok "Installed Yarn"

RELEASE=$(curl -s https://api.github.com/repos/Lissy93/dashy/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
msg_info "Installing Dashy ${RELEASE} (Patience)"
mkdir -p /opt/dashy
wget -qO- https://github.com/Lissy93/dashy/archive/refs/tags/${RELEASE}.tar.gz | tar -xz -C /opt/dashy --strip-components=1
cd /opt/dashy
sed -i 's/NODE_OPTIONS=--openssl-legacy-provider vue-cli-service build/NODE_OPTIONS=yarn vue-cli-service build/' /opt/dashy/package.json
$STD yarn
$STD yarn build
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt
msg_ok "Installed Dashy ${RELEASE}"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/dashy.service
[Unit]
Description=dashy

[Service]
Type=simple
WorkingDirectory=/opt/dashy
ExecStart=/usr/bin/yarn start
[Install]
WantedBy=multi-user.target
EOF
systemctl -q --now enable dashy
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
