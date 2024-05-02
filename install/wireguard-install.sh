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
$STD apt-get install -y gunicorn
msg_ok "Installed Dependencies"

msg_info "Installing WireGuard (using pivpn.io)"
OPTIONS_PATH='/options.conf'
cat >$OPTIONS_PATH <<EOF
IPv4dev=eth0
install_user=root
VPN=wireguard
pivpnNET=$(printf "10.%d.%d.0" $((RANDOM % 256)) $((RANDOM % 256)))
subnetClass=24
ALLOWED_IPS="0.0.0.0/0, ::0/0"
pivpnMTU=1420
pivpnPORT=51820
pivpnDNS1=1.1.1.1
pivpnDNS2=8.8.8.8
pivpnHOST=
pivpnPERSISTENTKEEPALIVE=25
UNATTUPG=1
EOF
$STD bash <(curl -fsSL https://install.pivpn.io) --unattended options.conf
msg_ok "Installed WireGuard"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
