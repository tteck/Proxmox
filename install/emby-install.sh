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
msg_ok "Installed Dependencies"

if [[ "$CTTYPE" == "0" ]]; then
  msg_info "Setting Up Hardware Acceleration"
  $STD apt-get -y install \
    va-driver-all \
    ocl-icd-libopencl1
  if [[ ${PCT_OSVERSION} == "20.04" ]]; then 
  $STD apt-get install -y beignet-opencl-icd
  else
  $STD apt-get install -y intel-opencl-icd
  fi
  chgrp video /dev/dri
  chmod 755 /dev/dri
  chmod 660 /dev/dri/*
  $STD adduser $(id -u -n) video
  $STD adduser $(id -u -n) render
  msg_ok "Set Up Hardware Acceleration"
fi

LATEST=$(curl -sL https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest | grep '"tag_name":' | cut -d'"' -f4)

msg_info "Installing Emby"
wget -q https://github.com/MediaBrowser/Emby.Releases/releases/download/${LATEST}/emby-server-deb_${LATEST}_amd64.deb
$STD dpkg -i emby-server-deb_${LATEST}_amd64.deb
sed -i -e 's/^ssl-cert:x:104:$/render:x:104:root,emby/' -e 's/^render:x:108:root,emby$/ssl-cert:x:108:/' /etc/group
msg_ok "Installed Emby"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
rm emby-server-deb_${LATEST}_amd64.deb
msg_ok "Cleaned"
