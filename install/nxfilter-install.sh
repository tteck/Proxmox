#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Author: DeepWoods
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
$STD apt-get install -y --no-install-recommends dnsutils iputils-ping curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y apt-transport-https
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

msg_info "Installing OpenJDK"
wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor >/etc/apt/trusted.gpg.d/adoptium.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main' >/etc/apt/sources.list.d/adoptium.list
$STD apt-get update
$STD apt-get install -y temurin-17-jre
msg_ok "Installed OpenJDK"

LATEST=$(curl -fsSL https://nxfilter.org/curver.php)
msg_info "Installing NxFilter v${LATEST} DNS Filtering Application"
curl -fsSL $(printf ' -O http://pub.nxfilter.org/nxfilter-%s.deb' ${LATEST})
$STD apt-get install -y --no-install-recommends ./$(printf 'nxfilter-%s.deb' ${LATEST})
echo "${LATEST}" > /nxfilter/version.txt
systemctl start nxfilter
msg_ok "Installed NxFilter v${LATEST} DNS Filtering Application"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf ./$(printf 'nxfilter-%s.deb' ${LATEST})
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
