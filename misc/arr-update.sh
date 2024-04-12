#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

app=$1   
installdir="/opt/$1"

branch="master"
dlbase="https://$app.servarr.com/v1/update/$branch/updatefile?os=linux&runtime=netcore&arch=x64"

msg_info "Stopping $app"
systemctl stop $app

msg_info "Updating Dependencies"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated Dependencies"

msg_info "Updating $app"
wget -q --content-disposition "$dlbase"
rm -rf "$installdir"
tar -xzf ${app^}.*.tar.gz -C "/opt"
msg_ok "Updated $app"
rm -rf "${app^}.*.tar.gz"

systemctl start $app
msg_ok "Started $app"
