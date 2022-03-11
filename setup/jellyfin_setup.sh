#!/usr/bin/env bash

set -o errexit 
set -o errtrace
set -o nounset 
set -o pipefail 
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
CROSS='\033[1;31m\xE2\x9D\x8C\033[0m'
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
RETRY_NUM=10
RETRY_EVERY=3
NUM=$RETRY_NUM
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
while [ "$(hostname -I)" = "" ]; do
  1>&2 echo -e "${CROSS} \e[1;31m No Network: \e[0m $(date)"
  sleep $RETRY_EVERY
  ((NUM--))
  if [ $NUM -eq 0 ]
  then
    1>&2 echo -e "${CROSS} \e[1;31m No Network After $RETRY_NUM Tries \e[0m"
    exit 1
  fi
done
  echo -e "${CHECKMARK} \e[1;92m Network Connected: \e[0m $(hostname -I)"

echo -e "${CHECKMARK} \e[1;92m Updating Container OS... \e[0m"
apt-get update &>/dev/null
apt-get -qqy upgrade &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Dependencies... \e[0m"
 apt-get update &>/dev/null
 apt-get -qqy install \
     curl \
     sudo &>/dev/null
 sudo apt install apt-transport-https -y &>/dev/null
 sudo apt-get install software-properties-common -y &>/dev/null
 
echo -e "${CHECKMARK} \e[1;92m Setting Up Jellyfin Repository... \e[0m"
sudo add-apt-repository universe -y &>/dev/null
wget -q -O - https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | sudo apt-key add - &>/dev/null
echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/ubuntu $( lsb_release -c -s ) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Installing Jellyfin... \e[0m"
apt-get update &>/dev/null
sudo apt install jellyfin-server -y &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Creating Jellyfin Service... \e[0m"
cat << 'EOF' > /lib/systemd/system/jellyfin.service
[Unit]
Description = Jellyfin Media Server
After = network.target

[Service]
Type = simple
EnvironmentFile = /etc/default/jellyfin
User = root
ExecStart = /usr/bin/jellyfin ${JELLYFIN_WEB_OPT} ${JELLYFIN_RESTART_OPT} ${JELLYFIN_FFMPEG_OPT} ${JELL>
Restart = on-failure
TimeoutSec = 15

[Install]
WantedBy = multi-user.target
EOF

ln -s /usr/share/jellyfin/web/ /usr/lib/jellyfin/bin/jellyfin-web

echo -e "${CHECKMARK} \e[1;92m Customizing Container... \e[0m"
chmod -x /etc/update-motd.d/*
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
rm -rf /jellyfin_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
