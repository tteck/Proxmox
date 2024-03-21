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

# Update OS and install Smokeping and Apache without specific configuration
msg_info "Updating OS and installing Smokeping and Apache"
$STD apt-get update
$STD apt-get install -y smokeping apache2 --no-install-recommends
msg_ok "Smokeping and Apache installed"

# Enable CGI module in Apache
msg_info "Enabling CGI module in Apache"
a2enmod cgi
msg_ok "CGI module enabled"

# Create a symlink for Smokeping Apache configuration if it doesn't already exist
msg_info "Configuring Apache to serve Smokeping"
if [ ! -f /etc/apache2/conf-available/smokeping.conf ]; then
    ln -s /etc/smokeping/apache2.conf /etc/apache2/conf-available/smokeping.conf
    msg_ok "Symlink for Smokeping configuration created"
else
    msg_info "Symlink for Smokeping configuration already exists"
fi

# Ensure the smokeping configuration is enabled
a2enconf smokeping
msg_ok "Apache configured for Smokeping"

# Reload Apache to apply changes
msg_info "Reloading Apache to apply changes"
service apache2 restart
msg_ok "Apache reloaded"

# Basic setup steps to ensure Smokeping is operational
msg_info "Ensuring Smokeping service is enabled and started"
systemctl enable smokeping
systemctl start smokeping
msg_ok "Smokeping service operational"

motd_ssh
customize

# Cleanup
msg_info "Cleaning up"
$STD apt-get autoremove -y
$STD apt-get autoclean -y
msg_ok "Cleanup complete"
