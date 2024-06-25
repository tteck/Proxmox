#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   _____                 __  _            
  / ___/____________  __/ /_(_)___  __  __
  \__ \/ ___/ ___/ / / / __/ / __ \/ / / /
 ___/ / /__/ /  / /_/ / /_/ / / / / /_/ / 
/____/\___/_/   \__,_/\__/_/_/ /_/\__, /  
                                 /____/   
EOF
}
header_info
echo -e "Loading..."
APP="Scrutiny"
var_disk="4"
var_cpu="1"
var_ram="1024"
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
  if [[ ! -d /opt/scrutiny ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  RELEASE=$(curl -s https://api.github.com/repos/AnalogJ/scrutiny/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')

  UPD=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Scrutiny Management" --radiolist --cancel-button Exit-Script "Spacebar = Select" 15 70 4 \
    "1" "Update Scrutiny to $RELEASE" ON \
    "2" "Start Scrutiny Webapp" OFF \
    "3" "Create/Start Scrutiny Collector" OFF \
	"4" "Change Scrutiny Settings"  OFF \
    3>&1 1>&2 2>&3)
  header_info

  if [ "$UPD" == "1" ]; then
    if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then

      msg_info "Stopping all Scrutiny Services"
	  WEBAPP_ACTIVE=$(systemctl is-active scrutiny.service)
      COLLECTOR_ACTIVE=$(systemctl is-active scrutiny_collector.service)
      systemctl stop scrutiny.service scrutiny_collector.service
      msg_ok "Stopped all Scrutiny Services"

      msg_info "Updating to ${RELEASE}"
      cd /opt
      rm -rf scrutiny_bak
      mv scrutiny scrutiny_bak
      mkdir -p /opt/scrutiny/web /opt/scrutiny/bin
      wget -q -O /opt/scrutiny/bin/scrutiny-web-linux-amd64 "https://github.com/AnalogJ/scrutiny/releases/download/${RELEASE}/scrutiny-web-linux-amd64"
      wget -q -O /opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 "https://github.com/AnalogJ/scrutiny/releases/download/${RELEASE}/scrutiny-collector-metrics-linux-amd64"
      wget -q -O /opt/scrutiny/web/scrutiny-web-frontend.tar.gz "https://github.com/AnalogJ/scrutiny/releases/download/${RELEASE}/scrutiny-web-frontend.tar.gz"
      cd /opt/scrutiny/web && tar xvzf scrutiny-web-frontend.tar.gz --strip-components 1 -C .
      chmod +x /opt/scrutiny/bin/scrutiny-web-linux-amd64
      chmod +x /opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64
      echo "${RELEASE}" > /opt/scrutiny_version.txt
      msg_ok "Updated Scrutiny to $RELEASE"

      msg_info "Cleaning up"
      rm -f /opt/scrutiny/web/scrutiny-web-frontend.tar.gz
      msg_ok "Cleaned"

      if [ "$WEBAPP_ACTIVE" == "active" ]; then
        msg_info "Starting Scrutiny Webapp Service"
        systemctl start scrutiny.service
        msg_ok "Started Scrutiny Webapp Service"
      fi

      if [ "$COLLECTOR_ACTIVE" == "active" ]; then
        msg_info "Starting Scrutiny Collector Service"
        systemctl start scrutiny_collector.service
        msg_ok "Started Scrutiny Collector Service"
      fi

      msg_ok "Updated Successfully!\n"
    else
      msg_ok "No update required. ${APP} is already at ${RELEASE}"
    fi
    exit
  fi
if [ "$UPD" == "2" ]; then
    msg_info "Checking for Scrutiny Webapp Service"
    if systemctl list-units --full -all | grep -Fq 'scrutiny.service'; then
        msg_info "Stopping Scrutiny Webapp Service"
        systemctl stop scrutiny.service
        msg_ok "Stopped Scrutiny Webapp Service"
    else
        msg_info "Scrutiny Webapp Service not found, creating..."
        cat <<EOF >/etc/systemd/system/scrutiny.service
[Unit]
Description=Scrutiny - Hard Drive Monitoring and Webapp
After=network.target

[Service]
Type=simple
ExecStart=/opt/scrutiny/bin/scrutiny-web-linux-amd64 start --config /opt/scrutiny/config/scrutiny.yaml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
        systemctl enable -q scrutiny.service
        msg_ok "Created Scrutiny Webapp Service"
    fi

    msg_info "Starting Scrutiny Webapp Service"
    systemctl start scrutiny.service
    msg_ok "Started Scrutiny Webapp Service"
    exit
fi

if [ "$UPD" == "3" ]; then
    msg_info "Checking for Scrutiny Collector Service"
    if systemctl list-units --full -all | grep -Fq 'scrutiny_collector.service'; then
        msg_info "Stopping Scrutiny Collector Service"
        systemctl stop scrutiny_collector.service
        msg_ok "Stopped Scrutiny Collector Service"
    else
        msg_info "Scrutiny Collector Service not found, creating..."
		wget -q -O /opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 "https://github.com/AnalogJ/scrutiny/releases/download/${RELEASE}/scrutiny-collector-metrics-linux-amd64"
		chmod +x /opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64
        cat <<EOF >/etc/systemd/system/scrutiny_collector.service
[Unit]
Description=Scrutiny Collector
After=network.target

[Service]
Type=simple
ExecStart=/opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 run --api-endpoint "http://localhost:8080"
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
        systemctl enable -q scrutiny_collector.service
        msg_ok "Created Scrutiny Collector Service"
    fi

    msg_info "Starting Scrutiny Collector Service"
    systemctl start scrutiny_collector.service
    msg_ok "Started Scrutiny Collector Service"
    exit
fi
if [ "$UPD" == "4" ]; then
	nano /opt/scrutiny/config/scrutiny.yaml
	exit
fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} Setup should be reachable by going to the following URL.
         ${BL}http://${IP}:8080${CL} \n"
