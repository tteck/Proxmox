#!/usr/bin/env bash
function header_info {
clear
cat <<"EOF"
   __  __          __      __          __   _  ________
  / / / /___  ____/ /___ _/ /____     / /  | |/ / ____/
 / / / / __ \/ __  / __ `/ __/ _ \   / /   |   / /     
/ /_/ / /_/ / /_/ / /_/ / /_/  __/  / /___/   / /___   
\____/ .___/\__,_/\__,_/\__/\___/  /_____/_/|_\____/   
    /_/                                                

EOF
}
set -e
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
CM='\xE2\x9C\x94\033'
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
header_info
while true; do
  read -p "This Will Update All LXC Containers. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
clear
containers=$(pct list | tail -n +2 | cut -f1 -d' ')
function update_container() {
  container=$1
  clear
  header_info
  name=$(pct exec "$container" hostname)
  echo -e "${BL}[Info]${GN} Updating ${BL}$container${CL} : ${GN}$name${CL} \n"
  os=$(pct config "$container" | awk '/^ostype/ {print $2}')
  case "$os" in
    alpine)  pct exec "$container" -- ash -c "apk update && apk upgrade" ;;
    archlinux)  pct exec "$container" -- bash -c "pacman -Syyu --noconfirm";;
    fedora|rocky|centos|alma)  pct exec "$container" -- bash -c "dnf -y update && dnf -y upgrade" ;;
    ubuntu|debian|devuan)  pct exec "$container" -- bash -c "apt-get update && apt-get -y upgrade" ;;
  esac
}
header_info
read -p "Skip stopped containers? [y/N]" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  skip=no
else
  skip=yes
fi
for container in $containers; do
  status=$(pct status $container)
  if [ "$skip" == "no" ] && [ "$status" == "status: stopped" ]; then
      echo -e "${BL}[Info]${GN} Starting${BL} $container ${CL} \n"
      pct start $container
      echo -e "${BL}[Info]${GN} Waiting For${BL} $container${CL}${GN} To Start ${CL} \n"
      sleep 5
      update_container $container
      echo -e "${BL}[Info]${GN} Shutting down${BL} $container ${CL} \n"
      pct shutdown $container &
    elif [ "$status" == "status: running" ]; then
      update_container $container
  fi
done
wait
rm -rf temp
header_info
echo -e "${GN} Finished, All Containers Updated. ${CL} \n"
