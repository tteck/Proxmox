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
$STD apt-get install -y gnupg2 
$STD apt-get install -y ca-certificates 
$STD apt-get install -y lsb-release 
$STD apt-get install -y debian-archive-keyring
msg_ok "Installed Dependencies"

msg_info "Installing Nginx"
wget -qO- https://nginx.org/keys/nginx_signing.key | gpg --dearmor >/usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
$STD apt-get update
$STD apt-get install -y nginx
msg_ok "Installed Nginx"

RELEASE=$(curl -s https://api.github.com/repos/bunkerity/bunkerweb/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
msg_info "Installing BunkerWeb v${RELEASE}"
export UI_WIZARD=1
curl -sSL https://packagecloud.io/install/repositories/bunkerity/bunkerweb/script.deb.sh | bash &>/dev/null
$STD apt-get install -y bunkerweb=${RELEASE}
cat <<EOF >/etc/apt/preferences.d/bunkerweb
Package: bunkerweb
Pin: version ${RELEASE}
Pin-Priority: 1001
EOF
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt
msg_ok "Installed BunkerWeb v${RELEASE}"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
