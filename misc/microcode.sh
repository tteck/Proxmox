#!/usr/bin/env bash
# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

clear
while true; do
  read -p "Install the latest Intel Processor Microcode (y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
clear
cat <<"EOF"
    ____      __       __   __  ____                                __   
   /  _/___  / /____  / /  /  |/  (_)_____________  _________  ____/ /__
   / // __ \/ __/ _ \/ /  / /|_/ / / ___/ ___/ __ \/ ___/ __ \/ __  / _ \
 _/ // / / / /_/  __/ /  / /  / / / /__/ /  / /_/ / /__/ /_/ / /_/ /  __/
/___/_/ /_/\__/\___/_/  /_/  /_/_/\___/_/   \____/\___/\____/\__,_/\___/

EOF

RD=$(echo "\033[01;31m")
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

set -euo pipefail
shopt -s inherit_errexit nullglob

msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

msg_info "Checking CPU Vendor"
cpu=$(lscpu | grep -oP 'Vendor ID:\s*\K\S+')
if [ "$cpu" == "GenuineIntel" ]; then
  msg_ok "${cpu} was detected"
else
  msg_error "${cpu} is not supported" 
  exit
fi 

msg_info "Installing iucode-tool: a tool for updating Intel processor microcode"
apt-get install -y iucode-tool &>/dev/null
msg_ok "Installed iucode-tool"

msg_info "Downloading the latest Intel Processor Microcode Package for Linux"
release=$(curl -s https://api.github.com/repos/intel/Intel-Linux-Processor-Microcode-Data-Files/releases/latest | awk -F'"' '/tag_name/{print $4}' | tr -cd '[:digit:]')
wget -q http://ftp.debian.org/debian/pool/non-free-firmware/i/intel-microcode/intel-microcode_3.${release}.1_amd64.deb
msg_ok "Downloaded the latest Intel Processor Microcode Package"

msg_info "Installing the Intel Processor Microcode (Patience)"
dpkg -i intel-microcode_3.${release}.1_amd64.deb &>/dev/null
msg_ok "Installed the Intel Processor Microcode"

msg_info "Cleaning up"
rm intel-microcode_3.${release}.1_amd64.deb
msg_ok "Cleaned"

echo -e "\n To apply the settings, the system will need to be rebooted.\n"
