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

msg "Installing prerequisites..."
apt-get -qqy install \
    curl \
    sudo &>/dev/null

msg "Installing Node-Red..."
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-root --confirm-install --skip-pi

#msg "Installing Node..."
#sudo apt -y install nodejs npm &>/dev/null

#msg "Installing PM2..."
#npm install -g pm2 &>/dev/null 

#msg "Installing Node-RED..."
#npm install -g --unsafe-perm node-red &>/dev/null

#msg "Setting up PM2..."
#/usr/local/bin/pm2 start /usr/local/bin/node-red  &>/dev/null
#/usr/local/bin/pm2 save &>/dev/null
#/usr/local/bin/pm2 startup &>/dev/null

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

msg "Cleanup..."
rm -rf /node-red_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
