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

msg_info "Installing MariaDB"
$STD bash <(curl -fsSL https://r.mariadb.com/downloads/mariadb_repo_setup)
$STD apt-get update
$STD apt-get install -y mariadb-server
sed -i 's/^# *\(port *=.*\)/\1/' /etc/mysql/my.cnf
sed -i 's/^bind-address/#bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf
msg_ok "Installed MariaDB"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
