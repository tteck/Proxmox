#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Python3"
$STD apt-get install -y --no-install-recommends \
	python3 \
	python3-pip \
	python3-dev \
	python3-setuptools \
	python3-wheel 
msg_ok "Installed Python3"

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y --no-install-recommends \
	redis \
	postgresql \
	build-essential \
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
	automake \
	libtool \
	pkg-config \
	git \
	curl \
	libtiff-dev \
	libpng-dev \
	libleptonica-dev \
	sudo \
	mc
msg_ok "Installed Dependencies"

msg_info "Installing OCR Dependencies (Patience)"
$STD apt-get install -y --no-install-recommends \
	unpaper \
	ghostscript \
	icc-profiles-free \
	qpdf \
	liblept5 \
	libxml2 \
	pngquant \
	zlib1g \
	tesseract-ocr \
	tesseract-ocr-eng
msg_ok "Installed OCR Dependencies"

msg_info "Installing JBIG2"
$STD git clone https://github.com/agl/jbig2enc /opt/jbig2enc
cd /opt/jbig2enc
$STD bash ./autogen.sh
$STD bash ./configure
$STD make
$STD make install
rm -rf /opt/jbig2enc
msg_ok "Installed JBIG2"

msg_info "Installing Paperless-ngx (Patience)"
Paperlessngx=$(wget -q https://github.com/paperless-ngx/paperless-ngx/releases/latest -O - | grep "title>Release" | cut -d " " -f 5)
cd /opt
$STD wget https://github.com/paperless-ngx/paperless-ngx/releases/download/$Paperlessngx/paperless-ngx-$Paperlessngx.tar.xz 
$STD tar -xf paperless-ngx-$Paperlessngx.tar.xz -C /opt/
mv paperless-ngx paperless
rm paperless-ngx-$Paperlessngx.tar.xz
cd /opt/paperless
## python 3.10+ doesn't like the '-e', so we remove it from this the requirements file
sed -i -e 's|-e git+https://github.com/paperless-ngx/django-q.git|git+https://github.com/paperless-ngx/django-q.git|' /opt/paperless/requirements.txt
$STD pip install --upgrade pip
$STD pip install -r requirements.txt
curl -s -o /opt/paperless/paperless.conf https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/main/paperless.conf.example
msg_ok "Installed Paperless-ngx"

msg_info "Installing Natural Language Toolkit (Patience)"
$STD python3 -m nltk.downloader -d /usr/share/nltk_data all
msg_ok "Installed Natural Language Toolkit"

msg_info "Setting up database"
DB_USER=paperless
DB_PASS="$(openssl rand -base64 18 | cut -c1-13)"
DB_NAME=paperlessdb
$STD sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';"
$STD sudo -u postgres psql -c "CREATE DATABASE $DB_NAME WITH OWNER $DB_USER TEMPLATE template0;"
echo "Paperless-ngx Database User" >>~/paperless.creds
echo $DB_USER >>~/paperless.creds
echo "Paperless-ngx Database Password" >>~/paperless.creds
echo $DB_PASS >>~/paperless.creds
echo "Paperless-ngx Database Name" >>~/paperless.creds
echo $DB_NAME >>~/paperless.creds
mkdir -p {consume,media}
sed -i -e 's|#PAPERLESS_DBNAME=paperless|PAPERLESS_DBNAME=paperlessdb|' /opt/paperless/paperless.conf
sed -i -e "s|#PAPERLESS_DBPASS=paperless|PAPERLESS_DBPASS=$DB_PASS|" /opt/paperless/paperless.conf
SECRET_KEY="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"
sed -i -e "s|#PAPERLESS_SECRET_KEY=change-me|PAPERLESS_SECRET_KEY=$SECRET_KEY|" /opt/paperless/paperless.conf
cd /opt/paperless/src
$STD python3 manage.py migrate
msg_ok "Set up database"

msg_info "Setting up admin Paperless-ngx User & Password"
## From https://github.com/linuxserver/docker-paperless-ngx/blob/main/root/etc/cont-init.d/99-migrations
cat <<EOF | python3 /opt/paperless/src/manage.py shell
from django.contrib.auth import get_user_model
UserModel = get_user_model()
user = UserModel.objects.create_user('admin', password='$DB_PASS')
user.is_superuser = True
user.is_staff = True
user.save()
EOF
echo "" >>~/paperless.creds
echo "Paperless-ngx WebUI User" >>~/paperless.creds
echo admin >>~/paperless.creds
echo "Paperless-ngx WebUI Password" >>~/paperless.creds
echo $DB_PASS >>~/paperless.creds
msg_ok "Set up admin Paperless-ngx User & Password"

msg_info "Creating Services"
cat <<EOF >/etc/systemd/system/paperless-scheduler.service
[Unit]
Description=Paperless Celery beat
Requires=redis.service

[Service]
WorkingDirectory=/opt/paperless/src
ExecStart=celery --app paperless beat --loglevel INFO

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/paperless-task-queue.service
[Unit]
Description=Paperless Celery Workers
Requires=redis.service

[Service]
WorkingDirectory=/opt/paperless/src
ExecStart=celery --app paperless worker --loglevel INFO

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/paperless-consumer.service
[Unit]
Description=Paperless consumer
Requires=redis.service

[Service]
WorkingDirectory=/opt/paperless/src
ExecStart=python3 manage.py document_consumer

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/paperless-webserver.service
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
$STD systemctl enable --now paperless-consumer paperless-webserver paperless-scheduler paperless-task-queue.service
msg_ok "Created Services"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
