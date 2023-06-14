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
$STD apk add newt
$STD apk add curl
$STD apk add openssl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
$STD apk add argon2
msg_ok "Installed Dependencies"

msg_info "Installing Alpine-Vaultwarden"
$STD apk add vaultwarden
sudo sed -i -e 's/# export ADMIN_TOKEN=.*/export ADMIN_TOKEN='\'''\''/' -e '/^# export ROCKET_ADDRESS=0\.0\.0\.0/s/^# //' -e 's|export WEB_VAULT_FOLDER=.*|export WEB_VAULT_FOLDER=/usr/share/webapps/vaultwarden-web/web-vault/|' -e 's|export WEB_VAULT_ENABLED=.*|export WEB_VAULT_ENABLED=true|' /etc/conf.d/vaultwarden
msg_ok "Installed Alpine-Vaultwarden"

WEBVAULT=$(curl -s https://api.github.com/repos/dani-garcia/bw_web_builds/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')  
curl -fsSLO https://github.com/dani-garcia/bw_web_builds/releases/download/$WEBVAULT/bw_web_$WEBVAULT.tar.gz
mkdir -p /usr/share/webapps/vaultwarden-web/

msg_info "Downloading Web-Vault ${WEBVAULT}"
$STD curl -fsSLO https://github.com/dani-garcia/bw_web_builds/releases/download/$WEBVAULT/bw_web_$WEBVAULT.tar.gz
$STD tar -xzf bw_web_$WEBVAULT.tar.gz -C /usr/share/webapps/vaultwarden-web/
rm bw_web_$WEBVAULT.tar.gz
msg_ok "Downloaded Web-Vault ${WEBVAULT}" 

msg_info "Starting Alpine-Vaultwarden"
$STD rc-service vaultwarden start
$STD rc-update add vaultwarden default
msg_info "Started Alpine-Vaultwarden"

motd_ssh
customize
