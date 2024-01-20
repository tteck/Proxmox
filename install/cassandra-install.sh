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
$STD apt-get install -y apt-transport-https
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

msg_info "Installing OpenJDK"
wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor >/etc/apt/trusted.gpg.d/adoptium.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main' >/etc/apt/sources.list.d/adoptium.list
$STD apt-get update
$STD apt-get install -y temurin-11-jdk
msg_ok "Installed OpenJDK"

msg_info "Installing Cassandra"
wget -qO- https://downloads.apache.org/cassandra/KEYS | gpg --dearmor >/etc/apt/trusted.gpg.d/cassandra.gpg
echo "deb https://debian.cassandra.apache.org 41x main" >/etc/apt/sources.list.d/cassandra.sources.list
$STD apt-get update
$STD apt-get install -y cassandra cassandra-tools
sed -i -e 's/^rpc_address: localhost/#rpc_address: localhost/g' -e 's/^# rpc_interface: eth1/rpc_interface: eth0/g' /etc/cassandra/cassandra.yaml
msg_ok "Installed Cassandra"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/cassandra.service
[Unit]
Description=Cassandra
After=network.target

[Service]
PIDFile=/tmp/cassandra.pid
ExecStart=/opt/cassandra/bin/cassandra -p /tmp/cassandra.pid -R
StandardOutput=append:/tmp/cassandra.log
StandardError=append:/tmp/cassandra-error.log
LimitNOFILE=100000
LimitMEMLOCK=infinity
LimitNPROC=32768
LimitAS=infinity

[Install]
WantedBy=default.target
EOF
systemctl enable -q --now cassandra.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
