#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
                                _           _     _              _       ___               
  /\  /\___  _ __ ___   ___    /_\  ___ ___(_)___| |_ __ _ _ __ | |_    / __\___  _ __ ___ 
 / /_/ / _ \| '_ ` _ \ / _ \  //_\\/ __/ __| / __| __/ _` | '_ \| __|  / /  / _ \| '__/ _ \
/ __  / (_) | | | | | |  __/ /  _  \__ \__ \ \__ \ || (_| | | | | |_  / /__| (_) | | |  __/
\/ /_/ \___/|_| |_| |_|\___| \_/ \_/___/___/_|___/\__\__,_|_| |_|\__| \____/\___/|_|  \___|
                                                                                           
EOF
}
header_info
echo -e "Loading..."
APP="Home Assistant-Core"
var_disk="8"
var_cpu="2"
var_ram="1024"
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
  NET=dhcp
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
  if [[ ! -d /srv/homeassistant ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  PY=$(ls /srv/homeassistant/lib/)
  IP=$(hostname -I | awk '{print $1}')
  UPD=$(whiptail --title "UPDATE" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 4 \
    "1" "Update Core" ON \
    "2" "Install HACS" OFF \
    "3" "Install FileBrowser" OFF \
    "4" "Install/Update AppDaemon" OFF \
    3>&1 1>&2 2>&3)
  header_info
  if [ "$UPD" == "1" ]; then
    if (whiptail --defaultno --title "SELECT BRANCH" --yesno "Use Beta Branch?" 10 58); then
      clear
      header_info
      echo -e "${GN}Updating to Beta Version${CL}"
      BR="--pre "
    else
      clear
      header_info
      echo -e "${GN}Updating to Stable Version${CL}"
      BR=""
    fi
    if [[ "$PY" == "python3.9" ]]; then echo -e "⚠️  Python 3.9 is deprecated and will be removed in Home Assistant 2023.2"; fi

    msg_info "Stopping Home Assistant"
    systemctl stop homeassistant
    msg_ok "Stopped Home Assistant"

    msg_info "Updating Home Assistant"
    source /srv/homeassistant/bin/activate
    pip install ${BR}--upgrade homeassistant &>/dev/null
    msg_ok "Updated Home Assistant"

    msg_info "Starting Home Assistant"
    systemctl start homeassistant
    sleep 2
    msg_ok "Started Home Assistant"
    msg_ok "Update Successful"
    echo -e "\n  Go to http://${IP}:8123 \n"
    exit
  fi
  if [ "$UPD" == "2" ]; then
    msg_info "Installing Home Assistant Comunity Store (HACS)"
    apt update &>/dev/null
    apt install unzip &>/dev/null
    cd .homeassistant
    bash <(curl -fsSL https://get.hacs.xyz) &>/dev/null
    msg_ok "Installed Home Assistant Comunity Store (HACS)"
    echo -e "\n Reboot Home Assistant and clear browser cache then Add HACS integration.\n"
    exit
  fi
  if [ "$UPD" == "3" ]; then
    msg_info "Installing FileBrowser"
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash &>/dev/null
    filebrowser config init -a '0.0.0.0' &>/dev/null
    filebrowser config set -a '0.0.0.0' &>/dev/null
    filebrowser users add admin changeme --perm.admin &>/dev/null
    msg_ok "Installed FileBrowser"

    msg_info "Creating Service"
    service_path="/etc/systemd/system/filebrowser.service"
    echo "[Unit]
Description=Filebrowser
After=network-online.target
[Service]
User=root
WorkingDirectory=/root/
ExecStart=/usr/local/bin/filebrowser -r /root/.homeassistant
[Install]
WantedBy=default.target" >$service_path

    systemctl enable --now -q filebrowser.service
    msg_ok "Created Service"

    msg_ok "Completed Successfully!\n"
    echo -e "FileBrowser should be reachable by going to the following URL.
         ${BL}http://$IP:8080${CL}   admin|changeme\n"
    exit
  fi
  if [ "$UPD" == "4" ]; then
    clear
    header_info
    if [[ ! -d /srv/appdaemon ]]; then
      msg_info "Installing AppDaemon"
      mkdir /srv/appdaemon
      cd /srv/appdaemon
      python3 -m venv .
      source bin/activate
      pip install appdaemon &>/dev/null
      mkdir -p /root/.homeassistant/appdaemon/apps
      cat >/root/.homeassistant/appdaemon/appdaemon.yaml <<EOF
# Sample appdaemon.yml file
# For configuration, please visit: https://appdaemon.readthedocs.io/en/latest/CONFIGURE.html
appdaemon:
  time_zone: CET
  latitude: 51.725
  longitude: 14.3434
  elevation: 0
  plugins:
    HASS:
      type: hass
      ha_url: <home_assistant_base_url>
      token: <some_long_lived_access_token>
http:
    url: http://127.0.0.1:5050
admin:
api:
EOF
      msg_ok "Installed AppDaemon"

      msg_info "Creating Service"
      cat >/etc/systemd/system/appdaemon.service <<EOF
[Unit]
Description=AppDaemon
After=homeassistant.service
Requires=homeassistant.service
[Service]
Type=simple
WorkingDirectory=/root/.homeassistant/appdaemon
ExecStart=/srv/appdaemon/bin/appdaemon -c "/root/.homeassistant/appdaemon"
RestartForceExitStatus=100
[Install]
WantedBy=multi-user.target
EOF
      systemctl enable --now appdaemon &>/dev/null
      msg_ok "Created Service"

      msg_ok "Completed Successfully!\n"
      echo -e "AppDaemon should be reachable by going to the following URL.
            ${BL}http://$IP:5050${CL}\n"
      exit
    else
      msg_info "Upgrading AppDaemon"
      msg_info "Stopping AppDaemon"
      systemctl stop appdaemon
      msg_ok "Stopped AppDaemon"

      msg_info "Updating AppDaemon"
      source /srv/appdaemon/bin/activate
      pip install --upgrade appdaemon &>/dev/null
      msg_ok "Updated AppDaemon"

      msg_info "Starting AppDaemon"
      systemctl start appdaemon
      sleep 2
      msg_ok "Started AppDaemon"
      msg_ok "Update Successful"
      echo -e "\n  Go to http://${IP}:5050 \n"
      exit
    fi
  fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8123${CL}"
