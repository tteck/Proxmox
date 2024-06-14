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
$STD apt-get install -y git
$STD apt-get install -y mc
$STD apt-get install -y wget
$STD apt-get install -y novnc
$STD apt-get install -y xvfb
$STD apt-get install -y openjdk-11-jdk
$STD apt-get install -y openbox
msg_ok "Installed Dependencies"

msg_info "Installing JDownloader2"
mkdir -p /app/cfg
$STD git clone https://github.com/jlesage/docker-jdownloader-2 /root/djd2
mv /root/djd2/rootfs/defaults/cfg/* /app/cfg/
rm -rf /root/djd2
cd /app
wget -q http://installer.jdownloader.org/JDownloader.jar
msg_ok "Installed JDownloader2"

msg_info "Setting up VNC Server"
mkdir /root/.vnc
secret=$(openssl rand -base64 8)
echo "$secret" >>/root/.vnc/passwd
echo $secret | vncpasswd -f
msg_ok "Setup VNC Server"

msg_info "Creating Service"
mkdir /output
cat <<EOF >/etc/systemd/system/xvfb.service
[Unit]
Description=Virtual Frame Buffer X server
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :1 -screen 0 1280x800x24

[Install]
WantedBy=multi-user.target
EOF
cat <<EOF >/etc/systemd/system/vncserver.service
[Unit]
Description=Start x0vncserver.
After=xvfb.service

[Service]
Type=forking
ExecStart=/usr/bin/x0vncserver -display :1 -PasswordFile=/root/.vnc/passwd
Environment="DISPLAY=:1"
Environment="HOME=/root"
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
cat <<EOF >/etc/systemd/system/novnc.service
[Unit]
Description=NoVNC Web Access Console
After=x0vncserver.service network.target

[Service]
Type=simple
WorkingDirectory=/usr/share/novnc
ExecStart=/usr/share/novnc/utils/launch.sh --vnc localhost:5901
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
cat <<EOF >/etc/systemd/system/jdownloader2.service
[Unit]
Description=JDownloader Service
After=novnc.service

[Service]
Type=simple
WorkingDirectory=/app
ExecStart=/usr/bin/java -jar /app/JDownloader.jar
Restart=always
RestartSec=10
Environment="DISPLAY=:1"

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now xvfb.service
systemctl enable -q --now vncserver.service
systemctl enable -q --now novnc.service
systemctl enable -q --now jdownloader2.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
