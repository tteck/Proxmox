#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Authors: tteck (tteckster), remz1337
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    __________  _____________  ____________
   / ____/ __ \/  _/ ____/   |/_  __/ ____/
  / /_  / /_/ // // / __/ /| | / / / __/   
 / __/ / _, _// // /_/ / ___ |/ / / /___   
/_/   /_/ |_/___/\____/_/  |_/_/ /_____/   
                                           
EOF
}
header_info
echo -e "Loading..."
APP="Frigate"
var_disk="40"
var_cpu="4"
var_ram="4096"
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
  if [[ ! -f /etc/systemd/system/frigate.service ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  
  FRIGATE=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/blakeblackshear/frigate/releases/latest)
  FRIGATE=${FRIGATE##*/}
  
  GO2RTC=$(curl -s https://api.github.com/repos/AlexxIT/go2rtc/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  
  FFMPEG="n6.1-latest"
  
  #Once nodejs is installed, can be updated via apt.
  #NODE=$(curl -s https://api.github.com/repos/nodejs/node/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')

  UPD=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 3 \
    "1" "Frigate $FRIGATE" ON \
    "2" "go2rtc $GO2RTC" OFF \
	"3" "ffmpeg $FFMPEG" OFF \
    3>&1 1>&2 2>&3)

  header_info
  #Update Frigate
  if [ "$UPD" == "1" ]; then

	#Ensure enough resources
	if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "Update Frigate" --yesno "Does the LXC have at least 4vCPU  and 4096MiB RAM?" 10 58); then
	  CONTINUE=1
	else
	  CONTINUE=0
	  exit-script
	fi

    echo -e "\n ⚠️  Ensure you set 4vCPU & 4096MiB RAM minimum!!! \n"
    msg_info "Stopping Frigate"
    systemctl stop frigate.service
    msg_ok "Stopped Frigate"

    msg_info "Updating Frigate to $FRIGATE (Patience)"
	python3 -m pip install --upgrade pip

	cd /opt
	wget https://github.com/blakeblackshear/frigate/archive/refs/tags/${FRIGATE}.tar.gz -O frigate.tar.gz
	tar -xzf frigate.tar.gz -C frigate --strip-components 1 --overwrite

	#Cleanup
	rm frigate.tar.gz

	cd /opt/frigate
	bash docker/main/build_nginx.sh

	#Cleanup previous wheels
	rm -rf /wheels

	pip3 install -r docker/main/requirements.txt
	pip3 wheel --wheel-dir=/wheels -r /opt/frigate/docker/main/requirements-wheels.txt

	pip3 install -U /wheels/*.whl
	ldconfig
	pip3 install -U /wheels/*.whl

	pip3 install -r /opt/frigate/docker/main/requirements-dev.txt

	#First, comment the call to S6 in the run script
	sed -i '/^s6-svc -O \.$/s/^/#/' /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/frigate/run

	#Call nginx from absolute path
	#nginx --> /usr/local/nginx/sbin/nginx
	sed -i 's/exec nginx/exec \/usr\/local\/nginx\/sbin\/nginx/g' /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/nginx/run

	#Copy preconfigured files
	cp -a /opt/frigate/docker/main/rootfs/. /

	#Can't log to /dev/stdout with systemd, so log to file
	sed -i 's/error_log \/dev\/stdout warn\;/error_log nginx\.err warn\;/' /usr/local/nginx/conf/nginx.conf
	sed -i 's/access_log \/dev\/stdout main\;/access_log nginx\.log main\;/' /usr/local/nginx/conf/nginx.conf

	#Frigate web build
	#This should be architecture agnostic, so speed up the build on multiarch by not using QEMU.
	cd /opt/frigate/web

	npm install
	npm run build

    cp -r dist/BASE_PATH/monacoeditorwork/* dist/assets/
    cd /opt/frigate/
    cp -r /opt/frigate/web/dist/* /opt/frigate/web/

    msg_ok "Updated Frigate"

    msg_info "Starting Frigate"
    systemctl start frigate.service
    msg_ok "Started Frigate"

    msg_ok "$FRIGATE Update Successful"
    echo -e "\n ⚠️  Ensure you set resources back to normal settings \n"
    exit
  fi
  #Update go2rtc
  if [ "$UPD" == "2" ]; then
    msg_info "Stopping go2rtc"
    systemctl stop go2rtc.service
    msg_ok "Stopped go2rtc"

    msg_info "Updating go2rtc to $GO2RTC"
	mkdir -p /usr/local/go2rtc/bin
	cd /usr/local/go2rtc/bin
	#Get latest release
	wget -O go2rtc "https://github.com/AlexxIT/go2rtc/releases/latest/download/go2rtc_linux_amd64"
	chmod +x go2rtc
    msg_ok "Updated go2rtc"

    msg_info "Starting go2rtc"
    systemctl start go2rtc.service
    msg_ok "Started go2rtc"
    msg_ok "$GO2RTC Update Successful"
    exit
  fi
  #Update ffmpeg
  if [ "$UPD" == "3" ]; then
    msg_info "Stopping Frigate and go2rtc"
    systemctl stop frigate.service go2rtc.service
    msg_ok "Stopped Frigate and go2rtc"

    msg_info "Updating ffmpeg to $FFMPEG"
	apt install xz-utils
	mkdir -p /usr/lib/btbn-ffmpeg
	wget -qO btbn-ffmpeg.tar.xz "https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-n6.1-latest-linux64-gpl-6.1.tar.xz"
	tar -xf btbn-ffmpeg.tar.xz -C /usr/lib/btbn-ffmpeg --strip-components 1
	rm -rf btbn-ffmpeg.tar.xz /usr/lib/btbn-ffmpeg/doc /usr/lib/btbn-ffmpeg/bin/ffplay
    msg_ok "Updated ffmpeg"

    msg_info "Starting Frigate and go2rtc"
    systemctl start frigate.service go2rtc.service
    msg_ok "Started Frigate and go2rtc"
    msg_ok "$FFMPEG Update Successful"
    exit
  fi
}

start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -memory 1024
pct set $CTID -cores 2
msg_ok "Set Container to Normal Resources"
msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:5000${CL} \n"
