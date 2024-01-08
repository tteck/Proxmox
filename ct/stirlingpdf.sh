#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   _____ __  _      ___                 ____  ____  ______
  / ___// /_(_)____/ (_)___  ____ _    / __ \/ __ \/ ____/
  \__ \/ __/ / ___/ / / __ \/ __ `/___/ /_/ / / / / /_
 ___/ / /_/ / /  / / / / / / /_/ /___/ ____/ /_/ / __/
/____/\__/_/_/  /_/_/_/ /_/\__, /   /_/   /_____/_/
                          /____/
EOF
}
header_info
echo -e "Loading..."
APP="StirlingPDF"
var_disk="8"
var_cpu="2"
var_ram="2048"
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
if [[ ! -d /opt/Stirling-PDF ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP}"
systemctl stop stirlingpdf
git clone https://github.com/Stirling-Tools/Stirling-PDF.git
cd Stirling-PDF
chmod +x ./gradlew
./gradlew build
cp -r ./build/libs/Stirling-PDF-*.jar /opt/Stirling-PDF/
cp -r scripts /opt/Stirling-PDF/
cd ~
rm -rf Stirling-PDF
latest_version=$(ls -1 /opt/Stirling-PDF/Stirling-PDF-*.jar | sort -V | tail -n 1)
ln -sf "$latest_version" /opt/Stirling-PDF/Stirling-PDF.jar
new_version=$(echo "$latest_version" | grep -oP '(?<=Stirling-PDF-)\d+(\.\d+)+(?=\.jar)')
systemctl start stirlingpdf
msg_ok "Updated ${APP} to v$new_version"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8080 ${CL} \n"
