#!/usr/bin/env bash
set -e
echo "Installing Python 3.10.8"
pyenv install 3.10.8 &>/dev/null
pyenv global 3.10.8
echo "Installed Python 3.10.8"
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
echo "Installing ESPHome"
pip3 install --pre esphome &>/dev/null
cat <<EOF >/etc/systemd/system/esphomeDashboard.service
[Unit]
Description=ESPHome Dashboard
After=network.target
[Service]
ExecStart=/root/.pyenv/versions/3.10.8/bin/esphome /root/.pyenv/versions/3.10.8/lib/python3.10/site-packages/esphome_dashboard dashboard
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now esphomeDashboard &>/dev/null
echo "Installed ESPHome"
fi
