#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
# License: MIT
# https://github.com/remz1337/Proxmox/raw/main/LICENSE

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
var_cpu="2"
var_ram="512"
var_os="debian"
var_version="11"
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
  if [[ ! -f /etc/systemd/system/scrutiny.service ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Stopping Scrutiny"
  systemctl stop scrutiny.service
  msg_ok "Stopped Scrutiny"

  msg_info "Updating Scrutiny"
  cd /opt/scrutiny/bin
  rm -rf scrutiny-web-linux-amd64
  wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-web-linux-amd64"
  chmod +x scrutiny-web-linux-amd64

  cd /opt/scrutiny/web
  rm -rf /opt/scrutiny/web/*
  wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-web-frontend.tar.gz"
  tar xvzf scrutiny-web-frontend.tar.gz --strip-components 1 -C .
  msg_ok "Updated Scrutiny"

  msg_info "Starting Scrutiny"
  systemctl start scrutiny.service
  msg_ok "Started Scrutiny"
}

install_collector() {
  #header_info
  if [[ ! -f /etc/systemd/system/scrutiny.service ]]; then
    #Not found, install
	msg_info "Installing Scrutiny Collector"
    apt-get install -y smartmontools &>/dev/null
    mkdir -p /opt/scrutiny/bin
    mkdir -p /opt/scrutiny/config
  
    cd /opt/scrutiny/config
    wget -O collector.yaml https://raw.githubusercontent.com/AnalogJ/scrutiny/master/example.collector.yaml &>/dev/null
    # #Enable API endpoint
    cat <<EOF >>/opt/scrutiny/config/collector.yaml
api:
  endpoint: 'http://${IP}:8080'
EOF

    cd /opt/scrutiny/bin
    wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-collector-metrics-linux-amd64" &>/dev/null
    chmod +x scrutiny-collector-metrics-linux-amd64

    cat <<EOF >/etc/systemd/system/scrutiny.service
[Unit]
Description="Scrutiny Collector service"
Requires=scrutiny.timer
After=syslog.target network.target

[Service]
Type=simple
WorkingDirectory=/opt/scrutiny
ExecStart=/opt/scrutiny/bin/scrutiny-collector-metrics-linux-amd64 run --config /opt/scrutiny/config/collector.yaml
EOF

    cat <<EOF >/etc/systemd/system/scrutiny.timer
[Unit]
Description="Timer for the scrutiny.service"

[Timer]
Unit=scrutiny.service
OnCalendar=*:0/15

[Install]
WantedBy=timers.target
EOF

    systemctl enable -q --now scrutiny.timer
	msg_ok "Installed Scrutiny Collector"
	msg_ok "Don't forget to update the the configuration in ${GN}/opt/scrutiny/config/collector.yaml${CL}"
  else
    #Already installed, update
	msg_ok "Scrutiny Collector already installed. It will be updated."
    msg_info "Stopping Scrutiny Collector"
    systemctl disable -q --now scrutiny.timer
    msg_ok "Stopped Scrutiny Collector"

    msg_info "Updating Scrutiny Collector"
    cd /opt/scrutiny/bin
    rm -rf scrutiny-collector-metrics-linux-amd64 &>/dev/null
    wget "https://github.com/AnalogJ/scrutiny/releases/latest/download/scrutiny-collector-metrics-linux-amd64" &>/dev/null
    chmod +x scrutiny-collector-metrics-linux-amd64
    msg_ok "Updated Scrutiny Collector"

    msg_info "Starting Scrutiny Collector"
    systemctl enable -q --now scrutiny.timer
    msg_ok "Started Scrutiny Collector"
  fi
}

start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -memory 256
pct set $CTID -cores 1
msg_ok "Set Container to Normal Resources"
msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8080${CL} \n"
		 
		 
#header_info
echo -e "\nDo you wish to install/update Scrutiny Collector?\n"
while true; do
  read -p "Start the Scrutiny Collector Install/Update Script (y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

install_collector