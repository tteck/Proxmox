#!/usr/bin/env bash
YW=`echo "\033[33m"`
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
RETRY_NUM=10
RETRY_EVERY=3
NUM=$RETRY_NUM
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR="\\r\\033[K"
HOLD="-"
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR

function error_exit() {
  trap - ERR
  local reason="Unknown failure occurred."
  local msg="${1:-$reason}"
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  exit $EXIT
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_info "Setting up Container OS "
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
while [ "$(hostname -I)" = "" ]; do
  1>&2 echo -en "${CROSS}${RD}  No Network! "
  sleep $RETRY_EVERY
  ((NUM--))
  if [ $NUM -eq 0 ]
  then
    1>&2 echo -e "${CROSS}${RD}  No Network After $RETRY_NUM Tries${CL}"    
    exit 1
  fi
done
msg_ok "Set up Container OS"
msg_ok "Network Connected: ${BL}$(hostname -I)"

msg_info "Updating Container OS"
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null
msg_ok "Updated Container OS"

msg_info "Installing Dependencies"
apt-get install -y curl &>/dev/null
apt-get install -y sudo &>/dev/null
apt-get install -y cifs-utils &>/dev/null
msg_ok "Installed Dependencies"

msg_info "Installing Motion"
 apt-get install motion -y &>/dev/null
 systemctl stop motion &>/dev/null
 systemctl disable motion &>/dev/null
msg_ok "Installed Motion"

msg_info "Installing FFmpeg"
 apt-get install ffmpeg v4l-utils -y &>/dev/null
msg_ok "Installed FFmpeg"

msg_info "Installing Python"
 apt-get update &>/dev/null
 apt-get install python2 -y &>/dev/null
 curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py &>/dev/null
 python2 get-pip.py &>/dev/null
 apt-get install libffi-dev libzbar-dev libzbar0 -y &>/dev/null
 apt-get install python2-dev libssl-dev libcurl4-openssl-dev libjpeg-dev -y &>/dev/null
 msg_ok "Installed Python"
 
msg_info "Installing MotionEye"
 apt-get update &>/dev/null
 sudo pip install motioneye &>/dev/null
 mkdir -p /etc/motioneye
 cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf
 mkdir -p /var/lib/motioneye
msg_ok "Installed MotionEye"

msg_info "Creating Service" 
 cp /usr/local/share/motioneye/extra/motioneye.systemd-unit-local /etc/systemd/system/motioneye.service &>/dev/null
 systemctl enable motioneye &>/dev/null
 systemctl start motioneye 
msg_ok "Created Service" 

PASS=$(grep -w "root" /etc/shadow | cut -b6);
  if [[ $PASS != $ ]]; then
msg_info "Customizing Container"
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
msg_ok "Customized Container"
  fi
  
msg_info "Cleaning up"
apt-get autoremove >/dev/null
apt-get autoclean >/dev/null
rm -rf /var/{cache,log}/* /var/lib/apt/lists/*
msg_ok "Cleaned"
