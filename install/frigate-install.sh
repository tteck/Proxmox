#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Installed Dependencies"

msg_info "Installing Docker"

get_latest_release() {
  curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
}

DOCKER_LATEST_VERSION=$(get_latest_release "moby/moby")
DOCKER_COMPOSE_LATEST_VERSION=$(get_latest_release "docker/compose")

msg_info "Installing Docker $DOCKER_LATEST_VERSION"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
$STD sh <(curl -sSL https://get.docker.com)
msg_ok "Installed Docker $DOCKER_LATEST_VERSION"

msg_ok "Installed Docker"

msg_info "Creating Frigate configuration file"
mkdir -p /config
cat >/config/config.yml <<'EOL'
detectors:
  # Required: name of the detector
  detector_name:
    # Required: type of the detector
    # Frigate provided types include 'cpu', 'edgetpu', 'openvino' and 'tensorrt' (default: shown below)
    # Additional detector types can also be plugged in.
    # Detectors may require additional configuration.
    # Refer to the Detectors configuration page for more information.
    type: cpu

mqtt:
  enabled: False

go2rtc:
  streams:
    dummy_camera:
      - "ffmpeg:/media/frigate/person-bicycle-car-detection.mp4"
    dummy_camera_sub:
      - "ffmpeg:/media/frigate/person-bicycle-car-detection.mp4#video=h264#width=640"

  webrtc:
    candidates:
      #- 192.168.1.1:8555
      - stun:8555

cameras:
  dummy_camera: # <--- this will be changed to your actual camera later
    enabled: true
    ffmpeg:
      output_args:
        record: preset-record-generic-audio-copy
      inputs:
        - path: rtsp://127.0.0.1:8554/dummy_camera # <--- the name here must match the name of the camera in restream
          input_args: preset-rtsp-restream
          roles:
            - record
            - audio # <- only necessary if audio detection is enabled
  dummy_camera_sub: # <--- this will be changed to your actual camera later
    enabled: true
    ffmpeg:
      output_args:
        record: preset-record-generic-audio-copy
      inputs:
        - path: rtsp://127.0.0.1:8554/dummy_camera_sub # <--- the name here must match the name of the camera in restream
          input_args: preset-rtsp-restream
          roles:
            - detect

motion:
  # Optional: The threshold passed to cv2.threshold to determine if a pixel is different enough to be counted as motion. (default: 30)
  # Increasing this value will make motion detection less sensitive and decreasing it will make motion detection more sensitive.
  # The value should be between 1 and 255.
  threshold: 30
  # Optional: The percentage of the image used to detect lightning or other substantial changes where motion detection
  #           needs to recalibrate. (default: shown below)
  # Increasing this value will make motion detection more likely to consider lightning or ir mode changes as valid motion.
  # Decreasing this value will make motion detection more likely to ignore large amounts of motion such as a person approaching
  # a doorbell camera.
  lightning_threshold: 0.8
  # Optional: Minimum size in pixels in the resized motion image that counts as motion (default: 10)
  # Increasing this value will prevent smaller areas of motion from being detected. Decreasing will
  # make motion detection more sensitive to smaller moving objects.
  # As a rule of thumb:
  #  - 10 - high sensitivity
  #  - 30 - medium sensitivity
  #  - 50 - low sensitivity
  contour_area: 10
  # Optional: Alpha value passed to cv2.accumulateWeighted when averaging frames to determine the background (default: 0.01)
  # Higher values mean the current frame impacts the average a lot, and a new object will be averaged into the background faster.
  # Low values will cause things like moving shadows to be detected as motion for longer.
  # https://www.geeksforgeeks.org/background-subtraction-in-an-image-using-concept-of-running-average/
  frame_alpha: 0.01
  # Optional: Height of the resized motion frame  (default: 100)
  # Higher values will result in more granular motion detection at the expense of higher CPU usage.
  # Lower values result in less CPU, but small changes may not register as motion.
  frame_height: 100
  # Optional: motion mask
  # NOTE: see docs for more detailed info on creating masks
  #mask: 0,900,1080,900,1080,1920,0,1920
  # Optional: improve contrast (default: shown below)
  # Enables dynamic contrast improvement. This should help improve night detections at the cost of making motion detection more sensitive
  # for daytime.
  improve_contrast: False
  # Optional: Delay when updating camera motion through MQTT from ON -> OFF (default: shown below).
  mqtt_off_delay: 30

live:
  # Optional: Set the name of the stream that should be used for live view
  # in frigate WebUI. (default: name of camera)
  stream_name: dummy_camera_sub
  # Optional: Set the height of the jsmpeg stream. (default: 720)
  # This must be less than or equal to the height of the detect stream. Lower resolutions
  # reduce bandwidth required for viewing the jsmpeg stream. Width is computed to match known aspect ratio.
  height: 720
  # Optional: Set the encode quality of the jsmpeg stream (default: shown below)
  # 1 is the highest quality, and 31 is the lowest. Lower quality feeds utilize less CPU resources.
  quality: 8

# Optional: Record configuration
# NOTE: Can be overridden at the camera level
record:
  # Optional: Enable recording (default: shown below)
  # WARNING: If recording is disabled in the config, turning it on via
  #          the UI or MQTT later will have no effect.
  enabled: False

objects:
  track:
    - person
    - car
    - bicycle
EOL
msg_ok "Frigate configuration file created at /config/config.yml"


msg_info "Creating Frigate media folder"
mkdir -p /media/frigate
msg_ok "Frigate media folder created at /media/frigate"

msg_info "Downloading sample video file"
cd /media/frigate
wget -q https://github.com/intel-iot-devkit/sample-videos/raw/master/person-bicycle-car-detection.mp4
msg_ok "Sample video file downloaded"

msg_info "Creating Frigate docker compose file"
mkdir -p /opt/frigate
cat >/opt/frigate/docker-compose.yml <<'EOL'
services:
  frigate:
    container_name: frigate
    privileged: true # this may not be necessary for all setups
    network_mode: host # no ports need to be mapped
    restart: unless-stopped
    image: ghcr.io/blakeblackshear/frigate:stable
    shm_size: "64mb" 
    # update for your cameras based on calculation above
#    devices:
#      - /dev/bus/usb:/dev/bus/usb  # Passes the USB Coral, needs to be modified for other versions
#      - /dev/apex_0:/dev/apex_0    # Passes a PCIe Coral, follow driver instructions here https://coral.ai/docs/m2/get-started/#2a-on-linux
#      - /dev/video11:/dev/video11  # For Raspberry Pi 4B
#      - /dev/dri/renderD128:/dev/dri/renderD128 # For intel hwaccel, needs to be updated for your hardware
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /config:/config
      - /media/frigate:/media/frigate
      - type: tmpfs # Optional: 1GB of memory, reduces SSD/SD Card wear
        target: /tmp/cache
        tmpfs:
          size: 1000000000
    ports:
      - "5000:5000"
      - "8554:8554" # RTSP feeds
      - "8555:8555/tcp" # WebRTC over tcp
      - "8555:8555/udp" # WebRTC over udp
    environment:
      FRIGATE_RTSP_PASSWORD: "password"
EOL
msg_ok "Frigate docker compose file created at /opt/frigate/docker-compose.yml"

msg_info "Downloading Frigate containers"
cd /opt/frigate
docker compose pull --quiet
docker compose up -d --quiet-pull
msg_ok "Frigate downloaded and started"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
