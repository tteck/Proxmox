#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/ELKozel/Proxmox/main/misc/build.func)
# Copyright (c) 2024 ELKozel
# Author: T.H. (ELKozel)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
 _____ _           _   _                              _     
| ____| | __ _ ___| |_(_) ___ ___  ___  __ _ _ __ ___| |__  
|  _| | |/ _` / __| __| |/ __/ __|/ _ \/ _` | '__/ __| '_ \ 
| |___| | (_| \__ \ |_| | (__\__ \  __/ (_| | | | (__| | | |
|_____|_|\__,_|___/\__|_|\___|___/\___|\__,_|_|  \___|_| |_|

EOF
}
header_info
echo -e "Loading..."
APP="Elasticsearch"
var_disk="16"
var_cpu="4"
var_ram="4096"
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
  if [[ ! -f /etc/systemd/system/elasticsearch.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  if (( $(df /boot | awk 'NR==2{gsub("%","",$5); print $5}') > 80 )); then
    read -r -p "Warning: Storage is dangerously low, continue anyway? <y/N> " prompt
    [[ ${prompt,,} =~ ^(y|yes)$ ]] || exit
  fi

  msg_info "Stopping ${APP}"
  $STD /bin/systemctl stop elasticsearch.service
  msg_ok "Stopped ${APP}"

  msg_info "Updating ${APP}"
  $STD apt-get install elasticsearch &>/dev/null
  msg_ok "Updated ${APP}"

  msg_info "Starting ${APP}"
  $STD /bin/systemctl restart elasticsearch.service
  msg_ok "Started ${APP}"

  msg_ok "Updated Successfully"
  exit
}

function ask_extend_mmap() {
  echo "Elasticsearch recommends extending the vm.max_map_count on the host"
  read -r -p "Would you like to extend mmap count? <y/N>" prompt
  if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
    msg_info "Extending mmap count"
    sysctl -w vm.max_map_count=262144 >/dev/null
    # Check if the setting is persistent
    if ! grep -q "vm.max_map_count" /etc/sysctl.conf; then
      echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    fi
    msg_ok "Extended mmap count"
  fi
}

start
ask_extend_mmap
build_container
description

msg_info "Configuring User"
ELASTIC_USER=elastic
KIBANA_USER=kibana
ELASTIC_PASSWORD=$(lxc-attach -n "$CTID" -- bash -c "/usr/share/elasticsearch/bin/elasticsearch-reset-password -sbf -u $ELASTIC_USER" || exit)
KIBANA_TOKEN=$(lxc-attach -n "$CTID" -- bash -c "/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s $KIBANA_USER" || exit)
ENROLLMENT_TOKEN=$(lxc-attach -n "$CTID" -- bash -c "/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node" || exit)
msg_ok "Configured User"

msg_info "Checking Health"
ELASTIC_PORT=9200
curl -s -XGET --insecure --fail --user $ELASTIC_USER:$ELASTIC_PASSWORD https://${IP}:$ELASTIC_PORT/_cluster/health?pretty >/dev/null
msg_ok "Checked Health"

msg_ok "Completed Successfully!\n"
echo -e "${APP} is installed, you can check it's health by running:
${BL}curl -XGET --insecure --fail --user $ELASTIC_USER:$ELASTIC_PASSWORD https://${IP}:$ELASTIC_PORT/_cluster/health?pretty${CL}
Elasticsearch credentials are:
User: ${BL}${ELASTIC_USER}${CL}
Password: ${BL}${ELASTIC_PASSWORD}${CL}
Enrollment and Kibana tokens were also generated for you:
Kibana Token: ${BL}${KIBANA_TOKEN}${CL}
Enrollment Token: ${BL}${ENROLLMENT_TOKEN}${CL} \n"
