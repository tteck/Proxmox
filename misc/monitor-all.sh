#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

clear
cat <<"EOF"
    __  ___            _ __                ___    ____
   /  |/  /___  ____  (_) /_____  _____   /   |  / / /
  / /|_/ / __ \/ __ \/ / __/ __ \/ ___/  / /| | / / /
 / /  / / /_/ / / / / / /_/ /_/ / /     / ___ |/ / /
/_/  /_/\____/_/ /_/_/\__/\____/_/     /_/  |_/_/_/

EOF

add() {
while true; do
  read -p "This script will add Monitor All to Proxmox VE. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

echo '#!/usr/bin/env bash
# Maximum number of restarts
maxrestartcount=3

# Emails for restarts
mailaddress='\''admin@domain.tld'\''
mail="false"

# Search string for IP address, here more precise selection, IP addresses can be excluded.
searchip='\''192\.168\.|10\.'\''

# Read excluded instances from command line arguments
excluded_instances=("$@")
echo "$(date +'\''%Y-%m-%d %H:%M:%S'\''): Excluded instances: ${excluded_instances[@]}"

while true; do

  for vmid in $(pct list | awk '\''{if(NR>1) print $1}'\''; qm list | awk '\''{if(NR>1) print $1}'\'')
  do
    IP=
    skip="false"
    if [ -f /tmp/$vmid.count ] ; then
      count=$(cat /tmp/$vmid.count)
    else
      count=0
    fi
    # Determine the type of the instance (container or virtual machine)
    if pct status $vmid >/dev/null 2>&1; then
      # It is a container
      config_cmd="pct config"
      test=$(pct status $vmid | grep -q "status: running")
      if [ $? -eq 0 ] ; then
        IP=$(pct exec $vmid ip a s dev eth0 | awk '\''/inet / {print $2}'\'' | cut -d/ -f1)
      fi
    else
      # It is a virtual machine
      config_cmd="qm config"
      test=$(qm status $vmid | grep -q "status: running")
      if [ $? -eq 0 ] ; then
        IP=$(qm guest cmd $vmid network-get-interfaces | egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -E "$searchip" | head -n 1)
      fi
    fi
    name=$($config_cmd $vmid | grep name: | awk '\''{ print $2 }'\'')
    # Skip instances based on onboot and templates
    test=$($config_cmd $vmid | grep "onboot" | awk '\''{ print $2 }'\'')
    if [ "$test" == "1" ] ; then
      onboot="true"
    else
      onboot="false"
    fi
    test=$($config_cmd $vmid | grep "template:" | awk '\''{ print $2 }'\'')
    if [ "$test" == "1" ] ; then
      template="true"
    else
      template="false"
    fi

    if [ "$onboot" == "false" ]; then
      echo "$(date +'\''%Y-%m-%d %H:%M:%S'\''): Skipping $vmid $name because it is set not to boot"
      skip="true"
    fi
    if [ "$template" == "true" ]; then
      echo "$(date +'\''%Y-%m-%d %H:%M:%S'\''): Skipping $vmid $name because it is a template"
      skip="true"
    fi
    if [ "$skip" == "false" ] ; then
      # Ping the instance
      if ! ping -c 1 $IP >/dev/null 2>&1; then
        if [ $count -le $maxrestartcount ] ; then
          count=$((count + 1))
          # If the instance can not be pinged, stop and start it
          if pct status $vmid >/dev/null 2>&1; then
            # It is a container
            echo "$(date +'\''%Y-%m-%d %H:%M:%S'\''): CT $vmid $name is not responding, restarting..."
            if [ "$mail" == "true" ] ;then
              echo "CT $vmid $name is not responding, restarting" | mail -s "$(date +'\''%Y-%m-%d %H:%M:%S'\''): $(hostname) - $name" $mailaddress
            fi
            pct stop $vmid >/dev/null 2>&1
            sleep 5
            pct start $vmid >/dev/null 2>&1
          else
            # It is a virtual machine
            test=$(qm status $vmid | grep -q "status: running")
            if [ $? -eq 0 ] ; then
              echo "$(date +'\''%Y-%m-%d %H:%M:%S'\''): VM $vmid $name is not responding, restarting..."
              if [ "$mail" == "true" ] ;then
                echo "VM $vmid $name is not responding, restarting" | mail -s "$(date +'\''%Y-%m-%d %H:%M:%S'\''): $(hostname) - $name" $mailaddress
              fi
              qm stop $vmid >/dev/null 2>&1
              sleep 5
            else
              echo "$(date +'%Y-%m-%d %H:%M:%S'): VM $vmid $name is not running, starting..."
            fi
            qm start $vmid >/dev/null 2>&1
            echo "$count" > /tmp/$vmid.count
          fi
        else
          echo "$(date +'\''%Y-%m-%d %H:%M:%S'\''): VM $vmid $name max restart count $count reached"
          if [ "$mail" == "true" ] ;then
            echo "VM $vmid $name max restart count $count reached" | mail -s "$(date +'\''%Y-%m-%d %H:%M:%S'\''): $(hostname) - $name" $mailaddress
          fi
        fi
      else
        echo "$(date +'\''%Y-%m-%d %H:%M:%S'\''): CT/VM $vmid $name with ip $IP is pingable..."
        echo "0" > /tmp/$vmid.count
      fi
    fi
  done

  # Wait for 5 minutes. (Edit to your needs)
  echo "$(date +'\''%Y-%m-%d %H:%M:%S'\''): Pausing for 5 minutes..."
  sleep 300
done >/var/log/ping-instances.log 2>&1' >/usr/local/bin/ping-instances.sh
touch /var/log/ping-instances.log
# Change file permissions to executable
chmod +x /usr/local/bin/ping-instances.sh
cat <<EOF >/etc/systemd/system/ping-instances.timer
[Unit]
Description=Delay ping-instances.service by 5 minutes

[Timer]
OnBootSec=300
OnUnitActiveSec=300

[Install]
WantedBy=timers.target
EOF

# Create ping-instances.service
cat <<EOF >/etc/systemd/system/ping-instances.service
[Unit]
Description=Ping instances every 5 minutes and restarts if necessary
After=ping-instances.timer
Requires=ping-instances.timer
[Service]
Type=simple
# To specify which CT/VM should be excluded, add the CT/VM ID at the end of the line where ExecStart=/usr/local/bin/ping-instances.sh is specified.
# For example: ExecStart=/usr/local/bin/ping-instances.sh 100 102
# Virtual machines without the QEMU guest agent installed must be excluded.

ExecStart=/usr/local/bin/ping-instances.sh
Restart=always
StandardOutput=file:/var/log/ping-instances.log
StandardError=file:/var/log/ping-instances.log

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon, enable and start ping-instances.service
systemctl daemon-reload
systemctl enable -q --now ping-instances.timer
systemctl enable -q --now ping-instances.service
clear
echo -e "\n To view Monitor All logs: cat /var/log/ping-instances.log"
}

remove() {
  systemctl disable -q --now ping-instances.timer
  systemctl disable -q --now ping-instances.service
  rm /etc/systemd/system/ping-instances.service /etc/systemd/system/ping-instances.timer /usr/local/bin/ping-instances.sh /var/log/ping-instances.log
  echo "Removed Monitor All from Proxmox VE"
}

# Define options for the whiptail menu
OPTIONS=(Add "Add Monitor-All to Proxmox VE" \
         Remove "Remove Monitor-All from Proxmox VE")

# Show the whiptail menu and save the user's choice
CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "Monitor-All for Proxmox VE" --menu "Select an option:" 10 58 2 \
          "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

# Check the user's choice and perform the corresponding action
case $CHOICE in
  "Add")
    add
    ;;
  "Remove")
    remove
    ;;
  *)
    echo "Exiting..."
    exit 0
    ;;
esac
