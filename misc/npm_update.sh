#!/usr/bin/env bash
RELEASE=$(curl -s https://api.github.com/repos/NginxProxyManager/nginx-proxy-manager/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 3, length($2)-4) }') \

RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`

function update_info {
echo -e "${RD}
  _   _   _____    __  __ 
 | \ | | |  __ \  |  \/  |
 |  \| | | |__) | | \  / |
 |     | |  ___/  | |\/| |
 | |\  | | |      | |  | |
 |_| \_| |_|      |_|  |_|
      UPDATE  v${RELEASE}                                                                                                                      
${CL}"
}

update_info

while true; do
    read -p "This will update Nginx Proxy Manager to v${RELEASE}. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
update_info
set -o errexit  
set -o errtrace 
set -o nounset  
set -o pipefail 
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
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
T="$(date +%M)"

if [ -f /lib/systemd/system/npm.service ]; then
echo -en "${GN} Prep For Update... "
sleep 2
echo -e "${CM}${CL} \r"
echo -en "${GN} Stopping Services... "
  systemctl stop openresty
  systemctl stop npm
echo -e "${CM}${CL} \r"  
 
echo -en "${GN} Cleaning Old Files... "
  rm -rf /app \
  /var/www/html \
  /etc/nginx \
  /var/log/nginx \
  /var/lib/nginx \
  /var/cache/nginx &>/dev/null
  echo -e "${CM}${CL} \r"
  else
  echo -en "${RD} No NPM to Update! ${CL}"
  exit
fi

echo -en "${GN} Downloading NPM v${RELEASE}... "
wget -q https://codeload.github.com/NginxProxyManager/nginx-proxy-manager/tar.gz/v${RELEASE} -O - | tar -xz &>/dev/null
cd ./nginx-proxy-manager-${RELEASE}
echo -e "${CM}${CL} \r"

echo -en "${GN} Setting up Enviroment... "
ln -sf /usr/bin/python3 /usr/bin/python
ln -sf /usr/bin/certbot /opt/certbot/bin/certbot
ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx
ln -sf /usr/local/openresty/nginx/ /etc/nginx
sed -i "s+0.0.0+${RELEASE}+g" backend/package.json
sed -i "s+0.0.0+${RELEASE}+g" frontend/package.json
sed -i 's+^daemon+#daemon+g' docker/rootfs/etc/nginx/nginx.conf
NGINX_CONFS=$(find "$(pwd)" -type f -name "*.conf")
for NGINX_CONF in $NGINX_CONFS; do
  sed -i 's+include conf.d+include /etc/nginx/conf.d+g' "$NGINX_CONF"
done
mkdir -p /var/www/html /etc/nginx/logs
cp -r docker/rootfs/var/www/html/* /var/www/html/
cp -r docker/rootfs/etc/nginx/* /etc/nginx/
cp docker/rootfs/etc/letsencrypt.ini /etc/letsencrypt.ini
cp docker/rootfs/etc/logrotate.d/nginx-proxy-manager /etc/logrotate.d/nginx-proxy-manager
ln -sf /etc/nginx/nginx.conf /etc/nginx/conf/nginx.conf
rm -f /etc/nginx/conf.d/dev.conf
mkdir -p /tmp/nginx/body \
/run/nginx \
/data/nginx \
/data/custom_ssl \
/data/logs \
/data/access \
/data/nginx/default_host \
/data/nginx/default_www \
/data/nginx/proxy_host \
/data/nginx/redirection_host \
/data/nginx/stream \
/data/nginx/dead_host \
/data/nginx/temp \
/var/lib/nginx/cache/public \
/var/lib/nginx/cache/private \
/var/cache/nginx/proxy_temp
chmod -R 777 /var/cache/nginx
chown root /tmp/nginx
echo resolver "$(awk 'BEGIN{ORS=" "} $1=="nameserver" {print ($2 ~ ":")? "["$2"]": $2}' /etc/resolv.conf);" > /etc/nginx/conf.d/include/resolvers.conf
echo -e "${CM}${CL} \r"

if [ ! -f /data/nginx/dummycert.pem ] || [ ! -f /data/nginx/dummykey.pem ]; then
  echo -e "${CHECKMARK} \e[1;92m Generating dummy SSL Certificate... \e[0m"
  openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/O=Nginx Proxy Manager/OU=Dummy Certificate/CN=localhost" -keyout /data/nginx/dummykey.pem -out /data/nginx/dummycert.pem &>/dev/null
fi

mkdir -p /app/global /app/frontend/images
cp -r backend/* /app
cp -r global/* /app/global

echo -en "${GN} Building Frontend... "
cd ./frontend
export NODE_ENV=development
yarn install --network-timeout=30000 &>/dev/null
yarn build &>/dev/null
cp -r dist/* /app/frontend
cp -r app-images/* /app/frontend/images
echo -e "${CM}${CL} \r"

echo -en "${GN} Initializing Backend... "
rm -rf /app/config/default.json &>/dev/null
if [ ! -f /app/config/production.json ]; then
cat << 'EOF' > /app/config/production.json
{
  "database": {
    "engine": "knex-native",
    "knex": {
      "client": "sqlite3",
      "connection": {
        "filename": "/data/database.sqlite"
      }
    }
  }
}
EOF
fi
cd /app
export NODE_ENV=development
yarn install --network-timeout=30000 &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Starting Services... "
systemctl enable npm &>/dev/null
systemctl start openresty
systemctl start npm
echo -e "${CM}${CL} \r"
TS="$(($(date +%M)-T))"

IP=$(hostname -I | cut -f1 -d ' ')
echo -e "${GN}Successfully Updated Nginx Proxy Manager to ${RD}${RELEASE}${CL} and it took ${RD}${TS} minutes.${CL}
               NPM should be reachable at ${BL}http://${IP}:81 ${CL}
                  
                  "
