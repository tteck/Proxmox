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
$STD apt-get install -y mc
$STD apt-get install -y git
$STD apt-get install -y ca-certificates
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Updating Python3"
$STD apt-get install -y \
  python3 \
  python3-dev \
  python3-pip
rm -rf /usr/lib/python3.*/EXTERNALLY-MANAGED
msg_ok "Updated Python3"

msg_info "Installing Free Games Claimer"
git clone -q https://github.com/vogler/free-games-claimer.git /opt/freegamesclaimer
cd /opt/freegamesclaimer
$STD npm install
$STD npx playwright install firefox --with-deps
msg_ok "Installed Free Games Claimer"

msg_info "Installing apprise"
$STD pip install apprise
msg_ok "Installed apprise"

msg_info "Creating dummy config file"
cat <<EOF >/opt/freegamesclaimer/data/config.env
  NOTIFY=  # apprise notification services
  NOTIFY_TITLE=  # apprise notification title

  # auth epic-games
  EG_EMAIL=
  EG_PASSWORD=

  # auth prime-gaming
  PG_EMAIL=
  PG_PASSWORD=

  # auth gog
  GOG_EMAIL=
  GOG_PASSWORD=

  # auth AliExpress
  AER_EMAIL=
  AE_PASSWORD=
EOF
msg_ok "Created dummy config file"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
