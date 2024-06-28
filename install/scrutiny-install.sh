#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Source: https://github.com/AnalogJ/scrutiny

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  sudo \
  curl \
  smartmontools  \
  make \
  mc \
  lsb-base \
  lsb-release \
  gnupg2
msg_ok "Installed Dependencies"

msg_info "Setting up InfluxDB Repository"
wget -qO- https://repos.influxdata.com/influxdata-archive_compat.key | gpg --dearmor > /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main" > /etc/apt/sources.list.d/influxdata.list
msg_ok "Set up InfluxDB Repository"

msg_info "Installing InfluxDB"
$STD apt-get update
$STD apt-get install -y influxdb2
systemctl enable -q --now influxdb
msg_ok "Installed InfluxDB"

msg_info "Installing Scrutiny WebApp"
mkdir -p /opt/scrutiny/{config,web,bin}
RELEASE=$(curl -s https://api.github.com/repos/analogj/scrutiny/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt
wget -q -O /opt/scrutiny/config/scrutiny.yaml https://raw.githubusercontent.com/AnalogJ/scrutiny/master/example.scrutiny.yaml
wget -q -O /opt/scrutiny/bin/scrutiny-web-linux-amd64 "https://github.com/AnalogJ/scrutiny/releases/download/${RELEASE}/scrutiny-web-linux-amd64"
wget -q -O /opt/scrutiny/web/scrutiny-web-frontend.tar.gz "https://github.com/AnalogJ/scrutiny/releases/download/${RELEASE}/scrutiny-web-frontend.tar.gz"
cd /opt/scrutiny/web 
tar xzf scrutiny-web-frontend.tar.gz --strip-components 1 -C .
chmod +x /opt/scrutiny/bin/scrutiny-web-linux-amd64
msg_ok "Installed Scrutiny WebApp"

msg_info "Setup Service" 
cat <<EOF >/etc/systemd/system/scrutiny.service
[Unit]
Description=Scrutiny - Hard Drive Monitoring and Webapp
After=network.target

[Service]
Type=simple
ExecStart=/opt/scrutiny/bin/scrutiny-web-linux-amd64 start --config /opt/scrutiny/config/scrutiny.yaml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now scrutiny.service
msg_ok "Created and enabled Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
