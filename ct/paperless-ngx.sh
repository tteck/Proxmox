#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    ____                        __                                     
   / __ \____ _____  ___  _____/ /__  __________    ____  ____ __  __
  / /_/ / __ `/ __ \/ _ \/ ___/ / _ \/ ___/ ___/___/ __ \/ __ `/ |/_/
 / ____/ /_/ / /_/ /  __/ /  / /  __(__  |__  )___/ / / / /_/ />  <  
/_/    \__,_/ .___/\___/_/  /_/\___/____/____/   /_/ /_/\__, /_/|_|  
           /_/                                         /____/        
 
EOF
}
header_info
echo -e "Loading..."
APP="Paperless-ngx"
var_disk="8"
var_cpu="2"
var_ram="2048"
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
  if [[ ! -d /opt/paperless ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/paperless-ngx/paperless-ngx/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  SER=/etc/systemd/system/paperless-task-queue.service

  UPD=$(whiptail --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 2 \
    "1" "Update Paperless-ngx to $RELEASE" ON \
    "2" "Paperless-ngx Credentials" OFF \
    3>&1 1>&2 2>&3)
  header_info
  if [ "$UPD" == "1" ]; then
    msg_info "Stopping Paperless-ngx"
    systemctl stop paperless-consumer paperless-webserver paperless-scheduler
    if [ -f "$SER" ]; then
      systemctl stop paperless-task-queue.service
    fi
    sleep 1
    msg_ok "Stopped Paperless-ngx"

    msg_info "Updating to ${RELEASE}"
    if [ "$(dpkg -l | awk '/libmariadb-dev-compat/ {print }' | wc -l)" != 1 ]; then apt-get install -y libmariadb-dev-compat; fi &>/dev/null
    wget https://github.com/paperless-ngx/paperless-ngx/releases/download/$RELEASE/paperless-ngx-$RELEASE.tar.xz &>/dev/null
    tar -xf paperless-ngx-$RELEASE.tar.xz &>/dev/null
    cp -r /opt/paperless/paperless.conf paperless-ngx/
    cp -r paperless-ngx/* /opt/paperless/
    cd /opt/paperless
    sed -i -e 's|-e git+https://github.com/paperless-ngx/django-q.git|git+https://github.com/paperless-ngx/django-q.git|' /opt/paperless/requirements.txt
    pip install -r requirements.txt &>/dev/null
    cd /opt/paperless/src
    /usr/bin/python3 manage.py migrate &>/dev/null
    if [ -f "$SER" ]; then
      msg_ok "paperless-task-queue.service Exists."
    else
      cat <<EOF >/etc/systemd/system/paperless-task-queue.service
[Unit]
Description=Paperless Celery Workers
Requires=redis.service
[Service]
WorkingDirectory=/opt/paperless/src
ExecStart=celery --app paperless worker --loglevel INFO
[Install]
WantedBy=multi-user.target
EOF
      systemctl enable paperless-task-queue &>/dev/null
      msg_ok "paperless-task-queue.service Created."
    fi
    cat <<EOF >/etc/systemd/system/paperless-scheduler.service
[Unit]
Description=Paperless Celery beat
Requires=redis.service
[Service]
WorkingDirectory=/opt/paperless/src
ExecStart=celery --app paperless beat --loglevel INFO
[Install]
WantedBy=multi-user.target
EOF
    msg_ok "Updated to ${RELEASE}"

    msg_info "Cleaning up"
    cd ~
    rm paperless-ngx-$RELEASE.tar.xz
    rm -rf paperless-ngx
    msg_ok "Cleaned"

    msg_info "Starting Paperless-ngx"
    systemctl daemon-reload
    systemctl start paperless-consumer paperless-webserver paperless-scheduler paperless-task-queue.service
    sleep 1
    msg_ok "Started Paperless-ngx"
    msg_ok "Updated Successfully!\n"
    exit
  fi
  if [ "$UPD" == "2" ]; then
    cat paperless.creds
    exit
  fi
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8000${CL} \n"
