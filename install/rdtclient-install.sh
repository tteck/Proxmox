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

msg_info "Installing ASP.NET Core Runtime"
$STD bash -c "$(wget --no-cache -qLO - https://dot.net/v1/dotnet-install.sh)"
ln -s /root/.dotnet/dotnet /usr/bin/dotnet
msg_ok "Installed ASP.NET Core Runtime"
msg_info "Installing rdtclient"
wget -q https://github.com/rogerfar/rdt-client/releases/latest/download/RealDebridClient.zip
unzip -qq RealDebridClient.zip -d /opt/rdtc
rm RealDebridClient.zip
mkdir -p /data/db/ # defaults for rdtclient
mkdir -p /data/downloads # defaults for rdtclient
msg_info "Installed rdtclient"
msg_info "Creating Service"
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
$STD systemctl enable -q --now rdtc
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
