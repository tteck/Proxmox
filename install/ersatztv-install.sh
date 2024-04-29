#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Source: https://github.com/ErsatzTV/ErsatzTV

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y --no-install-recommends \
  ffmpeg \
  build-essential \
  unzip \
  pkg-config \
  curl \
  sudo \
  git \
  make \
  mc
msg_ok "Installed Dependencies"


msg_info "Installing ErsatzTV (Patience)" 
cd /opt
RELEASE=$(curl -s https://api.github.com/repos/ErsatzTV/ErsatzTV/releases | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
LATEST_RELEASE=$(echo $RELEASE | awk '{print $1}')
echo $LATEST_RELEASE
wget -q --no-check-certificate "https://github.com/ErsatzTV/ErsatzTV/releases/download/${LATEST_RELEASE}/ErsatzTV-${LATEST_RELEASE}-linux-x64.tar.gz"
tar -xf ErsatzTV-${LATEST_RELEASE}-linux-x64.tar.gz 
mv ErsatzTV-${LATEST_RELEASE}-linux-x64 ErsatzTV
rm -R ErsatzTV-${LATEST_RELEASE}-linux-x64.tar.gz 
msg_ok "Installed ErsatzTV"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/ersatzTV.service
[Unit]
Description=ErsatzTV Service
After=multi-user.target

[Service]
User=root
WorkingDirectory=/opt/ErsatzTV 
ExecStart=/opt/ErsatzTV/ErsatzTV  
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
systemctl -q --now enable ersatzTV.service
systemctl start ersatzTV.service 
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
