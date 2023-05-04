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
$STD apt-get install -y pip
msg_ok "Installed Dependencies"

msg_info "Installing Change Detection"
mkdir /opt/changedetection
$STD pip3 install changedetection.io
$STD python3 -m pip install dnspython==2.2.1
msg_ok "Installed Change Detection"

msg_info "browserless Playwright"
mkdir /opt/browserless
$STD curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
$STD apt install python3-dev python3-pip nodejs build-essential ca-certificates curl dumb-init ffmpeg fontconfig fonts-freefont-ttf fonts-gfs-neohellenic fonts-indic fonts-ipafont-gothic fonts-kacst fonts-liberation fonts-noto-cjk fonts-noto-color-emoji fonts-roboto fonts-thai-tlwg fonts-wqy-zenhei gconf-service git libappindicator1 libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm-dev libgbm1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 locales lsb-release msttcorefonts pdftk unzip wget xdg-utils xvfb
$STD python3 -m pip install playwright
$STD git clone https://github.com/browserless/chrome /opt/browserless
npm install --prefix /opt/browserless
npm run build --prefix /opt/browserless
npm prune production --prefix /opt/browserless


msg_info "Creating Services"
cat <<EOF >/etc/systemd/system/changedetection.service
[Unit]
Description=Change Detection
After=network-online.target
After=network.target browserless.service
Wants=browserless.service
[Service]
Type=simple
WorkingDirectory=/opt/changedetection
Environment="WEBDRIVER_URL=http://127.0.0.1:4444/wd/hub"
Environment="PLAYWRIGHT_DRIVER_URL=ws://127.0.0.1:3000/?stealth=1&--disable-web-security=true"
ExecStart=changedetection.io -d /opt/changedetection -p 5000
[Install]
WantedBy=multi-user.target
EOF
$STD systemctl enable --now changedetection

cat <<EOF >/etc/systemd/system/browserless.service
[Unit]
Description=browserless service
After=network.target
[Service]
Environment=APP_DIR=/opt/browserless
Environment=PLAYWRIGHT_BROWSERS_PATH=/opt/browserless
Environment=CONNECTION_TIMEOUT=60000
Environment=HOST=127.0.0.1
Environment=LANG="C.UTF-8"
Environment=NODE_ENV=production
Environment=PORT=3000
Environment=WORKSPACE_DIR=/opt/browserless/workspace
WorkingDirectory=/opt/browserless
ExecStart=/opt/browserless/start.sh
SyslogIdentifier=browserless
[Install]
WantedBy=default.target
EOF
$STD systemctl enable --now browserless
msg_ok "Created Services"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
