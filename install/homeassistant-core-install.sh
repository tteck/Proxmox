#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
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

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y {git,curl,sudo,mc,bluez,libffi-dev,libssl-dev,libjpeg-dev,zlib1g-dev,autoconf,build-essential,libopenjp2-7,libturbojpeg0-dev,ffmpeg,liblapack3,liblapack-dev,dbus-broker,libpcap-dev,libavdevice-dev,libavformat-dev,libavcodec-dev,libavutil-dev,libavfilter-dev,libmariadb-dev-compat,libatlas-base-dev,python3-pip,python3.12-venv}
msg_ok "Installed Dependencies"

msg_info "Installing Home Assistant-Core"
mkdir /srv/homeassistant
cd /srv/homeassistant
python3 -m venv .
source bin/activate
$STD pip install webrtcvad
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
systemctl enable -q --now homeassistant
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
