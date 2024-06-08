#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
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

CURRENT_IP=$(ip addr | grep 'state UP' -A4 | grep 'inet ' | awk '{print $2}' | cut -f1  -d'/')

msg_info "Installing Dependencies"
$STD apt install -y git
$STD apt install -y php
$STD apt install -y php-xml
$STD apt install -y php-mbstring
$STD apt install -y php-pdo
$STD apt install -y php-mysql
$STD apt install -y php-gd
$STD apt install -y php-dom
$STD apt install -y php-curl
$STD apt install -y php-fpm
$STD apt install -y mariadb-server
$STD apt install -y apache2
$STD apt install -y libapache2-mod-php
$STD apt install -y unzip
msg_ok "Installed Dependencies"

msg_info "Installing composer"
EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid composer installer checksum'
    rm composer-setup.php
    exit 1
fi
php composer-setup.php --quiet
rm composer-setup.php
mv composer.phar /usr/local/bin/composer
msg_ok "Installed composer"

msg_info "Setting up Database MariaDB"
# Setup Mariadb
mysql -e "DROP USER IF EXISTS ''@'localhost'"
mysql -e "DROP USER IF EXISTS ''@'$(hostname)'"
mysql -e "DROP DATABASE IF EXISTS test"
mysql -e "FLUSH PRIVILEGES"

DB_PASS="$(openssl rand -hex 12)"

# Create Database and users
mysql -u root --execute="CREATE DATABASE bookstack;"
mysql -u root --execute="CREATE USER 'bookstack'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -u root --execute="GRANT ALL ON bookstack.* TO 'bookstack'@'localhost';FLUSH PRIVILEGES;"
msg_ok "Set up Database"

msg_info "Setting up bookstack"
BOOKSTACK_DIR="/opt/bookstack"
$STD git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch ${BOOKSTACK_DIR}
cd ${BOOKSTACK_DIR}
export COMPOSER_ALLOW_SUPERUSER=1
$STD composer install --no-dev
cp .env.example .env
sed -i.bak "s@APP_URL=.*\$@APP_URL=http://$CURRENT_IP@" .env
sed -i.bak 's/DB_DATABASE=.*$/DB_DATABASE=bookstack/' .env
sed -i.bak 's/DB_USERNAME=.*$/DB_USERNAME=bookstack/' .env
sed -i.bak "s/DB_PASSWORD=.*\$/DB_PASSWORD=$DB_PASS/" .env
php artisan key:generate --no-interaction --force
chown -R root:www-data ${BOOKSTACK_DIR}
chmod -R 755 ${BOOKSTACK_DIR}
chmod -R 775 ${BOOKSTACK_DIR}/storage ${BOOKSTACK_DIR}/bootstrap/cache ${BOOKSTACK_DIR}/public/uploads
chmod 640 ${BOOKSTACK_DIR}/.env
$STD git config core.fileMode false
php artisan migrate --no-interaction --force
msg_ok "Set up bookstack"


msg_info "Setting up apache2"
$STD a2enmod rewrite proxy_fcgi setenvif
$STD a2enconf php8.2-fpm
  # Set-up the required BookStack apache config
cat >/etc/apache2/sites-available/bookstack.conf <<EOL
<VirtualHost *:80>
  ServerName ${CURRENT_IP}

  ServerAdmin webmaster@localhost
  DocumentRoot ${BOOKSTACK_DIR}/public/

  <Directory ${BOOKSTACK_DIR}/public/>
      Options -Indexes +FollowSymLinks
      AllowOverride None
      Require all granted
      <IfModule mod_rewrite.c>
          <IfModule mod_negotiation.c>
              Options -MultiViews -Indexes
          </IfModule>

          RewriteEngine On

          # Handle Authorization Header
          RewriteCond %{HTTP:Authorization} .
          RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

          # Redirect Trailing Slashes If Not A Folder...
          RewriteCond %{REQUEST_FILENAME} !-d
          RewriteCond %{REQUEST_URI} (.+)/$
          RewriteRule ^ %1 [L,R=301]

          # Handle Front Controller...
          RewriteCond %{REQUEST_FILENAME} !-d
          RewriteCond %{REQUEST_FILENAME} !-f
          RewriteRule ^ index.php [L]
      </IfModule>
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOL
$STD a2dissite 000-default.conf
$STD a2ensite bookstack.conf
$STD systemctl reload apache2
$STD systemctl start php8.2-fpm.service
msg_ok "Set up apache2"


motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
