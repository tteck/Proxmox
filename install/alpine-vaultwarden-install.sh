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

msg_info "Installing Alpine-Vaultwarden"
$STD apk add vaultwarden
ADMINTOKEN=''
if NEWTOKEN=$(whiptail --passwordbox "Setup your ADMIN_TOKEN (make it strong)" 10 58 3>&1 1>&2 2>&3); then
  if [[ ! -z "$NEWTOKEN" ]]; then
    ADMINTOKEN=$(echo -n ${NEWTOKEN} | argon2 "$(openssl rand -base64 32)" -e -id -k 19456 -t 2 -p 1)
  else
    clear
    echo -e "⚠  User didn't setup ADMIN_TOKEN, admin panel is disabled! \n"
  fi
else
  clear
  echo -e "⚠  User didn't setup ADMIN_TOKEN, admin panel is disabled! \n"
fi
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