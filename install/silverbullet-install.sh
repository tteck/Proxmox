#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: ewilazarus (Gabriel Lima)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# This is the path of the directory where all the markdown notes will be stored.
SB_NOTES_DIR="/opt/silverbullet/notes"

# This is a helper function that will move binaries in the deno bin folder to /usr/bin.
# It will also remove the `.deno` folder in the root directory to prevent cluttering.
replace_deno_bin() {
  mv /root/.deno/bin/$1 /usr/bin/$1
  rm -rf /root/.deno
}

msg_info "Installing Dependencies"
$STD apt-get install -y curl unzip
msg_ok "Installed Dependencies"

msg_info "Installing Deno"
$STD bash <(curl -fsSL https://deno.land/install.sh)
replace_deno_bin "deno"
msg_ok "Installed Deno"

msg_info "Installing SilverBullet"
$STD deno install -f --name silverbullet --unstable-kv --unstable-worker-options -A https://get.silverbullet.md
replace_deno_bin "silverbullet"
mkdir -p $SB_NOTES_DIR
msg_ok "Installed SilverBullet"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/silverbullet.service
[Unit]
Description=SilverBullet
After=network.target

[Service]
User=root
WorkingDirectory=$SB_NOTES_DIR
SyslogIdentifier=silverbullet
Restart=on-failure
ExecStart=silverbullet -L 0.0.0.0 .

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now silverbullet
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
