#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

APP=$1
installdir="/opt/$1"

branch="master"
dlbase="https://$APP.servarr.com/v1/update/$branch/updatefile?os=linux&runtime=netcore&arch=x64"

msg_info "Stopping $APP"
systemctl stop $APP
msg_ok "Stopped $APP"

msg_info "Updating Dependencies"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated Dependencies"

msg_info "Updating $APP"
wget -q --content-disposition "$dlbase"
rm -rf "$installdir"
tar -xzf ${APP^}.*.tar.gz -C "/opt"
msg_ok "Updated $app"
rm -rf "${APP^}.*.tar.gz"

systemctl start $APP
msg_ok "Started $APP"
