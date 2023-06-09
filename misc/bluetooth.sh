#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

if command -v pveversion >/dev/null 2>&1; then echo -e "⚠️  Can't Run from the Proxmox Shell"; exit; fi
set -e
clear

while true; do
    read -p "Start the Bluetooth Integration Preparation (y/n)?" yn
    case $yn in
    [Yy]*) break ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
done

clear
    cat <<"EOF"
    __  __                        ___              _      __              __ 
   / / / /___  ____ ___  ___     /   |  __________(_)____/ /_____ _____  / /_
  / /_/ / __ \/ __ `__ \/ _ \   / /| | / ___/ ___/ / ___/ __/ __ `/ __ \/ __/
 / __  / /_/ / / / / / /  __/  / ___ |(__  |__  ) (__  ) /_/ /_/ / / / / /_  
/_/ /_/\____/_/ /_/ /_/\___/  /_/  |_/____/____/_/____/\__/\__,_/_/ /_/\__/  
      / __ )/ /_  _____  / /_____  ____  / /_/ /_                            
     / __  / / / / / _ \/ __/ __ \/ __ \/ __/ __ \                           
    / /_/ / / /_/ /  __/ /_/ /_/ / /_/ / /_/ / / /                           
   /_____/_/\__,_/\___/\__/\____/\____/\__/_/_/_/_                           
        /  _/___  / /____  ____ __________ _/ /_(_)___  ____                 
        / // __ \/ __/ _ \/ __ `/ ___/ __ `/ __/ / __ \/ __ \                
      _/ // / / / /_/  __/ /_/ / /  / /_/ / /_/ / /_/ / / / /                
     /___/_/_/_/\__/\___/\__, /_/   \__,_/\__/_/\____/_/ /_/                 
          / __ \________/____/  ____ __________ _/ /_(_)___  ____            
         / /_/ / ___/ _ \/ __ \/ __ `/ ___/ __ `/ __/ / __ \/ __ \           
        / ____/ /  /  __/ /_/ / /_/ / /  / /_/ / /_/ / /_/ / / / /           
       /_/   /_/   \___/ .___/\__,_/_/   \__,_/\__/_/\____/_/ /_/            
                      /_/                                                    

EOF
read -r -p "Switch from dbus-daemon to dbus-broker? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
cat <<EOF >>/etc/apt/sources.list
deb http://deb.debian.org/debian bullseye-backports main contrib non-free

deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free
EOF
apt-get update &>/dev/null
apt-get -t bullseye-backports install -y dbus-broker &>/dev/null
systemctl enable dbus-broker.service &>/dev/null
fi
read -r -p "Install BlueZ? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
apt-get -t bullseye-backports install -y bluez* &>/dev/null
fi
echo -e "Finished, reboot for changes to take affect"
