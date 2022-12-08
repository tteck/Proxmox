#!/usr/bin/env bash
if command -v pveversion >/dev/null 2>&1; then echo -e "⚠️  Can't Install on Proxmox "; exit; fi
set -e
DIR=/root/.pyenv/versions/3.10.8
if [ -d "$DIR" ]; then
    echo "Python 3.10.8 is already installed, moving on..."
else
echo "Installing Python 3.10.8"
pyenv install 3.10.8 &>/dev/null
pyenv global 3.10.8
echo "Installed Python 3.10.8"
fi
read -r -p "Would you like to install Home Assistant Beta? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
  HA="Y"
fi
if [[ $HA == "Y" ]]; then
echo "Installing Home Assistant Beta"
cat <<EOF >/etc/systemd/system/homeassistant.service
[Unit]
Description=Home Assistant
After=network-online.target
[Service]
Type=simple
WorkingDirectory=/root/.homeassistant
ExecStart=/srv/homeassistant/bin/hass -c "/root/.homeassistant"
RestartForceExitStatus=100
[Install]
WantedBy=multi-user.target
EOF
mkdir /srv/homeassistant
cd /srv/homeassistant
python3 -m venv .
source bin/activate
python3 -m pip install wheel &>/dev/null
pip3 install --upgrade pip &>/dev/null
pip3 install psycopg2-binary &>/dev/null
pip3 install --pre homeassistant &>/dev/null
systemctl enable homeassistant &>/dev/null
echo "Installed Home Assistant Beta"
echo -e " Go to $(hostname -I | awk '{print $1}'):8123"
hass
fi

read -r -p "Would you like to install ESPHome Beta? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
  ESP="Y"
fi
if [[ $ESP == "Y" ]]; then
echo "Installing ESPHome Beta"
mkdir /srv/esphome
cd /srv/esphome
python3 -m venv .
source bin/activate
python3 -m pip install wheel &>/dev/null
pip3 install --upgrade pip &>/dev/null
pip3 install --pre esphome &>/dev/null
cat <<EOF >/srv/esphome/start.sh
#!/bin/bash
source /srv/esphome/bin/activate
esphome dashboard /srv/esphome/
EOF
chmod +x start.sh
cat <<EOF >/etc/systemd/system/esphomedashboard.service
[Unit]
Description=ESPHome Dashboard Service
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/srv/esphome
ExecStart=/srv/esphome/start.sh
RestartSec=30
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now esphomedashboard &>/dev/null
echo "Installed ESPHome Beta"
echo -e " Go to $(hostname -I | awk '{print $1}'):6052"
fi

read -r -p "Would you like to install Matter-Server? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
  MTR="Y"
fi
if [[ $MTR == "Y" ]]; then
echo "Installing Matter Server"
apt-get install -y \
libcairo2-dev \
libjpeg62-turbo-dev \
libgirepository1.0-dev \
libpango1.0-dev \
libgif-dev \
g++ &>/dev/null
python3 -m pip install wheel 
pip3 install --upgrade pip 
pip install python-matter-server[server]
echo "Installed Matter Server"
echo -e "Start server > python -m matter_server.server"
fi
echo -e "\nFinished\n"
