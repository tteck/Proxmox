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

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y gcc
$STD apt-get install -y g++
$STD apt-get install -y git
$STD apt-get install -y gnupg
$STD apt-get install -y make
$STD apt-get install -y zip
$STD apt-get install -y unzip
$STD apt-get install -y exiftool
$STD apt-get install -y ffmpeg
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_18.x)
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get -y install nodejs
msg_ok "Installed Node.js"

msg_info "Installing Golang"
set +o pipefail
RELEASE=$(curl -s https://go.dev/dl/ | grep -o "go.*\linux-amd64.tar.gz" | head -n 1)
wget -q https://golang.org/dl/$RELEASE
$STD tar -xzf $RELEASE -C /usr/local
$STD ln -s /usr/local/go/bin/go /usr/local/bin/go
msg_ok "Installed Golang"

msg_info "Installing Go Dependencies"
$STD go install github.com/tianon/gosu@latest
$STD go install golang.org/x/tools/cmd/goimports@latest
$STD go install github.com/psampaz/go-mod-outdated@latest
$STD go install github.com/dsoprea/go-exif/v3/command/exif-read-tool@latest
$STD go install github.com/mikefarah/yq/v4@latest
$STD go install github.com/kyoh86/richgo@latest
cp /root/go/bin/* /usr/local/go/bin/
cp /usr/local/go/bin/richgo /usr/local/bin/richgo
cp /usr/local/go/bin/gosu /usr/local/sbin/gosu
chown root:root /usr/local/sbin/gosu
chmod 755 /usr/local/sbin/gosu
msg_ok "Installed Go Dependencies"

msg_info "Installing Tensorflow"
if grep -q avx2 /proc/cpuinfo; then
  suffix="avx2-"
elif grep -q avx /proc/cpuinfo; then
  suffix="avx-"
else
  suffix="1"
fi
version=$(curl -s https://dl.photoprism.org/tensorflow/amd64/ | grep -o "libtensorflow-amd64-$suffix.*\\.tar.gz" | head -n 1)
wget -q https://dl.photoprism.org/tensorflow/amd64/$version
tar -C /usr/local -xzf $version
ldconfig
set -o pipefail
msg_ok "Installed Tensorflow"

msg_info "Cloning PhotoPrism"
mkdir -p /opt/photoprism/bin
mkdir -p /var/lib/photoprism/storage
$STD git clone https://github.com/photoprism/photoprism.git
cd photoprism
$STD git checkout release
msg_ok "Cloned PhotoPrism"

msg_info "Building PhotoPrism (Patience)"
$STD make -B
$STD ./scripts/build.sh prod /opt/photoprism/bin/photoprism
$STD cp -r assets/ /opt/photoprism/
msg_ok "Built PhotoPrism"

env_path="/var/lib/photoprism/.env"
echo " 
PHOTOPRISM_AUTH_MODE='password'
PHOTOPRISM_ADMIN_PASSWORD='changeme'
PHOTOPRISM_HTTP_HOST='0.0.0.0'
PHOTOPRISM_HTTP_PORT='2342'
PHOTOPRISM_SITE_CAPTION='https://tteck.github.io/Proxmox/'
PHOTOPRISM_STORAGE_PATH='/var/lib/photoprism/storage'
PHOTOPRISM_ORIGINALS_PATH='/var/lib/photoprism/photos/Originals'
PHOTOPRISM_IMPORT_PATH='/var/lib/photoprism/photos/Import'
" >$env_path

msg_info "Creating Service"
service_path="/etc/systemd/system/photoprism.service"

echo "[Unit]
Description=PhotoPrism service
After=network.target

[Service]
Type=forking
User=root
WorkingDirectory=/opt/photoprism
EnvironmentFile=/var/lib/photoprism/.env
ExecStart=/opt/photoprism/bin/photoprism up -d
ExecStop=/opt/photoprism/bin/photoprism down

[Install]
WantedBy=multi-user.target" >$service_path
msg_ok "Created Service"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
rm -rf /var/{cache,log}/* \
  /photoprism \
  /$RELEASE \
  /$version
msg_ok "Cleaned"

msg_info "Starting PhotoPrism"
systemctl enable -q --now photoprism
msg_ok "Started PhotoPrism"
