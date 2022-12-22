#!/usr/bin/env bash
if [ "$VERBOSE" == "yes" ]; then set -x; fi
YW=$(echo "\033[33m")
RD=$(echo "\033[01;31m")
BL=$(echo "\033[36m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
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

function msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

msg_info "Setting up Container OS "
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
while [ "$(hostname -I)" = "" ]; do
  echo 1>&2 -en "${CROSS}${RD} No Network! "
  sleep $RETRY_EVERY
  ((NUM--))
  if [ $NUM -eq 0 ]; then
    echo 1>&2 -e "${CROSS}${RD} No Network After $RETRY_NUM Tries${CL}"
    exit 1
  fi
done
msg_ok "Set up Container OS"
msg_ok "Network Connected: ${BL}$(hostname -I)"

set +e
alias die=''
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
if [[ -z "$RESOLVEDIP" ]]; then msg_error "DNS Lookup Failure"; else msg_ok "DNS Resolved github.com to $RESOLVEDIP"; fi
alias die='EXIT=$? LINE=$LINENO error_exit'
set -e

msg_info "Updating Container OS"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated Container OS"

msg_info "Installing Dependencies"
apt-get install -y curl &>/dev/null
apt-get install -y sudo &>/dev/null
apt-get install -y apt-transport-https &>/dev/null
apt-get install -y software-properties-common &>/dev/null
msg_ok "Installed Dependencies"

if [[ -z "$(grep -w "100000" /proc/self/uid_map)" ]]; then
  msg_info "Setting Up Hardware Acceleration"
  apt-get -y install \
    va-driver-all \
    ocl-icd-libopencl1 \
    beignet-opencl-icd &>/dev/null

  /bin/chgrp video /dev/dri
  /bin/chmod 755 /dev/dri
  /bin/chmod 660 /dev/dri/*
  msg_ok "Set Up Hardware Acceleration"
fi

msg_info "Setting Up Jellyfin Repository"
sudo add-apt-repository universe -y &>/dev/null
wget -q -O - https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | sudo apt-key add - &>/dev/null
echo "deb [arch=$(dpkg --print-architecture)] https://repo.jellyfin.org/ubuntu $(lsb_release -c -s) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list &>/dev/null
msg_ok "Set Up Jellyfin Repository"

msg_info "Installing Jellyfin"
apt-get update &>/dev/null
sudo apt install jellyfin-server -y &>/dev/null
apt install jellyfin-ffmpeg -y &>/dev/null
msg_ok "Installed Jellyfin"

msg_info "Creating Service"
cat <<'EOF' >/lib/systemd/system/jellyfin.service
[Unit]
Description = Jellyfin Media Server
After = network.target
[Service]
Type = simple
EnvironmentFile = /etc/default/jellyfin
User = root
ExecStart = /usr/bin/jellyfin
Restart = on-failure
TimeoutSec = 15
[Install]
WantedBy = multi-user.target
EOF
ln -s /usr/share/jellyfin/web/ /usr/lib/jellyfin/bin/jellyfin-web
msg_ok "Created Service"

PASS=$(grep -w "root" /etc/shadow | cut -b6)
if [[ $PASS != $ ]]; then
  msg_info "Customizing Container"
  chmod -x /etc/update-motd.d/*
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
if [[ "${SSH_ROOT}" == "yes" ]]; then
  sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
  systemctl restart sshd
fi

msg_info "Cleaning up"
apt-get autoremove >/dev/null
apt-get autoclean >/dev/null
msg_ok "Cleaned"
