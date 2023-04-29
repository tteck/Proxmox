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
$STD apt-get install -y git
$STD apt-get install -y cifs-utils
msg_ok "Installed Dependencies"

msg_info "Installing Motion"
$STD apt-get install -y motion
systemctl stop motion
$STD systemctl disable motion
msg_ok "Installed Motion"

msg_info "Installing FFmpeg"
$STD apt-get install -y ffmpeg v4l-utils
msg_ok "Installed FFmpeg"

msg_info "Installing Python3-pip"
$STD apt-get install -y python3-pip
msg_ok "Installed Python3-pip"

msg_info "Installing MotionEye"
$STD apt-get update
$STD pip install git+https://github.com/motioneye-project/motioneye.git@dev
mkdir -p /etc/motioneye
chown -R root:root /etc/motioneye
chmod -R 777 /etc/motioneye
cp /usr/local/lib/python3.9/dist-packages/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf
mkdir -p /var/lib/motioneye
msg_ok "Installed MotionEye"

msg_info "Creating Service"
cp /usr/local/lib/python3.9/dist-packages/motioneye/extra/motioneye.systemd /etc/systemd/system/motioneye.service
systemctl enable -q --now motioneye
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
