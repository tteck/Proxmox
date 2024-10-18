#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: T.H. (ELKozel)
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

msg_info "Setting up Elastic Repository"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" >/etc/apt/sources.list.d/elastic-8.x.list
msg_ok "Set up Elastic Repository"

msg_info "Installing Elastcisearch"
$STD apt-get update
$STD apt-get install -y elasticsearch
msg_ok "Installed Elastcisearch"

msg_info "Configuring Elasticsearch Memory"
sed -i -E 's/## -Xms[0-9]+[Ggm]/-Xms3g/' /etc/elasticsearch/jvm.options
sed -i -E 's/## -Xmx[0-9]+[Ggm]/-Xmx3g/' /etc/elasticsearch/jvm.options
msg_ok "Elastcisearch Configured to use 3GB of RAM"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/Elasticsearch.service
[Unit]
Description=Elasticsearch
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
NotifyAccess=all
RuntimeDirectory=elasticsearch
PrivateTmp=true
Environment=ES_HOME=/usr/share/elasticsearch
Environment=ES_PATH_CONF=/etc/elasticsearch
Environment=PID_DIR=/var/run/elasticsearch
Environment=ES_SD_NOTIFY=true
EnvironmentFile=-/etc/default/elasticsearch

WorkingDirectory=/usr/share/elasticsearch

User=elasticsearch
Group=elasticsearch

ExecStart=/usr/share/elasticsearch/bin/systemd-entrypoint -p \${PID_DIR}/elasticsearch.pid --quiet

StandardOutput=journal
StandardError=inherit

LimitNOFILE=65535
LimitNPROC=4096
LimitAS=infinity
LimitFSIZE=infinity

TimeoutStopSec=0

KillSignal=SIGTERM
KillMode=process
SendSIGKILL=no
SuccessExitStatus=143

TimeoutStartSec=900

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now Elasticsearch.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"