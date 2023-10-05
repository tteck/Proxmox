#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies, (Patience)"
$STD apt-get install -y \
  git \
  curl \
  sudo \
  mc \
  bluez \
  libffi-dev \
  libssl-dev \
  libjpeg-dev \
  zlib1g-dev \
  autoconf \
  build-essential \
  libopenjp2-7 \
  libturbojpeg0-dev \
  ffmpeg \
  liblapack3 \
  liblapack-dev \
  dbus-broker \
  libpcap-dev \
  libmariadb-dev-compat \
  libatlas-base-dev
msg_ok "Installed Dependencies"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv

msg_ok "Updated Python3"

if [[ "$PCT_OSVERSION" == "11" ]]; then
  msg_info "Installing pyenv"
  $STD apt-get install -y \
    make \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    llvm \
    libbz2-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev
  $STD git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  set +e
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >>~/.bashrc
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.bashrc
  echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init --path)"\nfi' >>~/.bashrc
  msg_ok "Installed pyenv"
  . ~/.bashrc

  set -e
  msg_info "Installing Python 3.11.3 (Patience)"
  $STD pyenv install 3.11.3
  pyenv global 3.11.3
  msg_ok "Installed Python 3.11.3"
fi

msg_info "Installing Home Assistant-Core"
mkdir /srv/homeassistant
cd /srv/homeassistant
python3 -m venv .
source bin/activate
$STD pip install --upgrade pip
$STD python3 -m pip install wheel
$STD pip install homeassistant
$STD pip install mysqlclient
$STD pip install psycopg2-binary
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
Restart=always
RestartForceExitStatus=100
[Install]
WantedBy=multi-user.target
EOF
$STD systemctl enable --now homeassistant
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
