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
$STD apt-get update --fix-missing
$STD apt-get -y upgrade
msg_ok "Updated Container OS"

ubuntuversion=$(lsb_release -r | awk '{print $2}' | cut -d . -f1)
if [ "$ubuntuversion" = "18" ] || [ "$ubuntuversion" -le "18" ]; then
    apt install sudo wget -y
    sudo apt install -y software-properties-common
    sudo add-apt-repository universe -y
    apt update -y
    apt update --fix-missing -y
fi

msg_info "Installing Dependencies"
$STD apt-get install -y curl sudo git mc
$STD apt-get install -y make zip net-tools
$STD apt-get install -y gcc g++ cmake
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
$STD bash <(curl -fsSL https://deb.nodesource.com/setup_18.x)
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing FFMPEG"
$STD apt-get install -y ffmpeg
msg_ok "Installed FFMPEG"

msg_info "Clonning Shinobi"
cd /opt
$STD git clone https://gitlab.com/Shinobi-Systems/Shinobi.git -b master Shinobi
cd Shinobi
gitVersionNumber=$(git rev-parse HEAD)
theDateRightNow=$(date)
touch version.json
chmod 777 version.json
echo '{"Product" : "'"Shinobi"'" , "Branch" : "'"master"'" , "Version" : "'"$gitVersionNumber"'" , "Date" : "'"$theDateRightNow"'" , "Repository" : "'"https://gitlab.com/Shinobi-Systems/Shinobi.git"'"}' > version.json
msg_ok "Cloned Shinobi"

msg_info "Installing Database"
sqlpass=""
echo "mariadb-server mariadb-server/root_password password $sqlpass" | debconf-set-selections
echo "mariadb-server mariadb-server/root_password_again password $sqlpass" | debconf-set-selections
$STD apt-get install -y mariadb-server
service mysql start
sqluser="root"
mysql -e "source sql/user.sql" || true
mysql -e "source sql/framework.sql" || true
msg_ok "Installed Database"
cp conf.sample.json conf.json
cronKey=$(head -c 1024 < /dev/urandom | sha256sum | awk '{print substr($1,1,29)}')
sed -i -e 's/Shinobi/'"$cronKey"'/g' conf.json
cp super.sample.json super.json

msg_info "Installing Shinobi"
$STD npm i npm -g
$STD npm install --unsafe-perm
$STD npm install pm2@latest -g
chmod -R 755 .
touch INSTALL/installed.txt
ln -s /opt/Shinobi/INSTALL/shinobi /usr/bin/shinobi
node /opt/Shinobi/tools/modifyConfiguration.js addToConfig="{\"cron\":{\"key\":\"$(head -c 64 < /dev/urandom | sha256sum | awk '{print substr($1,1,60)}')\"}}" &>/dev/null
$STD pm2 start camera.js
$STD pm2 start cron.js
$STD pm2 startup
$STD pm2 save
$STD pm2 list
msg_ok "Installed Shinobi"

PASS=$(grep -w "root" /etc/shadow | cut -b6)
echo "export TERM='xterm-256color'" >>/root/.bashrc
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
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
