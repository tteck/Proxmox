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

function msg_error() {
    local msg="$1"
    echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

msg_info "Setting up Container OS "
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
while [ "$(hostname -I)" = "" ]; do
  1>&2 echo -en "${CROSS}${RD} No Network! "
  sleep $RETRY_EVERY
  ((NUM--))
  if [ $NUM -eq 0 ]
  then
    1>&2 echo -e "${CROSS}${RD} No Network After $RETRY_NUM Tries${CL}"    
    exit 1
  fi
done
msg_ok "Set up Container OS"
msg_ok "Network Connected: ${BL}$(hostname -I)"

set +e
alias die=''
if nc -zw1 8.8.8.8 443; then  msg_ok "Internet Connected"; else  msg_error "Internet NOT Connected"; exit 1; fi;
RESOLVEDIP=$(nslookup "github.com" | awk -F':' '/^Address: / { matched = 1 } matched { print $2}' | xargs)
if [[ -z "$RESOLVEDIP" ]]; then msg_error "DNS Lookup Failure";  else msg_ok "DNS Resolved github.com to $RESOLVEDIP";  fi;
alias die='EXIT=$? LINE=$LINENO error_exit'
set -e

msg_info "Updating Container OS"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated Container OS"

msg_info "Installing Paperless-ngx Dependencies"
apt-get install -y --no-install-recommends \
	python3 \
	python3-pip \
	python3-dev \
	imagemagick \
	fonts-liberation \
	optipng \
	gnupg \
	libpq-dev \
	libmagic-dev \
	mime-support \
	libzbar0 \
	poppler-utils \
	default-libmysqlclient-dev \
	sudo &>/dev/null
msg_ok "Installed Paperless-ngx Dependencies"

msg_info "Installing OCR Dependencies"
apt-get install -y --no-install-recommends \
	unpaper \
	ghostscript \
	icc-profiles-free \
	qpdf \
	liblept5 \
	libxml2 \
	pngquant \
	zlib1g \
	tesseract-ocr \
	tesseract-ocr-eng &>/dev/null
msg_ok "Installed OCR Dependencies"

msg_info "Installing Extra Dependencies"
apt-get install -y --no-install-recommends \
	redis \
	postgresql \
	build-essential \
	python3-setuptools \
	python3-wheel &>/dev/null
msg_ok "Installed Extra Dependencies"

msg_info "Installing JBIG2"
apt-get install -y --no-install-recommends \
	automake \
	libtool \
	pkg-config \
	git \
	curl \
	libtiff-dev \
	libpng-dev \
	libleptonica-dev &>/dev/null

git clone https://github.com/agl/jbig2enc /opt/jbig2enc &>/dev/null
cd /opt/jbig2enc
/bin/bash -c "./autogen.sh" &>/dev/null && \
/bin/bash -c "./configure && make" &>/dev/null && \
/bin/bash -c "make install" &>/dev/null
rm -rf /opt/jbig2enc 
msg_ok "Installed JBIG2"

msg_info "Downloading Paperless-ngx"
Paperlessngx=$(wget -q https://github.com/paperless-ngx/paperless-ngx/releases/latest -O - | grep "title>Release" | cut -d " " -f 5)
cd /opt && \
wget https://github.com/paperless-ngx/paperless-ngx/releases/download/$Paperlessngx/paperless-ngx-$Paperlessngx.tar.xz &>/dev/null && \
tar -xf paperless-ngx-$Paperlessngx.tar.xz -C /opt/ &>/dev/null && \
mv paperless-ngx paperless && \
rm paperless-ngx-$Paperlessngx.tar.xz
cd /opt/paperless

## python 3.10+ doesn't like the '-e', so we remove it from this the requirements file
sed -i -e 's|-e git+https://github.com/paperless-ngx/django-q.git|git+https://github.com/paperless-ngx/django-q.git|' /opt/paperless/requirements.txt

/usr/bin/python3 -m pip install --upgrade pip &>/dev/null
/usr/bin/python3 -m pip install -r requirements.txt &>/dev/null
msg_ok "Downloaded Paperless-ngx"

msg_info "Setting up database"
DB_USER=paperless
DB_PASS="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)"
DB_NAME=paperlessdb

sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';" &>/dev/null
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME WITH OWNER $DB_USER TEMPLATE template0;" &>/dev/null

echo "Paperless-ngx Database User" >> ~/paperless.creds
echo $DB_USER >> ~/paperless.creds
echo "Paperless-ngx Database Password" >> ~/paperless.creds
echo $DB_PASS >> ~/paperless.creds
echo "Paperless-ngx Database Name" >> ~/paperless.creds
echo $DB_NAME >> ~/paperless.creds

/bin/bash -c "mkdir -p {consume,media}"

sed -i -e 's|#PAPERLESS_DBNAME=paperless|PAPERLESS_DBNAME=paperlessdb|' /opt/paperless/paperless.conf
sed -i -e "s|#PAPERLESS_DBPASS=paperless|PAPERLESS_DBPASS=$DB_PASS|" /opt/paperless/paperless.conf
SECRET_KEY="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"
sed -i -e "s|#PAPERLESS_SECRET_KEY=change-me|PAPERLESS_SECRET_KEY=$SECRET_KEY|" /opt/paperless/paperless.conf

cd /opt/paperless/src
/usr/bin/python3 manage.py migrate &>/dev/null
msg_ok "Set up database"

msg_info "Setting up admin Paperless-ngx User & Password"
## From https://github.com/linuxserver/docker-paperless-ngx/blob/main/root/etc/cont-init.d/99-migrations
cat << EOF | python3 /opt/paperless/src/manage.py shell
from django.contrib.auth import get_user_model
UserModel = get_user_model()
if len(UserModel.objects.all()) == 1:
    user = UserModel.objects.create_user('admin', password='$DB_PASS')
    user.is_superuser = True
    user.is_staff = True
    user.save()
EOF
echo "" >> ~/paperless.creds
echo "Paperless-ngx WebUI User" >> ~/paperless.creds
echo admin >> ~/paperless.creds
echo "Paperless-ngx WebUI Password" >> ~/paperless.creds
echo $DB_PASS >> ~/paperless.creds
msg_ok "Set up admin Paperless-ngx User & Password"

cat << EOF > /etc/systemd/system/paperless-scheduler.service
[Unit]
Description=Paperless consumer
Requires=redis.service

[Service]
WorkingDirectory=/opt/paperless/src
ExecStart=python3 manage.py qcluster

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /etc/systemd/system/paperless-consumer.service
[Unit]
Description=Paperless consumer
Requires=redis.service

[Service]
WorkingDirectory=/opt/paperless/src
ExecStart=python3 manage.py document_consumer

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /etc/systemd/system/paperless-webserver.service
[Unit]
Description=Paperless webserver
After=network.target
Wants=network.target
Requires=redis.service

[Service]
WorkingDirectory=/opt/paperless/src
ExecStart=/usr/local/bin/gunicorn -c /opt/paperless/gunicorn.conf.py paperless.asgi:application

[Install]
WantedBy=multi-user.target
EOF

sed -i -e 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml

systemctl daemon-reload
systemctl enable --now paperless-consumer paperless-webserver paperless-scheduler &>/dev/null

msg_ok "Finished installing Paperless-ngx"

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
msg_ok "Cleaned"
