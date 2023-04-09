#!/usr/bin/env bash

# Copyright (c) 2021-2023 nicedevil007
# Author: nicedevil007 (nicedevil007ster)
# License: MIT
# https://github.com/nicedevil007/Proxmox/raw/main/LICENSE
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os
default_packages

msg_info "Installing Dependencies"
$STD apk add openssl
$STD apk add argon2
msg_ok "Installed Dependencies"

if NEWTOKEN=$(whiptail --passwordbox "Setup your ADMIN-TOKEN (make it strong)" 10 58 3>&1 1>&2 2>&3); then
  if [[ -z "$NEWTOKEN" ]]; then exit-script; fi
else
  exit-script
fi
clear

msg_info "Installing Alpine-Vaultwarden"
$STD apk add vaultwarden
ADMINTOKEN=$(echo -n ${NEWTOKEN} | argon2 "$(openssl rand -base64 32)" -e -id -k 19456 -t 2 -p 1)
cat <<EOF >/etc/conf.d/vaultwarden
export DATA_FOLDER=/var/lib/vaultwarden
export WEB_VAULT_FOLDER=/var/lib/vaultwarden/web-vault
export WEB_VAULT_ENABLED=true
export ADMIN_TOKEN='$ADMINTOKEN'
export ROCKET_ADDRESS=0.0.0.0
EOF
$STD rc-service vaultwarden start
$STD rc-update add vaultwarden default
msg_ok "Installed Alpine-Vaultwarden"

motd_ssh
root