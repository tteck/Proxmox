#!/bin/bash
set -e
BL=$(echo "\033[36m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
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

    ______      ______          _   _ _    _ _____    _____   ____   _____ _  ________ _____    _____ __  __          _____ ______  _____
  / ____| |    |  ____|   /\   | \ | | |  | |  __ \  |  __ \ / __ \ / ____| |/ /  ____|  __ \  |_   _|  \/  |   /\   / ____|  ____|/ ____|
 | |    | |    | |__     /  \  |  \| | |  | | |__) | | |  | | |  | | |    |   /| |__  | |__) |   | | | \  / |  /  \ | |  __| |__  | (___
 | |    | |    |  __|   / /\ \ |     | |  | |  ___/  | |  | | |  | | |    |  < |  __| |  _  /    | | | |\/| | / /\ \| | |_ |  __|  \___ \
 | |____| |____| |____ / ____ \| |\  | |__| | |      | |__| | |__| | |____|   \| |____| | \ \   _| |_| |  | |/ ____ \ |__| | |____ ____) |
  \_____|______|______/_/    \_\_| \_|\____/|_|      |_____/ \____/ \_____|_|\_\______|_|  \_\ |_____|_|  |_/_/    \_\_____|______|_____/


${CL}"
}
header_info

containers=$(pct list | tail -n +2 | cut -f1 -d' ')

function cleanup_container() {
  container=$1
  clear
  header_info
  echo -e "${BL}[Info]${GN} Cleaning up ${BL} $container ${CL} \n"
  pct config "$container" > temp
  os=$(awk '/^ostype/' temp | cut -d' ' -f2)
  echo "Checking for docker"
  if [ "$os" == "alpine" ]
      then

            if  test "$(pct exec "$container" -- ash -c "which docker 2>/dev/null")"
            then
                pct exec "$container" -- ash -c "docker image prune -af"
            else
                echo "Docker not installed. Skipping..."
            fi
      else
            if  test "$(pct exec "$container" -- bash -c "which docker 2>/dev/null")"
            then
                pct exec "$container" -- bash -c "docker image prune -af"
            else
                echo "Docker not installed. Skipping..."
            fi
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
  status=$(pct status "$container")
 if [ "$skip" == "no" ]; then
  if [ "$status" == "status: stopped" ]; then
    echo -e "${BL}[Info]${GN} Starting${BL} $container ${CL} \n"
    pct start "$container"
    echo -e "${BL}[Info]${GN} Waiting For${BL} $container${CL}${GN} To Start ${CL} \n"
    sleep 5
    cleanup_container "$container"
    echo -e "${BL}[Info]${GN} Shutting down${BL} $container ${CL} \n"
    pct shutdown "$container" &
  elif [ "$status" == "status: running" ]; then
    cleanup_container "$container"
  fi
 fi
 if [ "$skip" == "yes" ]; then
  if [ "$status" == "status: running" ]; then
    cleanup_container "$container"
  fi
 fi
done; wait

rm temp
echo -e "${GN} Finished, Cleaned up all containers. ${CL} \n"