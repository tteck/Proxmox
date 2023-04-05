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
$STD apt-get install -y gnupg
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

msg_info "Installing Jellyfin"
VERSION="$( awk -F'=' '/^UBUNTU_CODENAME=/{ print $NF }' /etc/os-release )"
# If the keyring directory is absent, create it
if [[ ! -d /etc/apt/keyrings ]]; then
    mkdir -p /etc/apt/keyrings
fi
# Download the repository signing key and install it to the keyring directory
curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor --yes --output /etc/apt/keyrings/jellyfin.gpg
# Install the Deb822 format jellyfin.sources entry
cat <<EOF >/etc/apt/sources.list.d/jellyfin.sources
Types: deb
URIs: https://repo.jellyfin.org/${PCT_OSTYPE}
Suites: ${VERSION}
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/jellyfin.gpg
EOF
# Install Jellyfin using the metapackage (which will fetch jellyfin-server, jellyfin-web, and jellyfin-ffmpeg5)
$STD apt-get update
$STD apt-get install -y jellyfin
msg_ok "Installed Jellyfin"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
