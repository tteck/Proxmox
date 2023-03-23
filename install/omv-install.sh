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
msg_ok "Installed Dependencies"

msg_info "Installing OpenMediaVault (Patience)"
wget -q -O "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.asc" https://packages.openmediavault.org/public/archive.key
$STD apt-key add "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.asc" &>/dev/null

cat <<EOF >>/etc/apt/sources.list.d/openmediavault.list
deb https://packages.openmediavault.org/public shaitan main
# deb https://downloads.sourceforge.net/project/openmediavault/packages shaitan main
## Uncomment the following line to add software from the proposed repository.
# deb https://packages.openmediavault.org/public shaitan-proposed main
# deb https://downloads.sourceforge.net/project/openmediavault/packages shaitan-proposed main
## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb https://packages.openmediavault.org/public shaitan partner
# deb https://downloads.sourceforge.net/project/openmediavault/packages shaitan partner
EOF
$STD apt-get update
apt-get -y install openmediavault-keyring &>/dev/null
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" install -qqy openmediavault &>/dev/null
omv-confdbadm populate
msg_ok "Installed OpenMediaVault"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
