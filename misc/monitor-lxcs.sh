#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Proxmox VE LXC Monitor
# bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/monitor-lxcs.sh)"

clear
cat <<"EOF"
    __  ___            _ __                __   _  ________
   /  |/  /___  ____  (_) /_____  _____   / /  | |/ / ____/
  / /|_/ / __ \/ __ \/ / __/ __ \/ ___/  / /   |   / / 
 / /  / / /_/ / / / / / /_/ /_/ / /     / /___/   / /___
/_/  /_/\____/_/ /_/_/\__/\____/_/     /_____/_/|_\____/   

EOF

while true; do
  read -p "This script will add Monitor LXC to Proxmox VE. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

echo '#!/usr/bin/env bash
while true
do
  # Get the list of containers
  containers=$(pct list | tail -n +2 | cut -f1 -d" ")

  for container in $containers
  do
    # Skip containers based on templates
    template=$(pct config $container | grep -q "template:" && echo "true" || echo "false")
    if [ "$template" == "true" ]; then
      continue
    fi

    # Get the IP address of the container
    IP=$(pct exec $container ip a s dev eth0 | awk '\''/inet / {print $2}'\'' | cut -d/ -f1)

    # Ping the container
    if ! ping -c 1 $IP >/dev/null 2>&1; then
      # If the container can'\''t be pinged, stop and start it
      echo -e "$(date): Container $container is not responding, restarting..."
      pct stop $container >/dev/null 2>&1
      sleep 5
      pct start $container >/dev/null 2>&1
    fi
  done

  # Wait for 5 minutes
  echo -e "$(date): Sleeping for 5 minutes..."
  sleep 300
done >> /var/log/ping-containers.log 2>&1' >/usr/local/bin/ping-containers.sh

# Change the permissions
chmod +x /usr/local/bin/ping-containers.sh

# Create service
echo '[Unit]
Description=Pings containers every 5 minutes and restarts if necessary

[Service]
Type=simple
ExecStart=/usr/local/bin/ping-containers.sh
Restart=always
StandardOutput=file:/var/log/ping-containers.log
StandardError=file:/var/log/ping-containers.log

[Install]
WantedBy=multi-user.target' >/etc/systemd/system/ping-containers.service

# Reload daemon, enable and start ping-containers.service
systemctl daemon-reload
systemctl enable -q --now ping-containers.service
clear
echo -e "\n To view Monitor LXC logs: cat /var/log/ping-containers.log"

# To remove Monitor LXC from Proxmox VE
# 1) systemctl stop ping-containers.service
# 2) systemctl disable ping-containers.service
# 3) rm /etc/systemd/system/ping-containers.service
# 4) rm /usr/local/bin/ping-containers.sh
# 5) rm /var/log/ping-containers.log
