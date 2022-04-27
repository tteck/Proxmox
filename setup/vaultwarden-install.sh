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
  local reason="Unknown failure occured."
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

msg_info "Checking Internet Status"
INTER=$(wget -q --tries=10 --timeout=5 --spider https://google.com)
sleep 2
if [[ "$INTER" != "0" ]]; then
        msg_ok "Internet Online"
else
        echo -e "${BFR} ${CROSS}${RD} Internet Offline${CL}"
fi

msg_info "Updating Container OS"
apt update &>/dev/null
apt-get -qqy upgrade &>/dev/null
msg_ok "Updated Container OS"

msg_info "Installing Dependencies"
apt-get update &>/dev/null
apt-get -qqy install \
    git \
    nano \
    wget \
    htop \
    pkg-config \
    openssl \
    libssl1.1 \
    libssl-dev \
    curl \
    sudo &>/dev/null
msg_ok "Installed Dependencies"

msg_info "Installing Build Essentials"
apt-get install -y build-essential &>/dev/null
msg_ok "Installed Build Essentials"

msg_info "Installing Rust"
curl https://sh.rustup.rs -sSf | sh -s -- -y &>/dev/null
echo 'export PATH=~/.cargo/bin:$PATH' >> ~/.bashrc &>/dev/null
export PATH=~/.cargo/bin:$PATH &>/dev/null
which rustc &>/dev/null
msg_ok "Installed Rust"

msg_info "Installing Node.js"
curl -fsSL https://deb.nodesource.com/setup_16.x | bash - &>/dev/null
apt-get install -y nodejs &>/dev/null
npm -g install npm@7 &>/dev/null
which npm &>/dev/null
npm i npm@latest -g &>/dev/null
msg_ok "Installed Node.js"

msg_info "Building Vaultwarden (Patience)"
git clone https://github.com/dani-garcia/vaultwarden &>/dev/null
pushd vaultwarden &>/dev/null
cargo clean &>/dev/null 
cargo build --features sqlite --release &>/dev/null
file target/release/vaultwarden &>/dev/null
msg_ok "Built Vaultwarden"

msg_info "Building Web-Vault"
pushd target/release/ &>/dev/null
git clone --recurse-submodules https://github.com/bitwarden/web.git web-vault.git &>/dev/null
cd web-vault.git &>/dev/null
git checkout v2.25.1 &>/dev/null
git submodule update --init --recursive &>/dev/null
wget https://raw.githubusercontent.com/dani-garcia/bw_web_builds/master/patches/v2.25.0.patch &>/dev/null
git apply v2.25.0.patch &>/dev/null
npm ci --silent --legacy-peer-deps &>/dev/null
npm audit fix --silent --legacy-peer-deps || true &>/dev/null
npm run --silent dist:oss:selfhost &>/dev/null
cp -a build ../web-vault &>/dev/null
cd ..
mkdir data 
msg_ok "Built Web-Vault"

msg_info "Creating Service"
cp ../../.env.template /etc/vaultwarden.env &>/dev/null
cp vaultwarden /usr/bin/vaultwarden &>/dev/null
chmod +x /usr/bin/vaultwarden &>/dev/null
useradd -m -d /var/lib/vaultwarden vaultwarden &>/dev/null
sudo cp -R data /var/lib/vaultwarden/ &>/dev/null
cp -R web-vault /var/lib/vaultwarden/ &>/dev/null
chown -R vaultwarden:vaultwarden /var/lib/vaultwarden &>/dev/null

service_path="/etc/systemd/system/vaultwarden.service" &>/dev/null

echo "[Unit]
Description=Bitwarden Server (Powered by Vaultwarden)
Documentation=https://github.com/dani-garcia/vaultwarden
After=network.target
[Service]
User=vaultwarden
Group=vaultwarden
EnvironmentFile=/etc/vaultwarden.env
ExecStart=/usr/bin/vaultwarden
LimitNOFILE=1048576
PrivateTmp=true
PrivateDevices=true
ProtectHome=true
ProtectSystem=strict
WorkingDirectory=/var/lib/vaultwarden
ReadWriteDirectories=/var/lib/vaultwarden
AmbientCapabilities=CAP_NET_BIND_SERVICE
[Install]
WantedBy=multi-user.target" > $service_path
systemctl daemon-reload
systemctl enable vaultwarden.service &>/dev/null
systemctl start vaultwarden.service &>/dev/null
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
