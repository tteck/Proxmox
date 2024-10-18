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

msg_info "Installing Kibana"
$STD apt-get update
$STD apt-get install -y kibana

echo 'export PATH=/usr/share/kibana/bin:$PATH' >>~/.bashrc
export PATH=/usr/share/kibana/bin:$PATH
msg_ok "Installed Kibana"

msg_info "Configuring hostname"
sed -i -E "s/#server.host: \"localhost\"/server.host: \"0.0.0.0\"/" /etc/kibana/kibana.yml
msg_ok "Configured hostname"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/Kibana.service
[Unit]
Description=Kibana
Documentation=https://www.elastic.co/guide/en/kibana/8.15/index.html
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=kibana
Group=kibana
PrivateTmp=true

Environment=KBN_HOME=/usr/share/kibana
Environment=KBN_PATH_CONF=/etc/kibana

EnvironmentFile=-/etc/default/kibana
EnvironmentFile=-/etc/sysconfig/kibana

ExecStart=/usr/share/kibana/bin/kibana

Restart=on-failure
RestartSec=3

StartLimitBurst=3
StartLimitInterval=60

WorkingDirectory=/usr/share/kibana

StandardOutput=journal
StandardError=inherit

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now Kibana.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
