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
$STD apt-get install -y git
msg_ok "Installed Dependencies"

RELEASE="$(curl -s https://api.github.com/repos/tobychui/zoraxy/releases | ggrep -oP '"tag_name":\s*"\K[\d.]+?(?=")' | sort -V | tail -n1)"
msg_info "Installing Zoraxy v${RELEASE}"
wget -q "https://github.com/tobychui/zoraxy/releases/download/${RELEASE}/zoraxy_linux_amd64"
install zoraxy_linux_amd64 /usr/bin/zoraxy
echo "${RELEASE}" > "/opt/${APPLICATION}_version.txt"
msg_ok "Installed Zoraxy"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/zoraxy.service
[Unit]
Description=General purpose request proxy and forwarding tool
After=syslog.target network-online.target

[Service]
ExecStart=/usr/bin/zoraxy
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now zoraxy.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
