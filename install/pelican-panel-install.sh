#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-author: Rogue-King
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
$STD apt-get install -y tar
$STD apt-get install -y unzip
$STD apt-get install -y git
$STD apt-get install -y software-properties-common
$STD apt-get install -y libapache2-mod-php
$STD apt-get install -y certbot
msg_ok "Installed Dependencies"

read -r -p "Would you like to install Redis? <y/N> (If you want to use external Redis server select 'N') " prompt
if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
  msg_info "Installing Redis"
  wget -qO- https://packages.redis.io/gpg | gpg --dearmor >/usr/share/keyrings/redis-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" >/etc/apt/sources.list.d/redis.list
  $STD apt-get update
  $STD apt-get install -y redis
  sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf
  systemctl enable -q --now redis-server.service
  msg_ok "Installed Redis"
fi

read -r -p "Would you like to install MariaDB? <y/N> (If you want to use external MariaDB server select 'N') " prompt
if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
  msg_info "Installing MariaDB"
  $STD bash <(curl -fsSL https://r.mariadb.com/downloads/mariadb_repo_setup)
  $STD apt-get update
  $STD apt-get install -y mariadb-server
  sed -i 's/^# *\(port *=.*\)/\1/' /etc/mysql/my.cnf
  sed -i 's/^bind-address/#bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf
  msg_ok "Installed MariaDB"
fi

msg_info "Installing PHP"
$STD add-apt-repository ppa:ondrej/php
$STD apt-get update
$STD apt-get install -y php8.3 php8.3-{gd,mysql,mbstring,bcmath,xml,curl,zip,intl,sqlite3,fpm}
msg_ok "Installed PHP"

msg_info "Installing Composer"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
msg_ok "Installed Composer"

while true; do
  CHOICE=$(
    whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --menu "Select option" 11 58 2 \
      "1" "Install Nginx" \
      "2" "Install Apache" 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    clear
    exit-script
  fi
  header_info
  case $CHOICE in
  1)
    $STD apt-get update
    $STD apt-get install -y nginx
    exit
    ;;
  2)
    $STD apt-get update
    $STD apt-get install -y apache2
    exit
    ;;
  esac
done

msg_info "Downloading Panel"
mkdir -p /var/www/pelican
cd /var/www/pelican
curl -L https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz
$STD tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
msg_ok "Downloaded Panel"

msg_info "Installing Panel"
composer install --no-dev --optimize-autoloader
php artisan p:environment:setup
php artisan p:environment:database
read -r -p "Would you like to setup Mail? <y/N> " prompt
if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
  php artisan p:environment:mail
fi
php artisan migrate --seed --force
php artisan p:user:make
msg_ok "Installed Panel"

msg_info "Setting up Crontab and Permissions"
echo "* * * * * php /var/www/pelican/artisan schedule:run >> /dev/null 2>&1" >> /var/spool/cron/crontabs/root
chown -R www-data:www-data /var/www/pelican/* 
msg_ok "Setup Crontab and Permissions"

if FQDN=$(whiptail --backtitle "Proxmox VE Helper Scripts" --inputbox "Set FQDN" 8 58 "panel.example.com" --title "FQDN" 3>&1 1>&2 2>&3); then
  if [ -z "$FQDN" ]; then
    FQDN="panel.example.com"
  else
    FQDN=$(echo ${FQDN,,} | tr -d ' ')
  fi
  echo -e "${DGN}Using FQDN: ${BGN}$FQDN${CL}"
else
  exit-script
fi

msg_info "Creating Webserver Configuration"
while true; do
  CHOICE=$(
    whiptail --backtitle "Proxmox VE Helper Scripts" --title "SUPPORT" --menu "Select option" 11 58 4 \
      "1" "Setup Nginx (http)" \
      "2" "Setup Nginx (https)" \
      "3" "TBD: Setup Apache (http)" \
      "4" "TBD: Setup Apache (https)" 3>&2 2>&1 1>&3
  )
  exit_status=$?
  if [ $exit_status == 1 ]; then
    clear
    exit-script
  fi
  header_info
  case $CHOICE in
  1)
    rm /etc/nginx/sites-enabled/default
    cat <<EOF >/etc/nginx/sites-available/pelican.conf
server {
    listen 80;
    server_name $FQDN;


    root /var/www/pelican/public;
    index index.html index.htm index.php;
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/pelican.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    ln -s /etc/nginx/sites-available/pelican.conf /etc/nginx/sites-enabled/pelican.conf
    systemctl restart nginx
    exit
    ;;
  2)
    certbot certonly --standalone --preferred-challenges http -d $FQDN
    rm /etc/nginx/sites-enabled/default
    cat <<EOF >/etc/nginx/sites-available/pelican.conf
server {
    listen 80;
    server_name $FQDN;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $FQDN;

    root /var/www/pelican/public;
    index index.php;

    access_log /var/log/nginx/pelican.app-access.log;
    error_log  /var/log/nginx/pelican.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    ssl_certificate /etc/letsencrypt/live/$FQDN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$FQDN/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;

    # See https://hstspreload.org/ before uncommenting the line below.
    # add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    ln -s /etc/nginx/sites-available/pelican.conf /etc/nginx/sites-enabled/pelican.conf
    systemctl restart nginx
    exit
    ;;
  esac
done
msg_ok "Created Webserver Configuration"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
