#!/usr/bin/env bash
if [ "$VERBOSE" == "yes" ]; then set -x; fi
AVX=$(grep -o -m1 'avx[^ ]*' /proc/cpuinfo)
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
silent() { "$@" > /dev/null 2>&1; }
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
$STD apt-get update
$STD apt-get -y upgrade
msg_ok "Updated Container OS"

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y gcc
$STD apt-get install -y g++
$STD apt-get install -y git
$STD apt-get install -y gnupg
$STD apt-get install -y make
$STD apt-get install -y zip
$STD apt-get install -y unzip
$STD apt-get install -y exiftool
$STD apt-get install -y ffmpeg
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
wget -qL https://deb.nodesource.com/setup_18.x
$STD bash setup_18.x
rm setup_18.x
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get -y install nodejs
msg_ok "Installed Node.js"

msg_info "Installing Golang (Patience)"
$STD wget https://golang.org/dl/go1.19.3.linux-amd64.tar.gz
$STD tar -xzf go1.19.3.linux-amd64.tar.gz -C /usr/local
$STD ln -s /usr/local/go/bin/go /usr/local/bin/go
$STD go install github.com/tianon/gosu@latest
$STD go install golang.org/x/tools/cmd/goimports@latest
$STD go install github.com/psampaz/go-mod-outdated@latest
$STD go install github.com/dsoprea/go-exif/v3/command/exif-read-tool@latest
$STD go install github.com/mikefarah/yq/v4@latest
$STD go install github.com/kyoh86/richgo@latest
cp /root/go/bin/* /usr/local/go/bin/
cp /usr/local/go/bin/richgo /usr/local/bin/richgo
cp /usr/local/go/bin/gosu /usr/local/sbin/gosu
chown root:root /usr/local/sbin/gosu
chmod 755 /usr/local/sbin/gosu
msg_ok "Installed Golang"

msg_info "Installing Tensorflow"
if [[ "$AVX" =~ avx2 ]]; then
 $STD wget https://dl.photoprism.org/tensorflow/linux/libtensorflow-linux-avx2-1.15.2.tar.gz
 $STD tar -C /usr/local -xzf libtensorflow-linux-avx2-1.15.2.tar.gz
elif [[ "$AVX" =~ avx ]]; then
 $STD wget https://dl.photoprism.org/tensorflow/linux/libtensorflow-linux-avx-1.15.2.tar.gz
 $STD tar -C /usr/local -xzf libtensorflow-linux-avx-1.15.2.tar.gz
else
 $STD wget https://dl.photoprism.org/tensorflow/linux/libtensorflow-linux-cpu-1.15.2.tar.gz
 $STD tar -C /usr/local -xzf libtensorflow-linux-cpu-1.15.2.tar.gz
fi
$STD ldconfig
msg_ok "Installed Tensorflow"

msg_info "Cloning PhotoPrism"
mkdir -p /opt/photoprism/bin
mkdir -p /var/lib/photoprism/storage
$STD git clone https://github.com/photoprism/photoprism.git
cd photoprism
$STD git checkout release
msg_ok "Cloned PhotoPrism"

msg_info "Building PhotoPrism (Patience)"
$STD make -B
$STD ./scripts/build.sh prod /opt/photoprism/bin/photoprism
$STD cp -r assets/ /opt/photoprism/
msg_ok "Built PhotoPrism"

env_path="/var/lib/photoprism/.env"
echo " 
PHOTOPRISM_AUTH_MODE='password'
PHOTOPRISM_ADMIN_PASSWORD='changeme'
PHOTOPRISM_HTTP_HOST='0.0.0.0'
PHOTOPRISM_HTTP_PORT='2342'
PHOTOPRISM_SITE_CAPTION='https://tteck.github.io/Proxmox/'
PHOTOPRISM_STORAGE_PATH='/var/lib/photoprism/storage'
PHOTOPRISM_ORIGINALS_PATH='/var/lib/photoprism/photos/Originals'
PHOTOPRISM_IMPORT_PATH='/var/lib/photoprism/photos/Import'
" >$env_path

msg_info "Creating Service"
service_path="/etc/systemd/system/photoprism.service"

echo "[Unit]
Description=PhotoPrism service
After=network.target

[Service]
Type=forking
User=root
WorkingDirectory=/opt/photoprism
EnvironmentFile=/var/lib/photoprism/.env
ExecStart=/opt/photoprism/bin/photoprism up -d
ExecStop=/opt/photoprism/bin/photoprism down

[Install]
WantedBy=multi-user.target" >$service_path
msg_ok "Created Service"

PASS=$(grep -w "root" /etc/shadow | cut -b6)
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
rm -rf /var/{cache,log}/* \
  /photoprism \
  /go1.19.3.linux-amd64.tar.gz \
  /libtensorflow-linux-avx2-1.15.2.tar.gz \
  /libtensorflow-linux-avx-1.15.2.tar.gz \
  /libtensorflow-linux-cpu-1.15.2.tar.gz
msg_ok "Cleaned"

msg_info "Starting PhotoPrism"
$STD systemctl enable --now photoprism
msg_ok "Started PhotoPrism"
