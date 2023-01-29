#!/bin/bash
function header_info {
  cat <<"EOF"
   ________                    __   _  ________
  / ____/ /__  ____ _____     / /  | |/ / ____/
 / /   / / _ \/ __ `/ __ \   / /   |   / /     
/ /___/ /  __/ /_/ / / / /  / /___/   / /___   
\____/_/\___/\__,_/_/ /_/  /_____/_/|_\____/   
                                               
EOF
}
set -e
YW=$(echo "\033[33m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
CM='\xE2\x9C\x94\033'
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
clear
header_info
echo -e "\n ${RD} USE AT YOUR OWN RISK. Deleting logs/cache may result in some apps/services broken!${CL} \n"
while true; do
  read -p "This Will Clean logs, cache and update apt lists on all LXC Containers. Proceed(y/n)?" yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done
clear
containers=$(pct list | tail -n +2 | cut -f1 -d' ')
function clean_container() {
  container=$1
  clear
  header_info
  name=`pct exec $container hostname`
  echo -e "${BL}[Info]${GN} Cleaning ${name} ${CL} \n"
  pct exec $container -- bash -c "apt-get -y --purge autoremove && apt-get -y autoclean && bash <(curl -fsSL https://github.com/tteck/Proxmox/raw/main/misc/clean.sh) && rm -rf /var/lib/apt/lists/* && apt-get update"
}
read -p "Skip stopped containers? [y/N]" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  skip=no
else
  skip=yes
fi

for container in $containers; do
  status=$(pct status $container)
  if [ "$skip" == "no" ]; then
    if [ "$status" == "status: stopped" ]; then
      echo -e "${BL}[Info]${GN} Starting${BL} $container ${CL} \n"
      pct start $container
      echo -e "${BL}[Info]${GN} Waiting For${BL} $container${CL}${GN} To Start ${CL} \n"
      sleep 5
      clean_container $container
      echo -e "${BL}[Info]${GN} Shutting down${BL} $container ${CL} \n"
      pct shutdown $container &
    elif [ "$status" == "status: running" ]; then
      clean_container $container
    fi
  fi
  if [ "$skip" == "yes" ]; then
    if [ "$status" == "status: running" ]; then
      clean_container $container
    fi
  fi
done
wait
clear
header_info
echo -e "${GN} Finished, Containers Cleaned. ${CL} \n"
