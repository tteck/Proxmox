#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
CROSS='\033[1;31m\xE2\x9D\x8C\033[0m'
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
RETRY_NUM=10
RETRY_EVERY=3
NUM=$RETRY_NUM
trap die ERR
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

echo -e "${CHECKMARK} \e[1;92m Installing Build Essentials... \e[0m"
apt-get install -y build-essential &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Rust... \e[0m"
curl https://sh.rustup.rs -sSf | sh -s -- -y &>/dev/null
echo 'export PATH=~/.cargo/bin:$PATH' >> ~/.bashrc &>/dev/null
export PATH=~/.cargo/bin:$PATH &>/dev/null
which rustc &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Installing Node.js... \e[0m"
curl -fsSL https://deb.nodesource.com/setup_16.x | bash - &>/dev/null
apt-get install -y nodejs &>/dev/null
npm -g install npm@7 &>/dev/null
which npm &>/dev/null
npm i npm@latest -g &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Building Vaultwarden (Patience)... \e[0m"
git clone https://github.com/dani-garcia/vaultwarden &>/dev/null
pushd vaultwarden &>/dev/null
cargo clean &>/dev/null 
cargo build --features sqlite --release &>/dev/null
file target/release/vaultwarden &>/dev/null

echo -e "${CHECKMARK} \e[1;92m Building Web-Vault... \e[0m"
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

echo -e "${CHECKMARK} \e[1;92m Create Systemd Service... \e[0m"
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
LimitNPROC=64
PrivateTmp=true
PrivateDevices=true
ProtectHome=true
ProtectSystem=strict
WorkingDirectory=/var/lib/vaultwarden
ReadWriteDirectories=/var/lib/vaultwarden
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target" > $service_path

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
systemctl enable vaultwarden.service &>/dev/null
systemctl start vaultwarden.service &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Cleanup... \e[0m"
rm -rf /vault_setup.sh /var/{cache,log}/* /var/lib/apt/lists/*
