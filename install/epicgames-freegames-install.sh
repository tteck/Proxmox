#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster), remz1337
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

EMAIL=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "\nEnter your Epic Games account (email)" 9 58 --title "Account" 3>&1 1>&2 2>&3)
echo -e "${DGN}Using Epic Games Account: ${BGN}$EMAIL${CL}"

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y \
  curl \
  libnss3 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libcups2 \
  libxcomposite-dev \
  libxdamage1 \
  libxrandr2 \
  libgbm-dev \
  libxkbcommon-x11-0 \
  libpangocairo-1.0-0 \
  libasound2 \
  gpg  
msg_ok "Installed Dependencies"

msg_info "Installing Node.js"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
$STD apt-get update
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing Epicgames-freegames"
RELEASE=$(curl -s https://api.github.com/repos/claabs/epicgames-freegames-node/releases/latest | grep "tarball_url" | awk '{print substr($2, 2, length($2)-3)}')
mkdir -p /opt/epicgames-freegames
wget -qO epicgames-freegames.tar.gz "${RELEASE}"
tar -xzf epicgames-freegames.tar.gz -C /opt/epicgames-freegames --strip-components 1 --overwrite
rm -rf epicgames-freegames.tar.gz
npm install --prefix /opt/epicgames-freegames
mkdir -p /opt/epicgames-freegames/config

cat <<EOF >/opt/epicgames-freegames/config/config.json
{
  "runOnStartup": true,
  "cronSchedule": "0 0,6,12,18 * * *",
  "logLevel": "info",
  "webPortalConfig": {
    //localtunnel is used when there is no reverse proxy
	"localtunnel": true,
    //Once a reverse proxy has been set up, comment the localtunnel and uncomment the baseUrl (with the correct value)
	//"baseUrl": "https://epicgames-freegames.example.com",
  },
  "accounts": [
    {
	  //Enter your Epic Games account email here
      "email": "${EMAIL}",
    },
  ],
  //You can setup notifications. See docs at https://github.com/claabs/epicgames-freegames-node
}
EOF
msg_ok "Installed Epicgames-freegames"

msg_info "Creating Services"
cat <<EOF >/etc/systemd/system/epicgames-freegames.service 
[Unit]
Description="Epic Games free games"
Requires=epicgames-freegames.timer
[Service]
Type=simple
WorkingDirectory=/opt/epicgames-freegames
ExecStart=npm run start
EOF

cat <<EOF >/etc/systemd/system/epicgames-freegames.timer
[Unit]
Description="Timer for the epicgames-freegames.service"
[Timer]
Unit=epicgames-freegames.service
OnBootSec=1min
OnUnitActiveSec=6h
[Install]
WantedBy=timers.target
EOF

systemctl enable -q --now epicgames-freegames.timer
msg_ok "Created Services"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"