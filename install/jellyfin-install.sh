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
$STD apt-get install -y apt-transport-https
$STD apt-get install -y software-properties-common
msg_ok "Installed Dependencies"

if [[ -z "$(grep -w "100000" /proc/self/uid_map)" ]]; then
  msg_info "Setting Up Hardware Acceleration"
  $STD apt-get -y install \
    va-driver-all \
    ocl-icd-libopencl1
  if [[ ${PCT_OSVERSION} == "20.04" ]]; then 
  $STD apt-get install -y beignet-opencl-icd
  else
  $STD apt-get install -y intel-opencl-icd
  fi
  /bin/chgrp video /dev/dri
  /bin/chmod 755 /dev/dri
  /bin/chmod 660 /dev/dri/*
  msg_ok "Set Up Hardware Acceleration"
fi

msg_info "Setting Up Jellyfin Repository"
$STD add-apt-repository universe -y
$STD apt-key add <(curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key)
sh -c 'echo "deb [arch=$(dpkg --print-architecture)] https://repo.jellyfin.org/ubuntu $(lsb_release -c -s) main" > /etc/apt/sources.list.d/jellyfin.list'
msg_ok "Set Up Jellyfin Repository"

msg_info "Installing Jellyfin"
$STD apt-get update
$STD apt install jellyfin-server -y
$STD apt install jellyfin-ffmpeg5 -y
msg_ok "Installed Jellyfin"

msg_info "Creating Service"
cat <<'EOF' >/lib/systemd/system/jellyfin.service
[Unit]
Description = Jellyfin Media Server
After = network.target
[Service]
Type = simple
EnvironmentFile = /etc/default/jellyfin
User = root
ExecStart = /usr/bin/jellyfin
Restart = on-failure
TimeoutSec = 15
[Install]
WantedBy = multi-user.target
EOF
ln -s /usr/share/jellyfin/web/ /usr/lib/jellyfin/bin/jellyfin-web
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
