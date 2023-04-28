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

add() {
while true; do
  read -p "This script will add Monitor LXC to Proxmox VE. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

echo '#!/usr/bin/env bash

# Read excluded containers from command line arguments
excluded_containers=("$@")
echo "Excluded containers: ${excluded_containers[@]}"

while true
do
  # Get the list of containers
  containers=$(pct list | tail -n +2 | cut -f1 -d" ")

  for container in $containers
  do
    # Skip excluded containers
    if [[ " ${excluded_containers[@]} " =~ " ${container} " ]]; then
      continue
    fi

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
      echo "$(date): Container $container is not responding, restarting..."
      pct stop $container >/dev/null 2>&1
      sleep 5
      pct start $container >/dev/null 2>&1
    fi
  done

  # Wait for 5 minutes. (Edit to your needs)
  echo "$(date): Sleeping for 5 minutes..."
  sleep 300
done >> /var/log/ping-containers.log 2>&1' >/usr/local/bin/ping-containers.sh

# Change file permissions to executable
chmod +x /usr/local/bin/ping-containers.sh

# Create ping-containers.service
echo '[Unit]
Description=Pings containers every 5 minutes and restarts if necessary

[Service]
Type=simple
# Include the container ID at the end of the line where ExecStart=/usr/local/bin/ping-containers.sh is specified,
# to indicate which container should be excluded. Example: ExecStart=/usr/local/bin/ping-containers.sh 100 102
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
}

remove() {
  systemctl stop ping-containers.service
  systemctl disable ping-containers.service &>/dev/null
  rm /etc/systemd/system/ping-containers.service
  rm /usr/local/bin/ping-containers.sh
  rm /var/log/ping-containers.log
  echo "Removed Monitor LXC from Proxmox VE"
}

if [ "$1" == "add" ]; then
    add
elif [ "$1" == "remove" ]; then
    remove
else
    echo "Usage: $0 [add | remove]"
    exit 1
fi
