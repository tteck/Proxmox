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
$STD apk add newt
$STD apk add curl
$STD apk add openssl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
$STD apk add argon2
msg_ok "Installed Dependencies"

msg_info "Creating Credentials"
DB_NAME=nextcloud
DB_USER=nextcloud
DB_PASS="$(openssl rand -base64 18 | cut -c1-13)"
ROOT_PASS="$(openssl rand -base64 18 | cut -c1-13)"
ADMIN_USER=ncAdmin
ADMIN_PASS="$(openssl rand -base64 18 | cut -c1-13)"
echo "" >>~/nextcloud.creds
echo -e "Nextcloud Database Username: \e[32m$DB_USER\e[0m" >>~/nextcloud.creds
echo -e "Nextcloud Database Password: \e[32m$DB_PASS\e[0m" >>~/nextcloud.creds
echo -e "Nextcloud Database Name: \e[32m$DB_NAME\e[0m" >>~/nextcloud.creds
echo -e "Nextcloud Admin Password: \e[32m$ADMIN_PASS\e[0m" >>~/nextcloud.creds
echo -e "Nextcloud Admin Username: \e[32m$ADMIN_USER\e[0m" >>~/nextcloud.creds
echo -e "MySQL Root Password: \e[32m$ROOT_PASS\e[0m" >>~/nextcloud.creds
msg_ok "Created Credentials"

msg_info "Installing MySQL Database"
$STD apk add nextcloud-mysql mariadb mariadb-client
$STD mysql_install_db --user=mysql --datadir=/var/lib/mysql
$STD service mariadb start
$STD rc-update add mariadb
msg_ok "Installed MySQL Database"

msg_info "Setting up MySQL Database"
$STD mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$ROOT_PASS' WITH GRANT OPTION;FLUSH PRIVILEGES;"
$STD mysql -uroot -p$ROOT_PASS -e "DELETE FROM mysql.user WHERE User='';"
$STD mysql -uroot -p$ROOT_PASS -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
$STD mysql -uroot -p$ROOT_PASS -e "DROP DATABASE test;"
$STD mysql -uroot -p$ROOT_PASS -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
$STD mysql -uroot -p$ROOT_PASS -e "CREATE DATABASE $DB_NAME;"
$STD mysql -uroot -p$ROOT_PASS -e "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
$STD mysql -uroot -p$ROOT_PASS -e "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost.localdomain' IDENTIFIED BY '$DB_PASS';"
$STD mysql -uroot -p$ROOT_PASS -e "FLUSH PRIVILEGES;"
$STD apk del mariadb-client
msg_ok "Set up MySQL Database"

msg_info "Installing Web-Server"
$STD apk add nextcloud-initscript
$STD apk add nginx
$STD apk add php82-fpm
$STD apk add php82-sysvsem
$STD apk add php82-pecl-imagick
$STD apk add php82-exif
msg_ok "Installed Web-Server"

msg_info "Setting up Web-Server"
$STD openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/nextcloud-selfsigned.key -out /etc/ssl/certs/nextcloud-selfsigned.crt -subj "/C=US/O=Nextcloud/OU=Domain Control Validated/CN=nextcloud.local"
$STD rm /etc/nginx/http.d/default.conf
cat <<'EOF' >/etc/nginx/http.d/nextcloud.conf
server {
        listen       [::]:80;
        listen       80;
        return 301 https://$host$request_uri;
        server_name localhost;
}

server {
        listen       443 ssl http2;
        listen       [::]:443 ssl http2;
        server_name  localhost;

        root /usr/share/webapps/nextcloud;
        index  index.php index.html index.htm;
        disable_symlinks off;

        ssl_certificate      /etc/ssl/certs/nextcloud-selfsigned.crt;
        ssl_certificate_key  /etc/ssl/private/nextcloud-selfsigned.key;
        ssl_session_timeout  5m;

        #Enable Perfect Forward Secrecy and ciphers without known vulnerabilities
        #Beware! It breaks compatibility with older OS and browsers (e.g. Windows XP, Android 2.x, etc.)
        ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA;
        ssl_prefer_server_ciphers  on;


        location / {
            try_files $uri $uri/ /index.html;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        location ~ [^/]\.php(/|$) {
                fastcgi_split_path_info ^(.+?\.php)(/.*)$;
                if (!-f $document_root$fastcgi_script_name) {
                        return 404;
                }
                #fastcgi_pass 127.0.0.1:9000;
                #fastcgi_pass unix:/run/php-fpm/socket;
                fastcgi_pass unix:/run/nextcloud/fastcgi.sock; # From the nextcloud-initscript package
                fastcgi_index index.php;
                include fastcgi.conf;
        }

        # Help pass nextcloud's configuration checks after install:
        # Per https://docs.nextcloud.com/server/22/admin_manual/issues/general_troubleshooting.html#service-discovery
        location ^~ /.well-known/carddav { return 301 /remote.php/dav/; }
        location ^~ /.well-known/caldav { return 301 /remote.php/dav/; }
        location ^~ /.well-known/webfinger { return 301 /index.php/.well-known/webfinger; }
        location ^~ /.well-known/nodeinfo { return 301 /index.php/.well-known/nodeinfo; }
}
EOF
sed -i -e 's|client_max_body_size 1m;|client_max_body_size 5120m;|' /etc/nginx/nginx.conf
sed -i -e 's|php_admin_value\[memory_limit\] = 512M|php_admin_value\[memory_limit\] = 5120M|' /etc/php82/php-fpm.d/nextcloud.conf
sed -i -e 's|php_admin_value\[post_max_size\] = 513M|php_admin_value\[post_max_size\] = 5121M|' /etc/php82/php-fpm.d/nextcloud.conf
sed -i -e 's|php_admin_value\[upload_max_filesize\] = 513M|php_admin_value\[upload_max_filesize\] = 5121M|' /etc/php82/php-fpm.d/nextcloud.conf
sed -i -e 's|upload_max_filesize = 513M|upload_max_filesize = 5121M|' /etc/php82/php.ini
sed -i -e 's|memory_limit = 128M|memory_limit = 512M|' /etc/php82/php.ini
msg_ok "Set up Web-Server"

msg_info "Adding Additional Nextcloud Packages"
$STD apk add nextcloud-activity
$STD apk add nextcloud-admin_audit
$STD apk add nextcloud-comments
$STD apk add nextcloud-dashboard
$STD apk add nextcloud-doc
$STD apk add nextcloud-encryption
$STD apk add nextcloud-federation
$STD apk add nextcloud-files_external
$STD apk add nextcloud-files_sharing
$STD apk add nextcloud-files_trashbin
$STD apk add nextcloud-files_versions
$STD apk add nextcloud-notifications
$STD apk add nextcloud-sharebymail
$STD apk add nextcloud-suspicious_login
$STD apk add nextcloud-support
$STD apk add nextcloud-systemtags
$STD apk add nextcloud-user_status
$STD apk add nextcloud-weather_status
msg_ok "Added Additional Nextcloud Packages"

msg_info "Setting up Cache"
$STD apk add php82-opcache
$STD apk add php82-redis
$STD apk add php82-apcu
$STD apk add redis
sed -i -e 's|;opcache.enable=1|opcache.enable=1|' /etc/php82/php.ini
sed -i -e 's|;opcache.enable_cli=1|opcache.enable_cli=1|' /etc/php82/php.ini
sed -i -e 's|;opcache.interned_strings_buffer=8|opcache.interned_strings_buffer=16|' /etc/php82/php.ini
sed -i -e 's|;opcache.max_accelerated_files=10000|opcache.max_accelerated_files=10000|' /etc/php82/php.ini
sed -i -e 's|;opcache.memory_consumption=128|opcache.memory_consumption=256|' /etc/php82/php.ini
sed -i -e 's|;opcache.save_comments=1|opcache.save_comments=1|' /etc/php82/php.ini
sed -i -e 's|;opcache.revalidate_freq=1|opcache.revalidate_freq=1|' /etc/php82/php.ini
$STD rc-update add redis
$STD rc-service redis start
msg_ok "Set up Cache"

msg_info "Setting up Nextcloud-Cronjob"
mkdir -p /etc/periodic/5min
cat <<'EOF' >/etc/periodic/5min/nextcloud_cron
#!/bin/sh

# Run only when nextcloud service is started.
if rc-service nextcloud -q status >/dev/null 2>&1; then
        su nextcloud -s /bin/sh -c 'php82 -f /usr/share/webapps/nextcloud/cron.php'
fi
EOF
sed -i '/monthly/a */5     *       *       *       *       run-parts /etc/periodic/5min' /etc/crontabs/root
$STD chmod +x /etc/periodic/5min/nextcloud_cron
msg_ok "Set up Nextcloud-Cronjob"

msg_info "Setting up Nextcloud-Config"
cat <<'EOF' >/usr/share/webapps/nextcloud/config/config.php
<?php
$CONFIG = array (
  'datadirectory' => '/var/lib/nextcloud/data',
  'logfile' => '/var/log/nextcloud/nextcloud.log',
  'logdateformat' => 'F d, Y H:i:s',
  'log_rotate_size' => 104857600,
  'apps_paths' => array (
    // Read-only location for apps shipped with Nextcloud and installed by apk.
    0 => array (
      'path' => '/usr/share/webapps/nextcloud/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    // Writable location for apps installed from AppStore.
    1 => array (
      'path' => '/var/lib/nextcloud/apps',
      'url' => '/apps-appstore',
      'writable' => true,
    ),
  ),
  'updatechecker' => false,
  'check_for_working_htaccess' => false,

  // Uncomment to enable Zend OPcache.
  'memcache.local' => '\\OC\\Memcache\\Redis',

  // Uncomment this and add user nextcloud to the redis group to enable Redis
  // cache for file locking. This is highly recommended, see
  // https://github.com/nextcloud/server/issues/9305.
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => array(
    'host' => 'localhost',
    'port' => 6379,
    'dbindex' => 0,
    'timeout' => 1.5,
  ),
  'installed' => false,
);
EOF
msg_ok "Set up Nextcloud-Config"

msg_info "Starting Alpine-Nextcloud"
$STD rc-service php-fpm82 start
$STD chown -R nextcloud:www-data /var/log/nextcloud/
$STD rc-service php-fpm82 restart
$STD rc-service nginx start
$STD rc-service nextcloud start
$STD rc-update add nginx default
$STD rc-update add nextcloud default
msg_ok "Started Alpine-Nextcloud"

msg_info "Start Setup-Wizard"
$STD cd /usr/share/webapps/nextcloud
$STD su nextcloud -s /bin/sh -c "php82 occ maintenance:install \
--database='mysql' --database-name $DB_NAME \
--database-user '$DB_USER' --database-pass '$DB_PASS' \
--admin-user '$ADMIN_USER' --admin-pass '$ADMIN_PASS' \
--data-dir '/var/lib/nextcloud/data'"
$STD su nextcloud -s /bin/sh -c 'php82 occ background:cron'
$STD su nextcloud -s /bin/sh -c 'php82 occ app:disable dashboard'
IP4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
sed -i "/0 => \'localhost\',/a \    \1 => '$IP4'," /usr/share/webapps/nextcloud/config/config.php
msg_ok "Run Setup-Wizard"

motd_ssh
customize
