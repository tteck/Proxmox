#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Source: https://github.com/matze/wastebin

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y --no-install-recommends \
  build-essential \
  unzip \
  curl \
  sudo \
  git \
  make \
  mc
msg_ok "Installed Dependencies"

msg_info "Installing Rust (Patience)" 
$STD bash <(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs) -y
source ~/.cargo/env
msg_ok "Installed Rust" 

msg_info "Installing Wastebin (Patience)"
RELEASE=$(curl -s https://api.github.com/repos/matze/wastebin/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
wget -q "https://github.com/matze/wastebin/archive/refs/tags/${RELEASE}.zip"
unzip -q ${RELEASE}.zip
mv wastebin-${RELEASE} /opt/wastebin
rm -R ${RELEASE}.zip 
cd /opt/wastebin
cargo build -q --release
msg_ok "Installed Wastebin"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/wastebin.service
[Unit]
Description=Start Wastebin Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/wastebin
ExecStart=/root/.cargo/bin/cargo run --release --quiet

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now wastebin.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
