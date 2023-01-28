#!/usr/bin/env bash
silent() { "$@" > /dev/null 2>&1; }
if [ "$VERBOSE" == "yes" ]; then set -x; fi
if [ "$DISABLEIPV6" == "yes" ]; then echo "net.ipv6.conf.all.disable_ipv6 = 1" >>/etc/sysctl.conf; $STD sysctl -p; fi
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

OPTIONS_PATH='/options.conf'
cat >$OPTIONS_PATH <<'EOF'
IPv4dev=eth0
install_user=root
VPN=wireguard
pivpnNET=10.6.0.0
subnetClass=24
ALLOWED_IPS="0.0.0.0/0, ::0/0"
pivpnMTU=1420
pivpnPORT=51820
pivpnDNS1=1.1.1.1
pivpnDNS2=8.8.8.8
pivpnHOST=
pivpnPERSISTENTKEEPALIVE=25
UNATTUPG=1
EOF

msg_info "Updating Container OS"
$STD apt-get update
$STD apt-get -y upgrade
msg_ok "Updated Container OS"

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y gunicorn
msg_ok "Installed Dependencies"

msg_info "Installing WireGuard (using pivpn.io)"
$STD bash <(curl -fsSL https://install.pivpn.io) --unattended options.conf
msg_ok "Installed WireGuard"

PASS=$(grep -w "root" /etc/shadow | cut -b6)
echo "export TERM='xterm-256color'" >>/root/.bashrc
if [[ $PASS != $ ]]; then
  msg_info "Customizing Container"
  rm /etc/motd
  rm /etc/update-motd.d/10-uname
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
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
