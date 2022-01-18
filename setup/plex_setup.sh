#!/usr/bin/env bash

set -o errexit 
set -o errtrace
set -o nounset 
set -o pipefail 
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
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

echo -e "${CHECKMARK} \e[1;92m Installing Prerequisites... \e[0m"
apt-get -qqy install \
    curl \
    sudo \
    gnupg &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Downloading Plex Media Server... \e[0m"
wget https://downloads.plex.tv/plex-media-server-new/1.25.2.5319-c43dc0277/debian/plexmediaserver_1.25.2.5319-c43dc0277_amd64.deb &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Installing Plex Media Server... \e[0m"
sudo dpkg -i plexmediaserver_1.25.2.5319-c43dc0277_amd64.deb &>/dev/null

cat <<EOF > /etc/apt/sources.list.d/plexmediaserver.list
deb https://downloads.plex.tv/repo/deb/ public main
EOF

wget -q https://downloads.plex.tv/plex-keys/PlexSign.key -O - | sudo apt-key add - &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Customizing Container... \e[0m"
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
echo -e "${CHECKMARK} \e[1;92m Cleanup... \e[0m"
rm -rf /plex_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
