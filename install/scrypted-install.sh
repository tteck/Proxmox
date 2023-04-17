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
$STD apt-get -y install software-properties-common apt-utils
$STD apt-get -y update
$STD apt-get -y upgrade
$STD apt-get install -y avahi-daemon
$STD apt-get -y install \
    build-essential \
    gcc \
    gir1.2-gtk-3.0 \
    libcairo2-dev \
    libgirepository1.0-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libgif-dev \
    libopenjp2-7 \
    libpango1.0-dev \
    librsvg2-dev \
    pkg-config \
    curl \
    sudo \
    mc
msg_ok "Installed Dependencies"

msg_info "Installing GStreamer"
$STD apt-get -y install \
    gstreamer1.0-tools \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-alsa
msg_ok "Installed GStreamer"

msg_info "Setting up Node.js Repository"
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_18.x)
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing Python3"
$STD apt-get -y install \
    python3 \
    python3-dev \
    python3-gi \
    python3-gst-1.0 \
    python3-matplotlib \
    python3-numpy \
    python3-opencv \
    python3-pil \
    python3-pip \
    python3-setuptools \
    python3-skimage \
    python3-wheel
$STD python3 -m pip install --upgrade pip
$STD python3 -m pip install aiofiles debugpy typing_extensions typing
msg_ok "Installed Python3"

read -r -p "Would you like to add Coral Edge TPU support? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
msg_info "Adding Coral Edge TPU Support"
$STD apt-key add <(curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg)
sh -c 'echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" > /etc/apt/sources.list.d/coral-edgetpu.list'
$STD apt-get -y update
$STD apt-get -y install libedgetpu1-std
msg_ok "Coral Edge TPU Support Added"
fi

msg_info "Installing Scrypted"
$STD sudo -u root npx -y scrypted@latest install-server
msg_info "Installed Scrypted"

msg_info "Creating Service"
service_path="/etc/systemd/system/scrypted.service"
echo "[Unit]
Description=Scrypted service
After=network.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/bin/npx -y scrypted serve
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target" >$service_path
$STD systemctl enable --now scrypted.service
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
