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

LATEST=$(curl -sL https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest | grep '"tag_name":' | cut -d'"' -f4)

msg_info "Installing Emby"
wget -q https://github.com/MediaBrowser/Emby.Releases/releases/download/${LATEST}/emby-server-deb_${LATEST}_amd64.deb
$STD dpkg -i emby-server-deb_${LATEST}_amd64.deb
msg_ok "Installed Emby"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
rm emby-server-deb_${LATEST}_amd64.deb
msg_ok "Cleaned"
