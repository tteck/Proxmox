#!/usr/bin/env bash

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

msg "Setting up Container OS..."
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
apt-get -y purge openssh-{client,server} >/dev/null
apt-get autoremove >/dev/null

msg "Updating Container OS..."
apt-get update >/dev/null
apt-get -qqy upgrade &>/dev/null

msg "Installing Prerequisites..."
apt-get -qqy install \
    curl \
    sudo &>/dev/null

msg "Installing Dependencies"
sudo apt-get install -y python3 \
python3-dev \
python3-venv \
python3-pip \
libffi-dev \
libssl-dev \
libjpeg-dev \
zlib1g-dev \
autoconf build-essential \
libopenjp2-7 \
libtiff5 tzdata &>/dev/null

sudo useradd -rm homeassistant &>/dev/null
sudo mkdir /srv/homeassistant &>/dev/null
sudo chown homeassistant:homeassistant /srv/homeassistant &>/dev/null
sudo -u homeassistant -H -s &>/dev/null
cd /srv/homeassistant &>/dev/null

msg "Installing VENV"
python3.8 -m venv . &>/dev/null
source bin/activate &>/dev/null

msg "Installing Wheel"
python3 -m pip install wheel

msg "Installing Home Assistant"
pip3 install homeassistant

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
rm -rf /ha_venv_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*