#!/usr/bin/env bash
if [ "$VERBOSE" == "yes" ]; then set -x;  STD=""; fi
if [ "$VERBOSE" != "yes" ]; then STD="silent"; fi
silent() { "$@" > /dev/null 2>&1; }
if [ "$DISABLEIPV6" == "yes" ]; then echo "net.ipv6.conf.all.disable_ipv6 = 1" >>/etc/sysctl.conf; $STD sysctl -p; fi
YW=$(echo "\033[33m")
RD=$(echo "\033[01;31m")
BL=$(echo "\033[36m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
RETRY_NUM=10
RETRY_EVERY=3
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR="\\r\\033[K"
HOLD="-"
set -Eeuo pipefail
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
function error_handler() {
  local exit_code="$?"
  local line_number="$1"
  local command="$2"
  local error_message="${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}: while executing command ${YW}$command${CL}"
  echo -e "\n$error_message\n"
}

function msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

function msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

msg_info "Setting up Container OS "
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
for ((i=RETRY_NUM; i>0; i--)); do
  if [ "$(hostname -I)" != "" ]; then
    break
  fi
  echo 1>&2 -en "${CROSS}${RD} No Network! "
  sleep $RETRY_EVERY
done
if [ "$(hostname -I)" = "" ]; then
  echo 1>&2 -e "\n${CROSS}${RD} No Network After $RETRY_NUM Tries${CL}"
  echo -e " 🖧  Check Network Settings"
  exit 1
fi
msg_ok "Set up Container OS"
msg_ok "Network Connected: ${BL}$(hostname -I)"

set +e
if nc -zw1 8.8.8.8 443; then msg_ok "Internet Connected"; else
  msg_error "Internet NOT Connected"
    read -r -p "Would you like to continue anyway? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
      echo -e " ⚠️  ${RD}Expect Issues Without Internet${CL}"
    else
      echo -e " 🖧  Check Network Settings"
      exit 1
    fi
fi
RESOLVEDIP=$(nslookup "github.com" | awk -F':' '/^Address: / { matched = 1 } matched { print $2}' | xargs)
if [[ -z "$RESOLVEDIP" ]]; then msg_error "DNS Lookup Failure"; else msg_ok "DNS Resolved github.com to ${BL}$RESOLVEDIP${CL}"; fi
set -e

msg_info "Updating Container OS"
$STD apt-get update
$STD apt-get -y upgrade
msg_ok "Updated Container OS"

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Installed Dependencies"

msg_info "Installing runlike"
$STD apt-get install -y python3-pip
$STD pip3 install runlike
msg_ok "Installed runlike"

get_latest_release() {
  curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
}

DOCKER_LATEST_VERSION=$(get_latest_release "moby/moby")
CORE_LATEST_VERSION=$(get_latest_release "home-assistant/core")
PORTAINER_LATEST_VERSION=$(get_latest_release "portainer/portainer")

msg_info "Installing Docker $DOCKER_LATEST_VERSION"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
if [ "$ST" == "yes" ]; then
VER=$(curl -s https://api.github.com/repos/containers/fuse-overlayfs/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
cd /usr/local/bin
curl -sSL -o fuse-overlayfs https://github.com/containers/fuse-overlayfs/releases/download/$VER/fuse-overlayfs-x86_64
chmod 755 /usr/local/bin/fuse-overlayfs
cd ~
echo -e '{\n  "storage-driver": "fuse-overlayfs",\n  "log-driver": "journald"\n}' > /etc/docker/daemon.json
else
echo -e '{\n  "log-driver": "journald"\n}' > /etc/docker/daemon.json
fi
$STD sh <(curl -sSL https://get.docker.com)
msg_ok "Installed Docker $DOCKER_LATEST_VERSION"

msg_info "Pulling Portainer $PORTAINER_LATEST_VERSION Image"
$STD docker pull portainer/portainer-ce:latest
msg_ok "Pulled Portainer $PORTAINER_LATEST_VERSION Image"

msg_info "Installing Portainer $PORTAINER_LATEST_VERSION"
$STD docker volume create portainer_data
$STD docker run -d \
  -p 8000:8000 \
  -p 9000:9000 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
msg_ok "Installed Portainer $PORTAINER_LATEST_VERSION"

msg_info "Pulling Home Assistant $CORE_LATEST_VERSION Image"
$STD docker pull homeassistant/home-assistant:stable
msg_ok "Pulled Home Assistant $CORE_LATEST_VERSION Image"

msg_info "Installing Home Assistant $CORE_LATEST_VERSION"
$STD docker volume create hass_config
$STD docker run -d \
  --name homeassistant \
  --privileged \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /dev:/dev \
  -v hass_config:/config \
  -v /etc/localtime:/etc/localtime:ro \
  --net=host \
  homeassistant/home-assistant:stable
  mkdir /root/hass_config
msg_ok "Installed Home Assistant $CORE_LATEST_VERSION"

echo "export TERM='xterm-256color'" >>/root/.bashrc
if ! getent shadow root | grep -q "^root:[^\!*]"; then
  msg_info "Customizing Container"
if [ "$PCT_OSTYPE" == "debian" ]; then rm -rf /etc/motd /etc/update-motd.d/10-uname; else chmod -x /etc/update-motd.d/*; fi
  touch ~/.hushlogin
  GETTY_OVERRIDE="/etc/systemd/system/container-getty@1.service.d/override.conf"
  mkdir -p $(dirname $GETTY_OVERRIDE)
  cat <<EOF >$GETTY_OVERRIDE
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM
EOF
  systemctl daemon-reload
  systemctl restart $(basename $(dirname $GETTY_OVERRIDE) | sed 's/\.d//')
  msg_ok "Customized Container"
fi
if [[ "${SSH_ROOT}" == "yes" ]]; then sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config; systemctl restart sshd; fi

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
