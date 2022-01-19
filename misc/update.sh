#!/bin/bash

echo -e "\e[1;33m Pulling New Stable Version... \e[0m"
docker pull homeassistant/home-assistant:stable
echo -e "\e[1;33m Stopping Home Assistant... \e[0m"
docker stop homeassistant
echo -e "\e[1;33m Removing Home Assistant... \e[0m"
docker rm homeassistant
echo -e "\e[1;33m Starting Home Assistant... \e[0m"
docker run -d \
  --name homeassistant \
  --privileged \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /dev:/dev \
  -v hass_config:/config \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro\
  --net=host \
  homeassistant/home-assistant:stable &>/dev/null
echo -e "\e[1;33m Removing Old Image... \e[0m"
docker image prune -f
echo -e "\e[1;33m Finished Update! \e[0m"