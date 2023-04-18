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

msg_info "Installing NextCloudPi (Patience)"
$STD bash <(curl -fsSL https://raw.githubusercontent.com/nextcloud/nextcloudpi/master/install.sh)
sed -i "s/3 => 'nextcloudpi.lan',/3 => '0.0.0.0',/g" /var/www/nextcloud/config/config.php
sed -i '{s|root:/usr/sbin/nologin|root:/bin/bash|g}' /etc/passwd
sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.1/fpm/php.ini /etc/php/8.1/cli/php.ini
service apache2 restart
msg_ok "Installed NextCloudPi"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
