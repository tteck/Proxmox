#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Authors: tteck (tteckster), remz1337
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
#Configuration to make unattended installs with APT
#https://serverfault.com/questions/48724/100-non-interactive-debian-dist-upgrade
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
#especially libc6, installed part of the dependency script (install_deps.sh)
echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections
cd /opt
$STD apt update
$STD apt upgrade -y
#I tried to install all the dependencies at the beginning, but it induced an error when building nginx, so I kept them in the same order of the Dockerfile
$STD apt install -y git automake build-essential wget xz-utils
msg_ok "Installed Dependencies"


msg_info "Downloading Frigate"
#Pull Frigate from  repo
#git clone https://github.com/blakeblackshear/frigate.git
$STD wget https://github.com/blakeblackshear/frigate/archive/refs/tags/v0.13.0-beta2.tar.gz -O frigate.tar.gz
mkdir frigate
$STD tar -xzf frigate.tar.gz -C frigate --strip-components 1
cd /opt/frigate
#Used in build dependencies scripts
export TARGETARCH=amd64
msg_ok "Downloaded Frigate"

msg_info "Building Nginx with custom modules"
$STD docker/main/build_nginx.sh
msg_ok "Built Nginx with custom modules"

msg_info "Installing go2rtc"
mkdir -p /usr/local/go2rtc/bin
cd /usr/local/go2rtc/bin
$STD wget -O go2rtc "https://github.com/AlexxIT/go2rtc/releases/download/v1.8.1/go2rtc_linux_${TARGETARCH}"
chmod +x go2rtc
msg_ok "Installed go2rtc"

msg_info "Installing object detection models"
cd /opt/frigate

### OpenVino
$STD apt install -y wget python3 python3-distutils
$STD wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
$STD python3 get-pip.py "pip"
$STD pip install -r docker/main/requirements-ov.txt


# Get OpenVino Model
mkdir -p /opt/frigate/models
cd /opt/frigate/models
$STD omz_downloader --name ssdlite_mobilenet_v2
cd /opt/frigate/models
$STD omz_converter --name ssdlite_mobilenet_v2 --precision FP16

# Build libUSB without udev.  Needed for Openvino NCS2 support
cd /opt/frigate

export CCACHE_DIR=/root/.ccache
export CCACHE_MAXSIZE=2G

$STD apt install -y unzip build-essential automake libtool ccache pkg-config

$STD wget https://github.com/libusb/libusb/archive/v1.0.26.zip -O v1.0.26.zip
$STD unzip v1.0.26.zip
cd libusb-1.0.26
$STD ./bootstrap.sh
$STD ./configure --disable-udev --enable-shared
$STD make -j $(nproc --all)

$STD apt install -y --no-install-recommends libusb-1.0-0-dev

cd /opt/frigate/libusb-1.0.26/libusb

mkdir -p /usr/local/lib
$STD /bin/bash ../libtool  --mode=install /usr/bin/install -c libusb-1.0.la '/usr/local/lib'
mkdir -p /usr/local/include/libusb-1.0
$STD /usr/bin/install -c -m 644 libusb.h '/usr/local/include/libusb-1.0'
mkdir -p /usr/local/lib/pkgconfig
cd /opt/frigate/libusb-1.0.26/
$STD /usr/bin/install -c -m 644 libusb-1.0.pc '/usr/local/lib/pkgconfig'
ldconfig

######## Frigate expects model files at root of filesystem
#cd /opt/frigate/models
cd /

# Get model and labels
$STD wget -O edgetpu_model.tflite https://github.com/google-coral/test_data/raw/release-frogfish/ssdlite_mobiledet_coco_qat_postprocess_edgetpu.tflite
$STD wget -O cpu_model.tflite https://github.com/google-coral/test_data/raw/release-frogfish/ssdlite_mobiledet_coco_qat_postprocess.tflite

#cp /opt/frigate/labelmap.txt .
$STD cp /opt/frigate/labelmap.txt /labelmap.txt
$STD cp -r /opt/frigate/models/public/ssdlite_mobilenet_v2/FP16 openvino-model

$STD wget https://github.com/openvinotoolkit/open_model_zoo/raw/master/data/dataset_classes/coco_91cl_bkgr.txt -O openvino-model/coco_91cl_bkgr.txt
sed -i 's/truck/car/g' openvino-model/coco_91cl_bkgr.txt
# Get Audio Model and labels
$STD wget -qO cpu_audio_model.tflite https://tfhub.dev/google/lite-model/yamnet/classification/tflite/1?lite-format=tflite
$STD cp /opt/frigate/audio-labelmap.txt /audio-labelmap.txt
msg_ok "Installed object detection models"

msg_info "Configuring Python dependencies"
cd /opt/frigate

$STD apt install -y python3 python3-dev wget build-essential cmake git pkg-config libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev gfortran openexr libatlas-base-dev libssl-dev libtbb2 libtbb-dev libdc1394-22-dev libopenexr-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev gcc gfortran libopenblas-dev liblapack-dev

$STD pip3 install -r docker/main/requirements.txt

$STD pip3 wheel --wheel-dir=/wheels -r /opt/frigate/docker/main/requirements-wheels.txt
#pip3 wheel --wheel-dir=/trt-wheels -r /opt/frigate/docker/tensorrt/requirements-amd64.txt

#Copy preconfigured files
$STD cp -a /opt/frigate/docker/main/rootfs/. /

#exports are lost upon system reboot...
#export PATH="$PATH:/usr/lib/btbn-ffmpeg/bin:/usr/local/go2rtc/bin:/usr/local/nginx/sbin"

# Install dependencies
$STD /opt/frigate/docker/main/install_deps.sh

#Create symbolic links to ffmpeg and go2rtc
$STD ln -svf /usr/lib/btbn-ffmpeg/bin/ffmpeg /usr/local/bin/ffmpeg
$STD ln -svf /usr/lib/btbn-ffmpeg/bin/ffprobe /usr/local/bin/ffprobe
$STD ln -svf /usr/local/go2rtc/bin/go2rtc /usr/local/bin/go2rtc

$STD pip3 install -U /wheels/*.whl
ldconfig
msg_ok "Configured Python dependencies"

msg_info "Installing NodeJS"
# Install Node 16
#wget -O- https://deb.nodesource.com/setup_16.x | bash -

# Install Node 21
#curl -fsSL https://deb.nodesource.com/setup_21.x | sudo -E bash -
#curl -fsSL https://deb.nodesource.com/setup_21.x | bash -
$STD wget https://deb.nodesource.com/setup_21.x
$STD /bin/bash setup_21.x

$STD apt install -y nodejs
#npm install -g npm@9
$STD npm install -g npm
msg_ok "Installed NodeJS"

msg_info "Installing Frigate"

$STD pip3 install -r /opt/frigate/docker/main/requirements-dev.txt

cd /opt/frigate

$STD /opt/frigate/.devcontainer/initialize.sh

$STD make version

# Frigate web build
# This should be architecture agnostic, so speed up the build on multiarch by not using QEMU.
cd /opt/frigate/web

$STD npm install
$STD npm run build

$STD cp -r dist/BASE_PATH/monacoeditorwork/* dist/assets/
cd /opt/frigate/
$STD cp -r /opt/frigate/web/dist/* /opt/frigate/web/

### BUILD COMPLETE, NOW INITIALIZE

mkdir /config
$STD cp -r /opt/frigate/config/. /config
$STD cp /config/config.yml.example /config/config.yml

################### EDIT CONFIG FILE HERE ################
#mqtt:
#  enabled: False
#
#cameras:
#  Camera1:
#    ffmpeg:
#      hwaccel_args: -c:v h264_cuvid
##      hwaccel_args: preset-nvidia-h264 #This one is not working...
#      inputs:
#        - path: rtsp://user:password@192.168.1.123:554/h264Preview_01_main
#          roles:
#            - detect
#    detect:
#      enabled: False
#      width: 2560
#      height: 1920
#########################################################

cd /opt/frigate
msg_ok "Installed Frigate"

msg_info "Configuring Services"
#####Start order should be:
#1. Go2rtc
#2. Frigate
#3. Nginx

### Starting go2rtc
#Create systemd service. If done manually, edit the file (nano /etc/systemd/system/go2rtc.service) then copy/paste the service configuraiton
go2rtc_service="$(cat << EOF

[Unit]
Description=go2rtc service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=bash /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/go2rtc/run

[Install]
WantedBy=multi-user.target

EOF
)"

echo "${go2rtc_service}" > /etc/systemd/system/go2rtc.service

$STD systemctl start go2rtc
$STD systemctl enable go2rtc

#Allow for a small delay before starting the next service
sleep 3

#Test go2rtc access at
#http://<machine_ip>:1984/



### Starting Frigate
#First, comment the call to S6 in the run script
sed -i '/^s6-svc -O \.$/s/^/#/' /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/frigate/run

#Second, install yq, needed by script to check database path
$STD wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod a+x /usr/local/bin/yq

#Create systemd service
frigate_service="$(cat << EOF

[Unit]
Description=Frigate service
After=go2rtc.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=bash /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/frigate/run

[Install]
WantedBy=multi-user.target

EOF
)"

echo "${frigate_service}" > /etc/systemd/system/frigate.service

$STD systemctl start frigate
$STD systemctl enable frigate

#Allow for a small delay before starting the next service
sleep 3

### Starting Nginx

## Call nginx from absolute path
## nginx --> /usr/local/nginx/sbin/nginx
sed -i 's/exec nginx/exec \/usr\/local\/nginx\/sbin\/nginx/g' /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/nginx/run

#Can't log to /dev/stdout with systemd, so log to file
sed -i 's/error_log \/dev\/stdout warn\;/error_log nginx\.err warn\;/' /usr/local/nginx/conf/nginx.conf
sed -i 's/access_log \/dev\/stdout main\;/access_log nginx\.log main\;/' /usr/local/nginx/conf/nginx.conf

#Create systemd service
nginx_service="$(cat << EOF

[Unit]
Description=Nginx service
After=frigate.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=bash /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/nginx/run

[Install]
WantedBy=multi-user.target

EOF
)"

echo "${nginx_service}" > /etc/systemd/system/nginx.service

$STD systemctl start nginx
$STD systemctl enable nginx
msg_ok "Configured Services"

#Test frigate through Nginx access at
#http://<machine_ip>:5000/

######## FULL FRIGATE CONFIG EXAMPLE:
#https://docs.frigate.video/configuration/

motd_ssh
customize

msg_info "Cleaning up"
rm /opt/frigate.tar.gz
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"

msg_ok "Don't forget to edit the Frigate config file (/config/config.yml) and reboot. Example configuration at https://docs.frigate.video/configuration/"
msg_ok "Frigate standalone installation complete! You can access the web interface at http://<machine_ip>:5000"