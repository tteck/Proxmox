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
$STD apt-get install -y openjdk-8-jdk
msg_ok "Installed Dependencies"


msg_info "Installing Cassandra"
cd /opt
wget -q https://dlcdn.apache.org/cassandra/4.1.3/apache-cassandra-4.1.3-bin.tar.gz
$STD tar -xvzf apache-cassandra-4.1.3-bin.tar.gz
mv apache-cassandra-4.1.3 cassandra
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