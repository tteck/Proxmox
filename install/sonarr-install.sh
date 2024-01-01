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
$STD apt-get install -y gnupg 
$STD apt-get install -y ca-certificates
msg_ok "Installed Dependencies"

read -r -p "Would you like to install v4 (experimental)? <y/N> " prompt
msg_info "Installing Sonarr"
wget -qO /etc/apt/trusted.gpg.d/sonarr-repo.asc "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2009837cbffd68f45bc180471f4f90de2a9b4bf8"
echo "deb https://apt.sonarr.tv/debian testing-main main" >/etc/apt/sources.list.d/sonarr.list
$STD apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" install -qqy sonarr &>/dev/null
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
  systemctl stop sonarr.service
  wget -q -O SonarrV4.tar.gz 'https://services.sonarr.tv/v1/download/develop/latest?version=4&os=linux'
  tar -xzf SonarrV4.tar.gz
  cp -r Sonarr/* /usr/lib/sonarr/bin
  rm -rf Sonarr SonarrV4.tar.gz
  sed -i 's|ExecStart=/usr/bin/mono --debug /usr/lib/sonarr/bin/Sonarr.exe -nobrowser -data=/var/lib/sonarr|ExecStart=/usr/lib/sonarr/bin/Sonarr -nobrowser -data=/var/lib/sonarr|' /lib/systemd/system/sonarr.service
  sed -i 's/\(User=\|Group=\).*/\1root/' /lib/systemd/system/sonarr.service
  systemctl daemon-reload
  systemctl start sonarr.service
fi
msg_ok "Installed Sonarr"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
