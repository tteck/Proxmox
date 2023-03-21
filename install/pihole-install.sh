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
$STD apt-get install -y ufw
$STD apt-get install -y ntp
msg_ok "Installed Dependencies"

msg_info "Installing Pi-hole"
systemctl stop systemd-resolved
echo "DNSStubListener=no" >>/etc/systemd/resolved.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
mkdir -p /etc/pihole/
cat <<EOF >/etc/pihole/setupVars.conf
PIHOLE_INTERFACE=eth0
PIHOLE_DNS_1=8.8.8.8
PIHOLE_DNS_2=8.8.4.4
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
CACHE_SIZE=10000
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSMASQ_LISTENING=local
WEBPASSWORD=$(openssl rand -base64 48)
BLOCKING_ENABLED=true
EOF

$STD bash <(curl -fsSL https://install.pi-hole.net) /dev/stdin --unattended
msg_ok "Installed Pi-hole"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
