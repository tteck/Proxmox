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
$STD apt-get install -y ufw
$STD apt-get install -y ntp
$STD apt-get install -y unbound

msg_ok "Installed Dependencies"

msg_info "Configuring Unbound"
cat <<EOF >/etc/unbound/unbound.conf.d/pi-hole.conf
server:
  verbosity: 0
  interface: 127.0.0.1
  port: 5335
  do-ip4: yes
  do-udp: yes
  do-tcp: yes
  do-ip6: no
  prefer-ip6: no
  harden-glue: yes
  harden-dnssec-stripped: yes
  use-caps-for-id: no
  edns-buffer-size: 1232
  prefetch: yes
  num-threads: 1
  private-address: 192.168.0.0/16
  private-address: 169.254.0.0/16
  private-address: 172.16.0.0/12
  private-address: 10.0.0.0/8
  private-address: fd00::/8
  private-address: fe80::/10
EOF

cat <<EOF >/etc/dnsmasq.d/99-edns.conf
edns-packet-max=1232
EOF

wget https://www.internic.net/domain/named.root -qO- | sudo tee /var/lib/unbound/root.hints

$STD systemctl enable unbound
$STD systemctl start unbound
msg_ok "Configured Unbound"

msg_info "Installing Pi-hole"
mkdir -p /etc/pihole/
cat <<EOF >/etc/pihole/setupVars.conf
PIHOLE_INTERFACE=eth0
PIHOLE_DNS_1=localhost:5335
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
# View script https://install.pi-hole.net
$STD bash <(curl -fsSL https://install.pi-hole.net) --unattended
msg_ok "Installed Pi-hole"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"