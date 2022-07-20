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
apt-get install -y runc &>/dev/null
msg_ok "Installed Dependencies"

msg_info "Installing Podman"
apt-get -y install podman &>/dev/null
msg_ok "Installed Podman"

msg_info "Pulling Yacht Image"
podman pull docker.io/selfhostedpro/yacht:latest &>/dev/null
msg_ok "Pulled Yacht Image"

msg_info "Installing Yacht"
podman volume create yacht >/dev/null
podman run -d \
  --privileged \
  --name yacht \
  --restart always \
  -v /var/run/podman/podman.sock:/var/run/docker.sock \
  -v yacht:/config \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -p 8000:8000 \
  selfhostedpro/yacht:latest &>/dev/null
msg_ok "Installed Yacht"

msg_info "Pulling Home Assistant Image"
podman pull docker.io/homeassistant/home-assistant:stable &>/dev/null
msg_ok "Pulled Home Assistant Image"

msg_info "Installing Home Assistant"
podman volume create hass_config >/dev/null
podman run -d \
  --privileged \
  --name homeassistant \
  --restart unless-stopped \
  -v /dev:/dev \
  -v hass_config:/config \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  --net=host \
  homeassistant/home-assistant:stable &>/dev/null
msg_ok "Installed Home Assistant"

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

podman generate systemd \
    --new --name homeassistant \
    > /etc/systemd/system/homeassistant.service 
systemctl enable homeassistant &>/dev/null

podman generate systemd \
    --new --name yacht \
    > /etc/systemd/system/yacht.service 
systemctl enable yacht &>/dev/null

msg_info "Cleaning up"
apt-get autoremove >/dev/null
apt-get autoclean >/dev/null
rm -rf /var/{cache,log}/* /var/lib/apt/lists/*
msg_ok "Cleaned"
