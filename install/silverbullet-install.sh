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

SB_NOTES_DIR="/opt/silverbullet/notes"

# This looks wrong, but it will get then `bin` appended to it as per the [install script](https://deno.land/x/install@v0.1.9/install.sh?source=#L30).
export DENO_INSTALL="/usr"

msg_info "Installing Dependencies"
# Install deno-install deps
$STD apt-get install -y curl unzip

# Install deno
$STD bash <(curl -fsSL https://deno.land/install.sh)
msg_ok "Installed Dependencies"

msg_info "Installing Silverbullet"
# Install silverbullet (view script https://get.silverbullet.md)
$STD deno install -f --name silverbullet --unstable-kv --unstable-worker-options -A https://get.silverbullet.md
mv /root/.deno/bin/silverbullet /usr/bin/silverbullet
rm -rf /root/.deno

# Create folder to hold all the markdown notes
mkdir -p $SB_NOTES_DIR
msg_ok "Installed Silverbullet"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/silverbullet.service
[Unit]
Description=Silverbullet
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
