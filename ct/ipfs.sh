#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: ulmentflam
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ________  ___________
   /  _/ __ \/ ____/ ___/
   / // /_/ / /_   \__ \
 _/ // ____/ __/  ___/ /
/___/_/   /_/    /____/
EOF
}
header_info
echo -e "Loading..."
APP="IPFS"
var_disk="4"
var_cpu="2"
var_ram="6144"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -f /usr/local/kubo ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating $APP LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
wget -q "$(curl -s "https://api.github.com/repos/ipfs/kubo/releases/latest" | grep "linux-amd64.tar.gz" | grep "browser_download_url" | head -n 1 | cut -d\" -f4)"
tar -xzf kubo*linux-amd64.tar.gz -C /usr/local
$STD ln -s /usr/local/kubo/ipfs /usr/local/bin/ipfs
rm -rf kubo*linux-amd64.tar.gz
msg_ok "Updated $APP LXC"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:5001/webui ${CL} \n"
