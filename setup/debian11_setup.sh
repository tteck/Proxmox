#!/usr/bin/env bash

# Setup script environment
set -o errexit  #Exit immediately if a pipeline returns a non-zero status
set -o errtrace #Trap ERR from shell functions, command substitutions, and commands from subshell
set -o nounset  #Treat unset variables as an error
set -o pipefail #Pipe will exit with last non-zero status if applicable
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
CROSS='\033[1;31m\xE2\x9D\x8C\033[0m'
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

msg "Setting up container OS..."
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
sleep 3
while [ "$(hostname -I)" = "" ]; do
  echo -e "${CROSS} \e[1;31m No network: \e[0m $(date)"
  sleep 3
done
  echo -e "${CHECKMARK} \e[1;92m Network connected: \e[0m $(hostname -I)"

echo -e "${CHECKMARK} \e[1;92m Updating Container OS... \e[0m"
msg "Updating container OS..."
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null

# Install prerequisites
msg "Installing prerequisites..."
apt-get update &>/dev/null
apt-get -qqy install \
    curl \
    sudo &>/dev/null

# Customize container
msg "Customizing container..."
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
rm -rf /debian11_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
