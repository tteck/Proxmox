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
$STD apt-get install -y unzip
msg_ok "Installed Dependencies"

msg_info "Installing rdtclient"
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb &>/dev/null
rm packages-microsoft-prod.deb
apt-get update &>/dev/null
apt-get install -y dotnet-sdk-6.0 &>/dev/null
wget -q https://github.com/rogerfar/rdt-client/releases/latest/download/RealDebridClient.zip
unzip -qq RealDebridClient.zip -d /opt/rdtc
mkdir -p /data/db/ # defaults for rdtclient
mkdir -p /data/downloads # defaults for rdtclient
cat <<EOF >/etc/systemd/system/rdtc.service
[Unit]
Description=RdtClient Service

[Service]

WorkingDirectory=/opt/rdtc
ExecStart=/usr/bin/dotnet RdtClient.Web.dll
SyslogIdentifier=RdtClient
User=root

[Install]
WantedBy=multi-user.target
EOF
$STD systemctl daemon-reload
$STD systemctl enable rdtc
$STD systemctl start rdtc
msg_ok "Installed rdtclient"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
