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

msg_info "Installing Dependencies"
$STD apt-get -y install \
  sudo \
  mc \
  curl \
  apt-utils \
  lighttpd \
  sqlite3 \
  mmdb-bin \
  arp-scan \
  dnsutils \
  net-tools \
  libwww-perl \
  nmap \
  zip \
  wakeonlan
msg_ok "Installed Dependencies"

msg_info "Installing PHP Dependencies"
$STD apt-get -y install \
  php \
  php-cgi \
  php-fpm \
  php-curl \
  php-sqlite3
$STD lighttpd-enable-mod fastcgi-php
service lighttpd force-reload
msg_ok "Installed PHP Dependencies"
#arp-scan -l

msg_info "Installing Python Dependencies"
$STD apt-get -y install \
  python3-pip \
  python3-requests
$STD pip3 install mac-vendor-lookup
$STD pip3 install fritzconnection
$STD pip3 install cryptography
msg_ok "Installed Python Dependencies"

msg_info "Installing Pi.Alert (Patience)"
curl -sL https://github.com/leiweibau/Pi.Alert/raw/main/tar/pialert_latest.tar | tar xvf - -C /opt >/dev/null 2>&1

rm /var/www/html/index.html
mv /var/www/html/index.lighttpd.html /var/www/html/index.lighttpd.html.old
ln -s /opt/pialert/install/index.html /var/www/html/index.html
ln -s /opt/pialert/front /var/www/html/pialert
chmod go+x /opt/pialert
chgrp -R www-data /opt/pialert/db
chmod -R 775 /opt/pialert/db
chmod -R 775 /opt/pialert/db/temp
chgrp www-data /opt/pialert/config
chmod -R 775 /opt/pialert/config
chgrp www-data /opt/pialert/config/pialert.conf
chmod -R 775 /opt/pialert/front/reports
chgrp -R www-data /opt/pialert/front/reports
chmod +x /opt/pialert/back/shoutrrr/x86/shoutrrr
touch "/opt/pialert/log/pialert.vendors.log"
touch "/opt/pialert/log/pialert.IP.log"
touch "/opt/pialert/log/pialert.1.log"
touch "/opt/pialert/log/pialert.cleanup.log"
touch "/opt/pialert/log/pialert.webservices.log"
ln -s "/opt/pialert/log/pialert.vendors.log" "/opt/pialert/front/php/server/pialert.vendors.log"
ln -s "/opt/pialert/log/pialert.IP.log" "/opt/pialert/front/php/server/pialert.IP.log"
ln -s "/opt/pialert/log/pialert.1.log" "/opt/pialert/front/php/server/pialert.1.log"
ln -s "/opt/pialert/log/pialert.cleanup.log" "/opt/pialert/front/php/server/pialert.cleanup.log"
ln -s "/opt/pialert/log/pialert.webservices.log" "/opt/pialert/front/php/server/pialert.webservices.log"
sed -i 's#PIALERT_PATH\s*=\s*'\''/home/pi/pialert'\''#PIALERT_PATH           = '\''/opt/pialert'\''#' /opt/pialert/config/pialert.conf
msg_ok "Installed Pi.Alert"

msg_info "Start Pi.Alert Scan"
$STD python3 /opt/pialert/back/pialert.py update_vendors
$STD python3 /opt/pialert/back/pialert.py internet_IP
$STD python3 /opt/pialert/back/pialert.py 1
msg_ok "Finished Pi.Alert Scan"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
