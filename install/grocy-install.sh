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
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y apache2
$STD apt-get install -y unzip
$STD apt-get install -y apt-transport-https
$STD apt-get install -y lsb-release
msg_ok "Installed Dependencies"

msg_info "Installing PHP 8.1"
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
$STD apt-get update
$STD apt-get install -y php8.1
$STD apt-get install -y libapache2-mod-php8.1
$STD apt-get install -y php8.1-sqlite3
$STD apt-get install -y php8.1-gd
$STD apt-get install -y php8.1-intl
$STD apt-get install -y php8.1-mbstring
msg_ok "Installed PHP 8.1"

msg_info "Installing grocy"
wget -q https://releases.grocy.info/latest
$STD unzip latest -d /var/www/html
chown -R www-data:www-data /var/www/html
cp /var/www/html/config-dist.php /var/www/html/data/config.php
chmod +x /var/www/html/update.sh

cat <<EOF >/etc/apache2/sites-available/grocy.conf
<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  DocumentRoot /var/www/html/public
  ErrorLog /var/log/apache2/error.log
<Directory /var/www/html/public>
  Options Indexes FollowSymLinks MultiViews
  AllowOverride All
  Order allow,deny
  allow from all
</Directory>
</VirtualHost>
EOF

$STD a2dissite 000-default.conf
$STD a2ensite grocy.conf
$STD a2enmod rewrite
systemctl reload apache2
msg_ok "Installed grocy"

motd_ssh
root

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
rm -rf /root/latest
msg_ok "Cleaned"
