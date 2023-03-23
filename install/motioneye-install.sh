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

msg_info "Installing Python"
$STD apt-get update
$STD apt-get install -y python2
curl -sSL https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
$STD python2 get-pip.py
$STD apt-get install -y libffi-dev libzbar-dev libzbar0
$STD apt-get install -y python2-dev libssl-dev libcurl4-openssl-dev libjpeg-dev
msg_ok "Installed Python"

msg_info "Installing MotionEye"
$STD apt-get update
$STD pip install motioneye
mkdir -p /etc/motioneye
cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf
mkdir -p /var/lib/motioneye
msg_ok "Installed MotionEye"

msg_info "Creating Service"
cp /usr/local/share/motioneye/extra/motioneye.systemd-unit-local /etc/systemd/system/motioneye.service
$STD systemctl enable motioneye
systemctl start motioneye
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
