#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies (Patience)"
$STD apt-get install -y --no-install-recommends \
  unzip \
  mariadb-server \
  apache2 \
  curl \
  sudo \
  git \
  make \
  mc

curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x >/dev/null 2>&1
sudo apt-get update >/dev/null 2>&1
$STD sudo systemctl restart apache2 2>&1
sudo apt-get autoremove --purge php7.4 >/dev/null 2>&1
sudo apt-get autoremove --purge php7.4-common >/dev/null 2>&1

$STD apt-get install -y --no-install-recommends \
  php8.2 \
  php8.2-xml \
  libapache2-mod-php8.2 \
  php8.2-fpm \
  php8.2-curl \
  php8.2-mbstring \
  php8.2-ldap \
  php8.2-tidy \
  php8.2-zip \
  php8.2-gd \
  php8.2-mysql 
msg_ok "Installed Dependencies"

msg_info "Setting up Database"
DB_NAME=bookstack
DB_USER=bookstack
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
$STD sudo mysql -u root -e "CREATE DATABASE $DB_NAME;"
$STD sudo mysql -u root -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED WITH mysql_native_password AS PASSWORD('$DB_PASS');"
$STD sudo mysql -u root -e "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"
echo "" >>~/bookstack.creds
echo -e "Bookstack Database User: \e $DB_USER\e" >>~/bookstack.creds
echo -e "Bookstack Database Password: \e$DB_PASS\e" >>~/bookstack.creds
echo -e "Bookstack Database Name: \e$DB_NAME\e" >>~/bookstack.creds
msg_ok "Set up database"

msg_info "Setup Bookstack (Patience)"
SERVER_USER=bookstack
SERVER_IP="$(ip -o -4 addr show scope global | awk '{split($4,a,"/"); print a[1]}')"
SERVER_PASS="$(openssl rand -base64 18 | cut -c1-13)"
echo -e "Bookstack Server User: \e$SERVER_USER\e" >>~/bookstack.creds
echo -e "Bookstack Server Password: \e$SERVER_PASS\e" >>~/bookstack.creds
sudo useradd -m $SERVER_USER
echo "$SERVER_USER:$SERVER_PASS" | sudo chpasswd

EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')" >/dev/null 2>&1
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" >/dev/null 2>&1
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" >/dev/null 2>&1
if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid composer installer checksum' 
    rm composer-setup.php
    exit 1
fi
php composer-setup.php >/dev/null 2>&1
rm composer-setup.php 
mv composer.phar /usr/local/bin/composer
cd /opt
git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch bookstack >/dev/null 2>&1
cd bookstack
cp .env.example .env
sudo sed -i "s|APP_URL=.*|APP_URL=http://$SERVER_IP/|g" /opt/bookstack/.env
sudo sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" /opt/bookstack/.env
sudo sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" /opt/bookstack/.env
sudo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" /opt/bookstack/.env
export COMPOSER_ALLOW_SUPERUSER=1
php /usr/local/bin/composer install --no-dev --no-plugins >/dev/null 2>&1
php artisan key:generate --no-interaction --force >/dev/null 2>&1
php artisan migrate --no-interaction --force >/dev/null 2>&1
chown www-data:www-data -R bootstrap/cache public/uploads storage && chmod -R 755 bootstrap/cache public/uploads storage >/dev/null 2>&1
a2enmod rewrite >/dev/null 2>&1
a2enmod php8.2 >/dev/null 2>&1
msg_ok "Initial Setup complete"

msg_info "Set Path and File Permissions"
sudo chown -R bookstack:www-data /opt/bookstack
sudo chmod -R 755 /opt/bookstack
sudo chmod -R 775 /opt/bookstack/storage /opt/bookstack/bootstrap/cache /opt/bookstack/public/uploads
sudo chmod -R 640 /opt/bookstack/.env
msg_ok "Permissions successfully set"

msg_info "Set up web services"
cat <<EOF >/etc/apache2/sites-available/bookstack.conf
<VirtualHost *:80>
  ServerName replaceme

  ServerAdmin webmaster@localhost
  DocumentRoot /opt/bookstack/public/

  <Directory /opt/bookstack/public/>
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
  
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined

</VirtualHost>
EOF
sudo sed -i "s/ServerName replaceme/ServerName $SERVER_IP/" /etc/apache2/sites-available/bookstack.conf
/usr/sbin/a2ensite bookstack.conf >/dev/null 2>&1
$STD sudo systemctl restart apache2 >/dev/null 2>&1
msg_ok "Created Services"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
