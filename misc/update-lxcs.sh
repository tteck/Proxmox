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
  clear
  header_info
  echo -e "${BL}[Info]${GN} Updating${BL} $container ${CL} \n"
  pct config $container > temp
  os=`awk '/^ostype/' temp | cut -d' ' -f2`
  if [ "$os" == "alpine" ]
  then
        pct exec $container -- ash -c "apk update && apk upgrade"
  else
        pct exec $container -- bash -c "apt update && apt upgrade -y && apt autoremove -y"
  fi
}
read -p "Skip stopped containers? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    skip=no
else
    skip=yes
fi

for container in $containers
do
  status=`pct status $container`
 if [ "$skip" == "no" ]; then 
  if [ "$status" == "status: stopped" ]; then
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
 fi 
 if [ "$skip" == "yes" ]; then
  if [ "$status" == "status: running" ]; then
    update_container $container
  fi
 fi 
done; wait

rm temp
echo -e "${GN} Finished, All Containers Updated. ${CL} \n"
