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
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

msg_info "Installing OpenMediaVault (Patience)"
wget -qO- https://packages.openmediavault.org/public/archive.key | gpg --dearmor >"/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.gpg"

cat <<EOF >> /etc/apt/sources.list.d/openmediavault.list
deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] http://packages.openmediavault.org/public sandworm main
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] http://downloads.sourceforge.net/project/openmediavault/packages sandworm main
## Uncomment the following line to add software from the proposed repository.
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] http://packages.openmediavault.org/public sandworm-proposed main
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] http://downloads.sourceforge.net/project/openmediavault/packages sandworm-proposed main
## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] http://packages.openmediavault.org/public sandworm partner
# deb [signed-by=/usr/share/keyrings/openmediavault-archive-keyring.gpg] http://downloads.sourceforge.net/project/openmediavault/packages sandworm partner
EOF

export LANG=C.UTF-8
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
apt-get install --yes gnupg
wget --quiet --output-document=- https://packages.openmediavault.org/public/archive.key | gpg --dearmor --yes --output "/usr/share/keyrings/openmediavault-archive-keyring.gpg"
apt-get update
apt-get --yes --auto-remove --show-upgraded --allow-downgrades --allow-change-held-packages --no-install-recommends --option DPkg::Options::="--force-confdef" --option DPkg::Options::="--force-confold" install openmediavault-keyring openmediavault

# Populate the database.
omv-confdbadm populate

# Display the login information.
omv-salt deploy run hosts
cat /etc/issue


motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
