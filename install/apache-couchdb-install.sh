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
$STD apt-get install -y apt-transport-https
$STD apt-get install -y gpg
msg_ok "Installed Dependencies"

msg_info "Installing Apache CouchDB"
wget -qO- https://downloads.apache.org/couchdb/KEYS | gpg --dearmor >/etc/apt/trusted.gpg.d/couchdb.gpg
source /etc/os-release
echo "deb https://apache.jfrog.io/artifactory/couchdb-deb/ ${VERSION_CODENAME} main" >/etc/apt/sources.list.d/couchdb.sources.list
$STD apt-get update
$STD apt-get install -y couchdb
# Change the bind address to make CouchDB accessible from other machines
sed -i 's/;bind_address = 127.0.0.1/bind_address = 0.0.0.0/g' /opt/couchdb/etc/local.ini
# Add an admin user (replace 'myadmin' and 'mypassword' with your desired admin username and password)
echo "[admins]" >> /opt/couchdb/etc/local.ini
echo "myadmin = mypassword" >> /opt/couchdb/etc/local.ini
msg_ok "Installed Apache CouchDB"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
