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

msg_info "Installing runlike"
$STD apt-get install -y python3-pip
$STD pip3 install runlike
msg_ok "Installed runlike"

get_latest_release() {
  curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
}

DOCKER_LATEST_VERSION=$(get_latest_release "moby/moby")
CORE_LATEST_VERSION=$(get_latest_release "home-assistant/core")
PORTAINER_LATEST_VERSION=$(get_latest_release "portainer/portainer")

msg_info "Installing Docker $DOCKER_LATEST_VERSION"
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
$STD sh <(curl -sSL https://get.docker.com)
msg_ok "Installed Docker $DOCKER_LATEST_VERSION"

msg_info "Pulling Portainer $PORTAINER_LATEST_VERSION Image"
$STD docker pull portainer/portainer-ce:latest
msg_ok "Pulled Portainer $PORTAINER_LATEST_VERSION Image"

msg_info "Installing Portainer $PORTAINER_LATEST_VERSION"
$STD docker volume create portainer_data
$STD docker run -d \
  -p 8000:8000 \
  -p 9000:9000 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
msg_ok "Installed Portainer $PORTAINER_LATEST_VERSION"

msg_info "Pulling Home Assistant $CORE_LATEST_VERSION Image"
$STD docker pull homeassistant/home-assistant:stable
msg_ok "Pulled Home Assistant $CORE_LATEST_VERSION Image"

msg_info "Installing Home Assistant $CORE_LATEST_VERSION"
$STD docker volume create hass_config
$STD docker run -d \
  --name homeassistant \
  --privileged \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /dev:/dev \
  -v hass_config:/config \
  -v /etc/localtime:/etc/localtime:ro \
  --net=host \
  homeassistant/home-assistant:stable
  mkdir /root/hass_config
msg_ok "Installed Home Assistant $CORE_LATEST_VERSION"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
