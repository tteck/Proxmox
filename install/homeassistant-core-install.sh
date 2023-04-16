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

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y \
  make \
  build-essential \
  libjpeg-dev \
  libpcap-dev \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libmariadb-dev-compat \
  autoconf \
  git \
  curl \
  sudo \
  mc \
  llvm \
  libncursesw5-dev \
  xz-utils \
  tzdata \
  bluez \
  tk-dev \
  libxml2-dev \
  libxmlsec1-dev \
  libffi-dev \
  libopenjp2-7 \
  libtiff5 \
  libturbojpeg0-dev \
  liblzma-dev
msg_ok "Installed Dependencies"

msg_info "Installing Linux D-Bus Message Broker"
cat <<EOF >>/etc/apt/sources.list
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free
EOF
$STD apt-get update
$STD apt-get -t bullseye-backports install -y dbus-broker
$STD systemctl enable --now dbus-broker.service
msg_ok "Installed Linux D-Bus Message Broker"

msg_info "Installing pyenv"
$STD git clone https://github.com/pyenv/pyenv.git ~/.pyenv
set +e
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init --path)"\nfi' >> ~/.bashrc  
msg_ok "Installed pyenv"
. ~/.bashrc
set -e
msg_info "Installing Python 3.11.2"
$STD pyenv install 3.11.2
pyenv global 3.11.2
msg_ok "Installed Python 3.11.2"

msg_info "Installing Home Assistant-Core"
mkdir /srv/homeassistant
cd /srv/homeassistant
python3 -m venv .
source bin/activate
$STD pip install --upgrade pip
$STD python3 -m pip install wheel
$STD pip install mysqlclient
$STD pip install psycopg2-binary
$STD pip install homeassistant
mkdir -p /root/.homeassistant
msg_ok "Installed Home Assistant-Core"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/homeassistant.service
[Unit]
Description=Home Assistant
After=network-online.target
[Service]
Type=simple
WorkingDirectory=/root/.homeassistant
ExecStart=/srv/homeassistant/bin/hass -c "/root/.homeassistant"
RestartForceExitStatus=100
[Install]
WantedBy=multi-user.target
EOF
$STD systemctl enable --now homeassistant
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
