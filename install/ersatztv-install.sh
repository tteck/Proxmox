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


msg_info "Installing ErsatzTV " 
RELEASE=$(curl -s https://api.github.com/repos/ErsatzTV/ErsatzTV/releases | grep -oP '"tag_name": "\K[^"]+' | head -n 1)
wget -qO- "https://github.com/ErsatzTV/ErsatzTV/releases/download/${RELEASE}/ErsatzTV-${RELEASE}-linux-x64.tar.gz" | tar -xz -C /opt
mv "/opt/ErsatzTV-${RELEASE}-linux-x64" /opt/ErsatzTV
msg_ok "Installed ErsatzTV"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/ersatzTV.service
[Unit]
Description=ErsatzTV Service
After=multi-user.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/ErsatzTV 
ExecStart=/opt/ErsatzTV/ErsatzTV  
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
systemctl -q --now enable ersatzTV.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
