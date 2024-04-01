#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Authors: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y {curl,sudo,mc,git,gpg,automake,build-essential,xz-utils,libtool,ccache,pkg-config,libgtk-3-dev,libavcodec-dev,libavformat-dev,libswscale-dev,libv4l-dev,libxvidcore-dev,libx264-dev,libjpeg-dev,libpng-dev,libtiff-dev,gfortran,openexr,libatlas-base-dev,libssl-dev,libtbb2,libtbb-dev,libdc1394-22-dev,libopenexr-dev,libgstreamer-plugins-base1.0-dev,libgstreamer1.0-dev,gcc,gfortran,libopenblas-dev,liblapack-dev,libusb-1.0-0-dev}
msg_ok "Installed Dependencies"

msg_info "Installing Python3 Dependencies"
$STD apt-get install -y {python3,python3-dev,python3-setuptools,python3-distutils}
wget -q https://bootstrap.pypa.io/get-pip.py -O get-pip.py
$STD python3 get-pip.py --quiet "pip"
msg_ok "Installed Python3 Dependencies"

msg_info "Installing Node.js"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
$STD apt-get update
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing go2rtc"
mkdir -p /usr/local/go2rtc/bin
cd /usr/local/go2rtc/bin
wget -qO go2rtc "https://github.com/AlexxIT/go2rtc/releases/latest/download/go2rtc_linux_amd64"
chmod +x go2rtc
$STD ln -svf /usr/local/go2rtc/bin/go2rtc /usr/local/bin/go2rtc
msg_ok "Installed go2rtc"

if [[ "$CTTYPE" == "0" ]]; then
  msg_info "Setting Up Hardware Acceleration"
  $STD apt-get -y install {va-driver-all,ocl-icd-libopencl1,intel-opencl-icd,vainfo,intel-gpu-tools}
  chgrp video /dev/dri
  chmod 755 /dev/dri
  chmod 660 /dev/dri/*
  $STD adduser $(id -u -n) video
  $STD adduser $(id -u -n) render
  msg_ok "Set Up Hardware Acceleration"
fi

RELEASE=$(curl -s https://api.github.com/repos/blakeblackshear/frigate/releases/latest | grep -o '"tag_name": *"[^"]*"' | cut -d '"' -f 4)
msg_info "Installing Frigate $RELEASE (Perseverance)"
cd ~
mkdir -p /opt/frigate/models
wget -q https://github.com/blakeblackshear/frigate/archive/refs/tags/${RELEASE}.tar.gz -O frigate.tar.gz
tar -xzf frigate.tar.gz -C /opt/frigate --strip-components 1
rm -rf frigate.tar.gz
cd /opt/frigate
$STD pip3 wheel --wheel-dir=/wheels -r /opt/frigate/docker/main/requirements-wheels.txt
cp -a /opt/frigate/docker/main/rootfs/. /
export TARGETARCH="amd64"
echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections
$STD /opt/frigate/docker/main/install_deps.sh
$STD ln -svf /usr/lib/btbn-ffmpeg/bin/ffmpeg /usr/local/bin/ffmpeg
$STD ln -svf /usr/lib/btbn-ffmpeg/bin/ffprobe /usr/local/bin/ffprobe
$STD pip3 install -U /wheels/*.whl
ldconfig
$STD pip3 install -r /opt/frigate/docker/main/requirements-dev.txt
$STD /opt/frigate/.devcontainer/initialize.sh
$STD make version
cd /opt/frigate/web
$STD npm install
$STD npm run build
cp -r /opt/frigate/web/dist/* /opt/frigate/web/
cp -r /opt/frigate/config/. /config
sed -i '/^s6-svc -O \.$/s/^/#/' /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/frigate/run
cat <<EOF >/config/config.yml
mqtt:
  enabled: false
model:
  path: /root/cpu_model.tflite
cameras:
  test:
    ffmpeg:
      #hwaccel_args: preset-vaapi
      inputs:
        - path: /media/frigate/person-bicycle-car-detection.mp4
          input_args: -re -stream_loop -1 -fflags +genpts
          roles:
            - detect
            - rtmp
    detect:
      height: 1080
      width: 1920
      fps: 5
EOF
ln -sf /config/config.yml /opt/frigate/config/config.yml
mkdir -p /dev/shm/logs/{frigate,go2rtc,nginx}
touch /dev/shm/logs/{frigate/current,go2rtc/current,nginx/current}
chmod -R 777 /dev/shm
sed -i -e 's/^kvm:x:104:$/render:x:104:root,frigate/' -e 's/^render:x:105:root$/kvm:x:105:/' /etc/group
msg_ok "Installed Frigate $RELEASE"

msg_info "Installing Object Detection Models (Resilience)"
$STD pip install -r /opt/frigate/docker/main/requirements-ov.txt
cd /opt/frigate/models
export ENABLE_ANALYTICS=NO
$STD /usr/local/bin/omz_downloader --name ssdlite_mobilenet_v2
cd ..
export CCACHE_DIR=/root/.ccache
export CCACHE_MAXSIZE=2G
wget -q https://github.com/libusb/libusb/archive/v1.0.26.zip
unzip -q v1.0.26.zip
rm v1.0.26.zip
cd libusb-1.0.26
$STD ./bootstrap.sh
$STD ./configure --disable-udev --enable-shared
$STD make -j $(nproc --all)
cd /opt/frigate/libusb-1.0.26/libusb
mkdir -p /usr/local/lib
$STD /bin/bash ../libtool  --mode=install /usr/bin/install -c libusb-1.0.la '/usr/local/lib'
mkdir -p /usr/local/include/libusb-1.0
$STD /usr/bin/install -c -m 644 libusb.h '/usr/local/include/libusb-1.0'
ldconfig
cd ~
wget -qO edgetpu_model.tflite https://github.com/google-coral/test_data/raw/release-frogfish/ssdlite_mobiledet_coco_qat_postprocess_edgetpu.tflite
wget -qO cpu_model.tflite https://github.com/google-coral/test_data/raw/release-frogfish/ssdlite_mobiledet_coco_qat_postprocess.tflite
cp /opt/frigate/labelmap.txt /labelmap.txt
cp -r /opt/frigate/models/public/ssdlite_mobilenet_v2 openvino-model
wget -q https://github.com/openvinotoolkit/open_model_zoo/raw/master/data/dataset_classes/coco_91cl_bkgr.txt -O openvino-model/coco_91cl_bkgr.txt
sed -i 's/truck/car/g' openvino-model/coco_91cl_bkgr.txt
wget -qO cpu_audio_model.tflite https://tfhub.dev/google/lite-model/yamnet/classification/tflite/1?lite-format=tflite
cp /opt/frigate/audio-labelmap.txt /audio-labelmap.txt
mkdir -p /media/frigate
wget -qO /media/frigate/person-bicycle-car-detection.mp4 https://github.com/intel-iot-devkit/sample-videos/raw/master/person-bicycle-car-detection.mp4
msg_ok "Installed Object Detection Models"

msg_info "Building Nginx with Custom Modules"
$STD /opt/frigate/docker/main/build_nginx.sh
sed -i 's/exec nginx/exec \/usr\/local\/nginx\/sbin\/nginx/g' /opt/frigate/docker/main/rootfs/etc/s6-overlay/s6-rc.d/nginx/run
sed -i 's/error_log \/dev\/stdout warn\;/error_log nginx\.err warn\;/' /usr/local/nginx/conf/nginx.conf
sed -i 's/access_log \/dev\/stdout main\;/access_log nginx\.log main\;/' /usr/local/nginx/conf/nginx.conf
msg_ok "Built Nginx"

msg_info "Creating Services"
cat <<EOF >/etc/systemd/system/go2rtc.service
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
systemctl enable -q --now go2rtc
sleep 3
cat <<EOF >/etc/systemd/system/frigate.service
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
systemctl enable -q --now frigate
sleep 3
cat <<EOF >/etc/systemd/system/nginx.service
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
systemctl enable -q --now nginx
msg_ok "Configured Services"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
