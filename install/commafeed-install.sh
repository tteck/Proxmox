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
msg_ok "Installed Dependencies"

msg_info "Installing Azul Zulu"
wget -qO /etc/apt/trusted.gpg.d/zulu-repo.asc "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB1998361219BD9C9"
wget -q https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb
$STD dpkg -i zulu-repo_1.0.0-3_all.deb
$STD apt-get update
$STD apt-get -y install zulu17-jdk
msg_ok "Installed Azul Zulu"

msg_info "Installing CommaFeed"
mkdir /opt/commafeed && cd /opt/commafeed
wget -q https://github.com/Athou/commafeed/releases/latest/download/commafeed.jar
wget -q https://github.com/Athou/commafeed/releases/latest/download/config.yml.example -O config.yml
msg_ok "Installed CommaFeed"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/commafeed.service
[Unit]
Description=CommaFeed Service
After=network.target

[Service]
ExecStart=/usr/bin/java -Djava.net.preferIPv4Stack=true -jar /opt/commafeed/commafeed.jar server /opt/commafeed/config.yml
WorkingDirectory=/opt/commafeed/
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now commafeed.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf zulu-repo_1.0.0-3_all.deb
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
