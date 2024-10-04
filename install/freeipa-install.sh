#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: IEatCodeDaily
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
$STD dnf install -y freeipa-server freeipa-server-dns
msg_ok "Installed Dependencies"

msg_info "Configuring FreeIPA"
  
SERVER_NAME=$(echo "$HN" | cut -d. -f1)
REALM=$(echo "${DOMAIN}" | tr '[:lower:]' '[:upper:]')
  
$STD hostnamectl set-hostname $HN $redirect
$STD bash -c "'echo '127.0.0.1 $HN $SERVER_NAME' >> /etc/hosts'"
  
$STD ipa-server-install \
    --realm=$REALM \
    --domain=$DOMAIN \
    --ds-password="changeme" \
    --admin-password="changeme" \
    --hostname=$HN \
    --setup-dns \
    --no-forwarders \
    --no-ntp \
    --unattended
  
  if [ $? -ne 0 ]; then
    msg_error "FreeIPA installation failed. Please check the logs in the container at /var/log/ipaserver-install.log"
    exit 1
  fi
  
msg_ok "Configured FreeIPA"

msg_info "Starting FreeIPA services"
$STD systemctl enable --now ipa
msg_ok "Started FreeIPA services"

motd_ssh
customize
