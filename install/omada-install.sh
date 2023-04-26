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
$STD apt-get install -y gnupg
$STD apt-get install -y openjdk-8-jre-headless
$STD apt-get install -y jsvc
wget -qL https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/3.6/multiverse/binary-amd64/mongodb-org-server_3.6.23_amd64.deb
$STD dpkg -i mongodb-org-server_3.6.23_amd64.deb
msg_ok "Installed Dependencies"

msg_info "Installing Omada Controller v5.9.31"
wget -qL https://static.tp-link.com/upload/software/2023/202303/20230321/Omada_SDN_Controller_v5.9.31_Linux_x64.deb
$STD dpkg -i Omada_SDN_Controller_v5.9.31_Linux_x64.deb 
msg_ok "Installed Omada Controller"

motd_ssh
root

msg_info "Cleaning up"
rm -f Omada_SDN_Controller_v5.9.31_Linux_x64.deb mongodb-org-server_3.6.23_amd64.deb
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
