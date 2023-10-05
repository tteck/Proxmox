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
$STD apt update && apt upgrade -y
$STD apt-get install -y curl
$STD curl -sSL https://get.docker.com/ | sh
msg_ok "Installed Dependencies"

msg_info "Installing Minecraft Bedrock"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
if [ "$ST" == "yes" ]; then
VER=$(curl -s https://api.github.com/repos/containers/fuse-overlayfs/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
cd /usr/local/bin
curl -sSL -o fuse-overlayfs https://github.com/containers/fuse-overlayfs/releases/download/$VER/fuse-overlayfs-x86_64
chmod 755 /usr/local/bin/fuse-overlayfs
cd ~
echo -e '{\n  "storage-driver": "fuse-overlayfs",\n  "log-driver": "journald"\n}' > /etc/docker/daemon.json
else
echo -e '{\n  "log-driver": "journald"\n}' > /etc/docker/daemon.json
fi
$STD docker run -d -it -e EULA=TRUE -p 19132:19132/udp -v mc-bedrock-data:/data itzg/minecraft-bedrock-server
msg_ok "Installed Minecraft Bedrock"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
