#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
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

msg "Setting up container OS..."
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
apt-get -y purge openssh-{client,server} >/dev/null
apt-get autoremove >/dev/null

msg "Updating container OS..."
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null

msg "Installing prerequisites..."
apt-get -qqy install \
    curl \
    sudo \
    unzip &>/dev/null

msg "Installing zwavejs2mqtt..."
cd ~
mkdir zwavejs2mqtt
cd zwavejs2mqtt
curl -s https://api.github.com/repos/zwave-js/zwavejs2mqtt/releases/latest  \
| grep "browser_download_url.*zip" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i - &>/dev/null
unzip zwavejs2mqtt-v*.zip &>/dev/null
./zwavejs2mqtt

msg "Customizing container..."
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

msg "Cleanup..."
rm -rf /zwavejs2mqtt_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*