## Home Assistant Container Update ##

In the homeassistant lxc console run `nano upha.sh`
it will open a new file, copy and paste the Stable Branch (change TZ)
Save and exit the text editor with "Ctrl+O", "Enter" and "Ctrl+X"
To update HA, run `bash upha.sh` from the console

Stable Branch
```
### upha.sh ###
#!/bin/bash

echo -e "\e[1;33m Pulling New Stable Version... \e[0m"
docker pull homeassistant/home-assistant:stable
echo -e "\e[1;33m Stopping Home Assistant... \e[0m"
docker stop homeassistant
echo -e "\e[1;33m Removing Home Assistant... \e[0m"
docker rm homeassistant
echo -e "\e[1;33m Starting Home Assistant... \e[0m"
docker run -d --name homeassistant --restart unless-stopped -v hass_config:/config -e TZ=US/Eastern --net=host homeassistant/home-assistant:stable
echo -e "\e[1;33m Removing Old Image... \e[0m"
docker image prune -f
echo -e "\e[1;33m Finished Update! \e[0m"
```

Beta Branch
```
### uphabeta.sh ###
#!/bin/bash

echo -e "\e[1;33m Pulling New Beta Version... \e[0m"
docker pull homeassistant/home-assistant:beta
echo -e "\e[1;33m Stopping Home Assistant... \e[0m"
docker stop homeassistant
echo -e "\e[1;33m Removing Home Assistant... \e[0m"
docker rm homeassistant
echo -e "\e[1;33m Starting Home Assistant... \e[0m"
docker run -d --name homeassistant --restart unless-stopped -v hass_config:/config -e TZ=US/Eastern --net=host homeassistant/home-assistant:beta
echo -e "\e[1;33m Removing Old Image... \e[0m"
docker image prune -f
echo -e "\e[1;33m Finished Update! \e[0m"
```

Development Branch
```
### uphadev.sh ###
#!/bin/bash

echo -e "\e[1;33m Pulling New Dev Version... \e[0m"
docker pull homeassistant/home-assistant:dev
echo -e "\e[1;33m Stopping Home Assistant... \e[0m"
docker stop homeassistant
echo -e "\e[1;33m Removing Home Assistant... \e[0m"
docker rm homeassistant
echo -e "\e[1;33m Starting Home Assistant... \e[0m"
docker run -d --name homeassistant --restart unless-stopped -v hass_config:/config -e TZ=US/Eastern --net=host homeassistant/home-assistant:dev
echo -e "\e[1;33m Removing Old Image... \e[0m"
docker image prune -f
echo -e "\e[1;33m Finished Update! \e[0m"
```
