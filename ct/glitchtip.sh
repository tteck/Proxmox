#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)

function header_info {
    echo Status
    clear
}
header_info
echo -e "Loading..."
APP="GlitchTip"
APP_VERSION="4.0.9"
var_disk="4"
var_cpu="2"
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
    header_info
    if [[ ! -d /opt/glitchtip ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi
    msg_info "Updating ${APP} LXC"
    rm -rf /opt/glitchtip
    mkdir -p /opt/glitchtip
    wget -O backend.tar.gz https://gitlab.com/glitchtip/glitchtip-backend/-/archive/v${APP_VERSION}/glitchtip-backend-v${APP_VERSION}.tar.gz
    mkdir -p /opt/glitchtip
    tar zxvf backend.tar.gz --strip-components=1 -C /opt/glitchtip
    wget -O assets.zip https://gitlab.com/api/v4/projects/15449363/jobs/artifacts/v${APP_VERSION}/download?job=build-assets
    unzip assets.zip
    mv dist/glitchtip-frontend /opt/glitchtip/dist
    cd /opt/glitchtip
    poetry install --no-root
    source /etc/glitchtip.env
    poetry run ./manage.py migrate
    poetry run ./manage.py collectstatic
    msg_ok "Updated Successfully"
    exit
}

start
build_container
description

echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:8000${CL} \n"
