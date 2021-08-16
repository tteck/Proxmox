#!/usr/bin/env bash

# Setup script environment
set -o errexit  #Exit immediately if a pipeline returns a non-zero status
set -o errtrace #Trap ERR from shell functions, command substitutions, and commands from subshell
set -o nounset  #Treat unset variables as an error
set -o pipefail #Pipe will exit with last non-zero status if applicable
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
trap 'die "Script interrupted."' INT

function error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR:LXC] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

# Prepare container OS
msg "Setting up Container OS..."
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
apt-get -y purge openssh-{client,server} >/dev/null
apt-get autoremove >/dev/null

# Update container OS
msg "Updating Container OS..."
apt-get update >/dev/null
apt-get upgrade &>/dev/null

# Install prerequisites
msg "Installing Prerequisites..."
apt-get -qqy install \
    curl \
    sudo &>/dev/null
    # Setup Node.js repository
    msg "Setting up Node.js Repository..."
    sudo curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - &>/dev/null
    # Install Node.js;
    msg "Installing Node.js..."
    sudo apt-get install -y nodejs git make g++ gcc &>/dev/null
    # Clone Zigbee2MQTT repository
    msg "Setting up Zigbee2MQTT Repository..."
    sudo git clone https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt &>/dev/null
    # Install zigbee2mqtt
    msg "Installing Zigbee2MQTT..."
    cd /opt/zigbee2mqtt &>/dev/null
    npm ci --production &>/dev/null

echo "Creating service file zigbee2mqtt.service"
service_path="/etc/systemd/system/zigbee2mqtt.service"

echo "[Unit]
Description=zigbee2mqtt
After=network.target
[Service]
ExecStart=/usr/bin/npm start
WorkingDirectory=/opt/zigbee2mqtt
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root
[Install]
WantedBy=multi-user.target" > $service_path

# Customize container
msg "Customizing Container..."
rm /etc/motd # Remove message of the day after login
rm /etc/update-motd.d/10-uname # Remove kernel information after login
touch ~/.hushlogin # Remove 'Last login: ' and mail notification after login
GETTY_OVERRIDE="/etc/systemd/system/container-getty@1.service.d/override.conf"
mkdir -p $(dirname $GETTY_OVERRIDE)
cat << EOF > $GETTY_OVERRIDE
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM
EOF
systemctl daemon-reload
systemctl restart $(basename $(dirname $GETTY_OVERRIDE) | sed 's/\.d//')

# Cleanup container
msg "Cleanup..."
rm -rf /pve7_zigbee2mqtt_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
