#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

if [[ "$1" == "" ]]; then
  msg_error "App name missing"
  exit 1
fi

color
catch_errors

APP=$1
installdir="/opt/$1"

#Radarr
#Lidarr
#Readarr
branch="master"

#Whisparr
if [[ "$APP" == "Whisparr" ]]; then
branch="nightly"
fi

#Prowlarr
if [[ "$APP" == "Prowlarr" ]]; then
branch="develop"
fi

dlbase="https://${APP,,}.servarr.com/v1/update/$branch/updatefile?os=linux&runtime=netcore&arch=x64"

#Sonarr
if [[ "$APP" == "Sonarr" ]]; then
dlbase="https://services.sonarr.tv/v1/download/main/latest?version=4&os=linux&arch=x64"
fi

msg_info "Stopping $APP"
systemctl stop ${APP,,}
msg_ok "Stopped $APP"

msg_info "Updating Dependencies"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated Dependencies"

msg_info "Updating $APP"
wget -q --content-disposition "$dlbase"
rm -rf "$installdir"
tar -xzf ${APP^}.*.tar.gz -C /opt
chmod 775 "/opt/$APP"
rm -rf ${APP^}.*.tar.gz
msg_ok "Updated $APP"


systemctl start ${APP,,}
msg_ok "Started $APP"
