#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
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

msg_info "Installing Collabora Online"
wget -q -O /usr/share/keyrings/collaboraonline-release-keyring.gpg https://collaboraoffice.com/downloads/gpg/collaboraonline-release-keyring.gpg
cat <<EOF >/etc/apt/sources.list.d/collaboraonline.sources
Types: deb
URIs: https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-deb
Suites: ./
Signed-By: /usr/share/keyrings/collaboraonline-release-keyring.gpg
EOF
$STD apt update 
$STD apt install -y coolwsd code-brand collaboraoffice*
sed -i 's|<enable type="bool" desc="Controls whether SSL encryption between coolwsd and the network is enabled (do not disable for production deployment). If default is false, must first be compiled with SSL support to enable." default="true">true</enable>|<enable type="bool" desc="Controls whether SSL encryption between coolwsd and the network is enabled (do not disable for production deployment). If default is false, must first be compiled with SSL support to enable." default="true">false</enable>|g' /etc/coolwsd/coolwsd.xml
sed -i 's|<termination desc="Connection via proxy where coolwsd acts as working via https, but actually uses http." type="bool" default="true">false</termination>|<termination desc="Connection via proxy where coolwsd acts as working via https, but actually uses http." type="bool" default="true">true</termination>|g' /etc/coolwsd/coolwsd.xml
systemctl restart coolwsd
msg_ok "Installed Collabora Online"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
