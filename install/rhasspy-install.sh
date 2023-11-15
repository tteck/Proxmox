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
$STD apt-get -y install \
    libportaudio2 \
    libatlas3-base \
    libgfortran4 \
    ca-certificates \
    supervisor \
    mosquitto \
    perl \
    curl \
    sox \
    alsa-utils \
    libasound2-plugins \
    jq \
    espeak \
    flite \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-good \
    libsndfile1 \
    libgomp1 \
    libatlas3-base \
    libgfortran4 \
    libopenblas-base \
    libjbig0 \
    liblcms2-2 \
    libopenjp2-7 \
    libtiff5 \
    libwebp6 \
    libwebpdemux2 \
    libwebpmux3 \
    libatomic1 \
    libspeex1 \
    libspeex-dev \
    libspeexdsp1 \
    libspeexdsp-dev
msg_ok "Installed Dependencies"

msg_info "Updating Python"
$STD apt-get install -y \
    python3 \
    libpython3.7 \
    python3-setuptools \
    python3-pip \
    python3-distutils \
msg_ok "Updated Python"

LATEST=$(curl -sL https://api.github.com/repos/rhasspy/rhasspy/releases/latest | grep '"tag_name":' | cut -d'"' -f4)

msg_info "Installing Rhasspy"
wget -q https://github.com/rhasspy/rhasspy/releases/download/${LATEST}/rhasspy_amd64.deb
# Switch out libgfortran5 for libgfortran4 dependency
dpkg-deb --extract rhasspy_amd64.deb tmp
dpkg-deb --control rhasspy_amd64.deb tmp/DEBIAN
sed -i 's/libgfortran4/libgfortran5/' ./tmp/DEBIAN/control
$STD dpkg --build tmp rhasspy_amd64.deb
$STD dpkg -i ./rhasspy_amd64.deb
msg_ok "Installed Rhasspy"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
rm rhasspy_amd64.deb
msg_ok "Cleaned"