#!/bin/bash
set -e
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
while true; do
    read -p "This Will Update All LXC Containers. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
function header_info {
echo -e "${BL}
  _    _ _____  _____       _______ ______ 
 | |  | |  __ \|  __ \   /\|__   __|  ____|
 | |  | | |__) | |  | | /  \  | |  | |__   
 | |  | |  ___/| |  | |/ /\ \ | |  |  __|  
 | |__| | |    | |__| / ____ \| |  | |____ 
  \____/|_|    |_____/_/    \_\_|  |______|

${CL}"
}
header_info

containers=$(pct list | tail -n +2 | cut -f1 -d' ')

function update_container() {
  container=$1
  echo -e "${BL}[Info]${GN} Updating${BL} $container... ${CL}"
  # to chain commands within one exec we will need to wrap them in bash
  pct exec $container -- bash -c "apt update && apt upgrade -y && apt autoremove -y"
}

for container in $containers
do
  status=`pct status $container`
  if [ "$status" == "status: stopped" ]; then
    echo -e "${BL}[Info]${GN} Starting${BL} $container... ${CL}"
    pct start $container
    echo -e "${BL}[Info]${GN} Waiting For${BL} $container To Start... ${CL}"
    sleep 5
    update_container $container
    echo -e "${BL}[Info]${GN} Shutting down${BL} $container ${CL}"
    pct shutdown $container &
  elif [ "$status" == "status: running" ]; then
    update_container $container
  fi
done; wait
