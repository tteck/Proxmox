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
$STD apk add vaultwarden-web-vault
cat <<EOF >>/etc/conf.d/vaultwarden
export ADMIN_TOKEN=''
export WEB_VAULT_FOLDER=/usr/share/webapps/vaultwarden-web/
export WEB_VAULT_ENABLED=true
export ROCKET_ADDRESS=0.0.0.0
EOF
$STD rc-service vaultwarden start
$STD rc-update add vaultwarden default
msg_ok "Installed Alpine-Vaultwarden"

motd_ssh
customize
