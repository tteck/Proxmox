#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"

    _   __      _               ____                           __  ___                                 
   / | / /___ _(_)___  _  __   / __ \_________v5_  ____  __   /  |/  /___ _____  ____ _____ ____  _____
  /  |/ / __  / / __ \| |/_/  / /_/ / ___/ __ \| |/_/ / / /  / /|_/ / __  / __ \/ __  / __  / _ \/ ___/
 / /|  / /_/ / / / / />  <   / ____/ /  / /_/ />  </ /_/ /  / /  / / /_/ / / / / /_/ / /_/ /  __/ /    
/_/ |_/\__, /_/_/ /_/_/|_|  /_/   /_/   \____/_/|_|\__, /  /_/  /_/\__,_/_/ /_/\__,_/\__, /\___/_/     
      /____/                                      /____/                            /____/             
 
EOF
}
header_info
echo -e "Loading..."
APP="Nginx Proxy Manager"
var_disk="4"
var_cpu="1"
var_ram="1024"
var_os="debian"
var_version="11"
NSAPP=$(echo ${APP,,} | tr -d ' ')
var_install="${NSAPP}-v5-install"
timezone=$(cat /etc/timezone)
INTEGER='^[0-9]+([.][0-9]+)?$'
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
BGN=$(echo "\033[4;92m")
GN=$(echo "\033[1;92m")
DGN=$(echo "\033[32m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
set -Eeuo pipefail
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
function error_handler() {
  local exit_code="$?"
  local line_number="$1"
  local command="$2"
  local error_message="${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}: while executing command ${YW}$command${CL}"
  echo -e "\n$error_message\n"
}

function msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

function msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

function PVE_CHECK() {
if [ $(pveversion | grep -c "pve-manager/7\.[0-9]") -eq 0 ]; then
  echo -e "${CROSS} This version of Proxmox Virtual Environment is not supported"
  echo -e "Requires PVE Version 7.0 or higher"
  echo -e "Exiting..."
  sleep 2
exit
fi
}
function ARCH_CHECK() {
if [ "$(dpkg --print-architecture)" != "amd64" ]; then
  echo -e "\n ${CROSS} This script will not work with PiMox! \n"
  echo -e "Exiting..."
  sleep 2
exit
fi
}

function default_settings() {
  echo -e "${DGN}Using Container Type: ${BGN}Unprivileged${CL} ${RD}NO DEVICE PASSTHROUGH${CL}"
  CT_TYPE="1"
  echo -e "${DGN}Using Root Password: ${BGN}Automatic Login${CL}"
  PW=""
  echo -e "${DGN}Using Container ID: ${BGN}$NEXTID${CL}"
  CT_ID=$NEXTID
  echo -e "${DGN}Using Hostname: ${BGN}$NSAPP${CL}"
  HN=$NSAPP
  echo -e "${DGN}Using Disk Size: ${BGN}$var_disk${CL}${DGN}GB${CL}"
  DISK_SIZE="$var_disk"
  echo -e "${DGN}Allocated Cores ${BGN}$var_cpu${CL}"
  CORE_COUNT="$var_cpu"
  echo -e "${DGN}Allocated Ram ${BGN}$var_ram${CL}"
  RAM_SIZE="$var_ram"
  echo -e "${DGN}Using Bridge: ${BGN}vmbr0${CL}"
  BRG="vmbr0"
  echo -e "${DGN}Using Static IP Address: ${BGN}dhcp${CL}"
  NET=dhcp
  echo -e "${DGN}Using Gateway Address: ${BGN}Default${CL}"
  GATE=""
  echo -e "${DGN}Disable IPv6: ${BGN}No${CL}"
  DISABLEIP6="no"
  echo -e "${DGN}Using Interface MTU Size: ${BGN}Default${CL}"
  MTU=""
  echo -e "${DGN}Using DNS Search Domain: ${BGN}Host${CL}"
  SD=""
  echo -e "${DGN}Using DNS Server Address: ${BGN}Host${CL}"
  NS=""
  echo -e "${DGN}Using MAC Address: ${BGN}Default${CL}"
  MAC=""
  echo -e "${DGN}Using VLAN Tag: ${BGN}Default${CL}"
  VLAN=""
  echo -e "${DGN}Enable Root SSH Access: ${BGN}No${CL}"
  SSH="no"
  echo -e "${DGN}Enable Verbose Mode: ${BGN}No${CL}"
  VERB="no"
  echo -e "${BL}Creating a ${APP} LXC using the above default settings${CL}"
}

function exit-script() {
    clear
    echo -e "⚠  User exited script \n"
    exit
}

function advanced_settings() {
if CT_TYPE=$(whiptail --title "CONTAINER TYPE" --radiolist "Choose Type" 10 58 2 \
    "1" "Unprivileged" ON \
    "0" "Privileged" OFF \
    3>&1 1>&2 2>&3); then
    echo -e "${DGN}Using Container Type: ${BGN}$CT_TYPE${CL}"
else
    exit-script
fi

if PW1=$(whiptail --inputbox "\nSet Root Password (needed for root ssh access)" 9 58 --title "PASSWORD(leave blank for automatic login)" 3>&1 1>&2 2>&3); then
    if [ -z $PW1 ]; then
        PW1="Automatic Login"
        PW=" "
    else
        PW="-password $PW1"
    fi
    echo -e "${DGN}Using Root Password: ${BGN}$PW1${CL}"
else
    exit-script
fi

if CT_ID=$(whiptail --inputbox "Set Container ID" 8 58 $NEXTID --title "CONTAINER ID" 3>&1 1>&2 2>&3); then
    if [ -z "$CT_ID" ]; then
        CT_ID="$NEXTID"
        echo -e "${DGN}Using Container ID: ${BGN}$CT_ID${CL}"
    else
        echo -e "${DGN}Container ID: ${BGN}$CT_ID${CL}"
    fi
else
    exit
fi

if CT_NAME=$(whiptail --inputbox "Set Hostname" 8 58 $NSAPP --title "HOSTNAME" 3>&1 1>&2 2>&3); then
    if [ -z "$CT_NAME" ]; then
        HN="$NSAPP"
    else
        HN=$(echo ${CT_NAME,,} | tr -d ' ')
    fi
    echo -e "${DGN}Using Hostname: ${BGN}$HN${CL}"
else
    exit-script
fi

if DISK_SIZE=$(whiptail --inputbox "Set Disk Size in GB" 8 58 $var_disk --title "DISK SIZE" 3>&1 1>&2 2>&3); then
    if [ -z "$DISK_SIZE" ]; then
        DISK_SIZE="$var_disk"
        echo -e "${DGN}Using Disk Size: ${BGN}$DISK_SIZE${CL}"
        else
        if ! [[ $DISK_SIZE =~ $INTEGER ]]; then
          echo -e "${RD}⚠ DISK SIZE MUST BE AN INTEGER NUMBER!${CL}"
          advanced_settings
        fi
        echo -e "${DGN}Using Disk Size: ${BGN}$DISK_SIZE${CL}"
    fi
else
    exit-script
fi

if CORE_COUNT=$(whiptail --inputbox "Allocate CPU Cores" 8 58 $var_cpu --title "CORE COUNT" 3>&1 1>&2 2>&3); then
    if [ -z "$CORE_COUNT" ]; then
        CORE_COUNT="$var_cpu"
        echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}"
    else
        echo -e "${DGN}Allocated Cores: ${BGN}$CORE_COUNT${CL}"
    fi
else
    exit-script
fi

if RAM_SIZE=$(whiptail --inputbox "Allocate RAM in MiB" 8 58 $var_ram --title "RAM" 3>&1 1>&2 2>&3); then
    if [ -z "$RAM_SIZE" ]; then
        RAM_SIZE="$var_ram"
        echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}"
    else
        echo -e "${DGN}Allocated RAM: ${BGN}$RAM_SIZE${CL}"
    fi
else
    exit-script
fi

if BRG=$(whiptail --inputbox "Set a Bridge" 8 58 vmbr0 --title "BRIDGE" 3>&1 1>&2 2>&3); then
    if [ -z "$BRG" ]; then
        BRG="vmbr0"
        echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}"
    else
        echo -e "${DGN}Using Bridge: ${BGN}$BRG${CL}"
    fi
else
    exit-script
fi

if NET=$(whiptail --inputbox "Set a Static IPv4 CIDR Address(/24)" 8 58 dhcp --title "IP ADDRESS" 3>&1 1>&2 2>&3); then
    if [ -z $NET ]; then
        NET="dhcp"
        echo -e "${DGN}Using IP Address: ${BGN}$NET${CL}"
    else
        echo -e "${DGN}Using IP Address: ${BGN}$NET${CL}"
    fi
else
    exit-script
fi
if GATE1=$(whiptail --inputbox "Set a Gateway IP (mandatory if Static IP was used)" 8 58 --title "GATEWAY IP" 3>&1 1>&2 2>&3); then
    if [ -z $GATE1 ]; then
        GATE1="Default"
        GATE=""
    else
        GATE=",gw=$GATE1"
    fi
        echo -e "${DGN}Using Gateway IP Address: ${BGN}$GATE1${CL}"
else
    exit-script
fi

if (whiptail --defaultno --title "IPv6" --yesno "Disable IPv6?" 10 58); then
    DISABLEIP6="yes"
else
    DISABLEIP6="no"
fi
    echo -e "${DGN}Disable IPv6: ${BGN}$DISABLEIP6${CL}"

if MTU1=$(whiptail --inputbox "Set Interface MTU Size (leave blank for default)" 8 58 --title "MTU SIZE" 3>&1 1>&2 2>&3); then
    if [ -z $MTU1 ]; then
        MTU1="Default"
        MTU=""
    else
        MTU=",mtu=$MTU1"
    fi
        echo -e "${DGN}Using Interface MTU Size: ${BGN}$MTU1${CL}"
else
    exit-script
fi

if SD=$(whiptail --inputbox "Set a DNS Search Domain (leave blank for HOST)" 8 58 --title "DNS Search Domain" 3>&1 1>&2 2>&3); then
    if [ -z $SD ]; then
        SX=Host
        SD=""
    else
        SX=$SD
        SD="-searchdomain=$SD"
    fi
        echo -e "${DGN}Using DNS Search Domain: ${BGN}$SX${CL}"
else
    exit-script
fi

if NX=$(whiptail --inputbox "Set a DNS Server IP (leave blank for HOST)" 8 58 --title "DNS SERVER IP" 3>&1 1>&2 2>&3); then
    if [ -z $NX ]; then
        NX=Host    
        NS=""
    else
        NS="-nameserver=$NX"
    fi
        echo -e "${DGN}Using DNS Server IP Address: ${BGN}$NX${CL}"
else
    exit-script
fi

if MAC1=$(whiptail --inputbox "Set a MAC Address(leave blank for default)" 8 58 --title "MAC ADDRESS" 3>&1 1>&2 2>&3); then
    if [ -z $MAC1 ]; then
        MAC1="Default"
        MAC=""
    else
        MAC=",hwaddr=$MAC1"
        echo -e "${DGN}Using MAC Address: ${BGN}$MAC1${CL}"
    fi
else
    exit-script
fi

if VLAN1=$(whiptail --inputbox "Set a Vlan(leave blank for default)" 8 58 --title "VLAN" 3>&1 1>&2 2>&3); then
    if [ -z $VLAN1 ]; then
        VLAN1="Default"
        VLAN=""
    else
        VLAN=",tag=$VLAN1"
    fi
        echo -e "${DGN}Using Vlan: ${BGN}$VLAN1${CL}"
else
    exit-script
fi

if (whiptail --defaultno --title "SSH ACCESS" --yesno "Enable Root SSH Access?" 10 58); then
    SSH="yes"
else
    SSH="no"
fi
    echo -e "${DGN}Enable Root SSH Access: ${BGN}$SSH${CL}"

if (whiptail --defaultno --title "VERBOSE MODE" --yesno "Enable Verbose Mode?" 10 58); then
    VERB="yes"
else
    VERB="no"
fi
    echo -e "${DGN}Enable Verbose Mode: ${BGN}$VERB${CL}"

if (whiptail --title "ADVANCED SETTINGS COMPLETE" --yesno "Ready to create ${APP} LXC?" 10 58); then
    echo -e "${RD}Creating a ${APP} LXC using the above advanced settings${CL}"
else
    clear
    header_info
    echo -e "${RD}Using Advanced Settings${CL}"
    advanced_settings
fi
}

function install_script() {
ARCH_CHECK
PVE_CHECK
NEXTID=$(pvesh get /cluster/nextid)
header_info
  if (whiptail --title "SETTINGS" --yesno "Use Default Settings?" --no-button Advanced 10 58); then
    header_info
    echo -e "${BL}Using Default Settings${CL}"
    default_settings
  else
    header_info
    echo -e "${RD}Using Advanced Settings${CL}"
    advanced_settings
  fi
}

function update_script() {
header_info
RELEASE=$(curl -s https://api.github.com/repos/NginxProxyManager/nginx-proxy-manager/releases/latest |
  grep "tag_name" |
  awk '{print substr($2, 3, length($2)-4) }') 
msg_info "Stopping Services"
systemctl stop openresty
systemctl stop npm
msg_ok "Stopped Services"

msg_info "Cleaning Old Files"
  rm -rf /app \
    /var/www/html \
    /etc/nginx \
    /var/log/nginx \
    /var/lib/nginx \
    /var/cache/nginx &>/dev/null
msg_ok "Cleaned Old Files"

msg_info "Downloading NPM v${RELEASE}"
wget -q https://codeload.github.com/NginxProxyManager/nginx-proxy-manager/tar.gz/v${RELEASE} -O - | tar -xz &>/dev/null
cd nginx-proxy-manager-${RELEASE}
msg_ok "Downloaded NPM v${RELEASE}"

msg_info "Setting up Enviroment"
ln -sf /usr/bin/python3 /usr/bin/python
ln -sf /usr/bin/certbot /opt/certbot/bin/certbot
ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx
ln -sf /usr/local/openresty/nginx/ /etc/nginx
sed -i "s+0.0.0+${RELEASE}+g" backend/package.json
sed -i "s+0.0.0+${RELEASE}+g" frontend/package.json
sed -i 's+^daemon+#daemon+g' docker/rootfs/etc/nginx/nginx.conf
NGINX_CONFS=$(find "$(pwd)" -type f -name "*.conf")
for NGINX_CONF in $NGINX_CONFS; do
  sed -i 's+include conf.d+include /etc/nginx/conf.d+g' "$NGINX_CONF"
done
mkdir -p /var/www/html /etc/nginx/logs
cp -r docker/rootfs/var/www/html/* /var/www/html/
cp -r docker/rootfs/etc/nginx/* /etc/nginx/
cp docker/rootfs/etc/letsencrypt.ini /etc/letsencrypt.ini
cp docker/rootfs/etc/logrotate.d/nginx-proxy-manager /etc/logrotate.d/nginx-proxy-manager
ln -sf /etc/nginx/nginx.conf /etc/nginx/conf/nginx.conf
rm -f /etc/nginx/conf.d/dev.conf
mkdir -p /tmp/nginx/body \
  /run/nginx \
  /data/nginx \
  /data/custom_ssl \
  /data/logs \
  /data/access \
  /data/nginx/default_host \
  /data/nginx/default_www \
  /data/nginx/proxy_host \
  /data/nginx/redirection_host \
  /data/nginx/stream \
  /data/nginx/dead_host \
  /data/nginx/temp \
  /var/lib/nginx/cache/public \
  /var/lib/nginx/cache/private \
  /var/cache/nginx/proxy_temp
chmod -R 777 /var/cache/nginx
chown root /tmp/nginx
echo resolver "$(awk 'BEGIN{ORS=" "} $1=="nameserver" {print ($2 ~ ":")? "["$2"]": $2}' /etc/resolv.conf);" >/etc/nginx/conf.d/include/resolvers.conf
if [ ! -f /data/nginx/dummycert.pem ] || [ ! -f /data/nginx/dummykey.pem ]; then
  echo -e "${CHECKMARK} \e[1;92m Generating dummy SSL Certificate... \e[0m"
  openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/O=Nginx Proxy Manager/OU=Dummy Certificate/CN=localhost" -keyout /data/nginx/dummykey.pem -out /data/nginx/dummycert.pem &>/dev/null
fi
mkdir -p /app/global /app/frontend/images
cp -r backend/* /app
cp -r global/* /app/global
msg_ok "Setup Enviroment"

msg_info "Building Frontend"
cd ./frontend
export NODE_ENV=development
yarn install --network-timeout=30000 &>/dev/null
yarn build &>/dev/null
cp -r dist/* /app/frontend
cp -r app-images/* /app/frontend/images
msg_ok "Built Frontend"


msg_info "Initializing Backend"
rm -rf /app/config/default.json &>/dev/null
if [ ! -f /app/config/production.json ]; then
  cat <<'EOF' >/app/config/production.json
{
  "database": {
    "engine": "knex-native",
    "knex": {
      "client": "sqlite3",
      "connection": {
        "filename": "/data/database.sqlite"
      }
    }
  }
}
EOF
fi
cd /app
export NODE_ENV=development
sed -i 's/"liquidjs": "\^12\.9\.20",/"liquidjs": "\^10.6.1",/g' package.json
yarn install --network-timeout=30000 &>/dev/null
msg_ok "Initialized Backend"

msg_info "Starting Services"
systemctl enable npm &>/dev/null
systemctl start openresty
systemctl start npm
msg_ok "Started Services"

msg_info "Cleaning up"
rm -rf ~/nginx-proxy-manager-*
msg_ok "Cleaned"

msg_ok "Update Successfull"
exit
}

if command -v pveversion >/dev/null 2>&1; then
  if ! (whiptail --title "${APP} LXC" --yesno "This will create a New ${APP} LXC. Proceed?" 10 58); then
    clear
    echo -e "⚠  User exited script \n"
    exit
  fi
  install_script
fi

if ! command -v pveversion >/dev/null 2>&1 && [[ ! -f /lib/systemd/system/npm.service ]]; then
  msg_error "No ${APP} Installation Found!"
  exit 
fi

if ! command -v pveversion >/dev/null 2>&1; then
  if ! (whiptail --title "${APP} LXC UPDATE" --yesno "This will update ${APP} LXC.  Proceed?" 10 58); then
    clear
    echo -e "⚠  User exited script \n"
    exit
  fi
  update_script
fi

if [ "$VERB" == "yes" ]; then set -x; fi
if [ "$CT_TYPE" == "1" ]; then
  FEATURES="nesting=1,keyctl=1"
else
  FEATURES="nesting=1"
fi
TEMP_DIR=$(mktemp -d)
pushd $TEMP_DIR >/dev/null 
export tz=$timezone
export DISABLEIPV6=$DISABLEIP6
export APPLICATION=$APP
export VERBOSE=$VERB
export SSH_ROOT=${SSH}
export CTID=$CT_ID
export PCT_OSTYPE=$var_os
export PCT_OSVERSION=$var_version
export PCT_DISK_SIZE=$DISK_SIZE
export PCT_OPTIONS="
  -features $FEATURES
  -hostname $HN
  $SD
  $NS
  -net0 name=eth0,bridge=$BRG$MAC,ip=$NET$GATE$VLAN$MTU
  -onboot 1
  -cores $CORE_COUNT
  -memory $RAM_SIZE
  -unprivileged $CT_TYPE
  $PW
"
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/create_lxc.sh)" || exit
msg_info "Starting LXC Container"
pct start $CTID
msg_ok "Started LXC Container"
lxc-attach -n $CTID -- bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/install/$var_install.sh)" || exit
IP=$(pct exec $CTID ip a s dev eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
pct set $CTID -description "# ${APP} LXC
### https://tteck.github.io/Proxmox/
<a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/☕-Buy me a coffee-red' /></a>"
msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:81${CL} \n"
