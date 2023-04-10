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
cat <<EOF >/etc/conf.d/vaultwarden
export DATA_FOLDER=/var/lib/vaultwarden
export WEB_VAULT_FOLDER=/var/lib/vaultwarden/web-vault
export WEB_VAULT_ENABLED=true
export ADMIN_TOKEN=''
export ROCKET_ADDRESS=0.0.0.0
EOF
$STD rc-service vaultwarden start
$STD rc-update add vaultwarden default
msg_ok "Installed Alpine-Vaultwarden"

motd_ssh
root