#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
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

echo -e "${CHECKMARK} \e[1;92m Setting up Container OS... \e[0m"
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
apt-get -y purge openssh-{client,server} >/dev/null
apt-get autoremove >/dev/null

echo -e "${CHECKMARK} \e[1;92m Updating Container OS... \e[0m"
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Dependencies... \e[0m"
apt-get -qqy install \
    curl \
    runc &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Podman... \e[0m"
apt-get -y install podman &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Pulling Home Assistant Image...\e[0m"
podman pull docker.io/homeassistant/home-assistant:stable &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Home Assistant... \e[0m"
podman volume create hass_config >/dev/null
podman run -d \
  --name homeassistant \
  --restart=always \
  -v /dev:/dev \
  -v hass_config:/config \
  -v /etc/localtime:/etc/localtime:ro \
  --net=host \
  homeassistant/home-assistant:stable &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Customizing LXC... \e[0m"
rm /etc/motd
rm /etc/update-motd.d/10-uname
touch ~/.hushlogin
GETTY_OVERRIDE="/etc/systemd/system/container-getty@1.service.d/override.conf"
mkdir -p $(dirname $GETTY_OVERRIDE)
cat << EOF > $GETTY_OVERRIDE
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM
EOF
systemctl daemon-reload
systemctl restart $(basename $(dirname $GETTY_OVERRIDE) | sed 's/\.d//')
podman generate systemd \
    --new --name homeassistant \
    > /etc/systemd/system/homeassistant.service 
systemctl enable homeassistant &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Cleanup... \e[0m"
rm -rf /podman_ha_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
