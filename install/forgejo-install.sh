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

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
$STD apt-get install -y git-lfs
msg_ok "Installed Dependencies"

msg_info "Installing Forgejo"
mkdir -p /opt/forgejo
RELEASE=$(curl -s https://codeberg.org/api/v1/repos/forgejo/forgejo/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+' | sed 's/^v//')
wget -qO /opt/forgejo/forgejo-$RELEASE-linux-amd64 "https://codeberg.org/forgejo/forgejo/releases/download/v${RELEASE}/forgejo-${RELEASE}-linux-amd64"
chmod +x /opt/forgejo/forgejo-$RELEASE-linux-amd64
ln -sf /opt/forgejo/forgejo-$RELEASE-linux-amd64 /usr/local/bin/forgejo
msg_ok "Installed Forgejo"

msg_info "Setting up Forgejo"
$STD adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git  git
mkdir /var/lib/forgejo
chown git:git /var/lib/forgejo && chmod 750 /var/lib/forgejo
mkdir /etc/forgejo
chown root:git /etc/forgejo && chmod 770 /etc/forgejo
echo "" >>~/forgejo.creds
echo -e "Forgejo GIT User: \e[32mgit\e[0m" >>~/forgejo.creds
echo -e "Forgejo data directory: \e[32m/var/lib/forgejo\e[0m" >>~/forgejo.creds
msg_ok "Setup Forgejo"

read -r -p "Forgejo uses SQLite by default. Would you like to use another database? <y/N> " prompt
if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
  DB_NAME=forgejodb
  DB_USER=forgejo
  DB_PASS="$(openssl rand -base64 18 | cut -c1-13)"

  PS3="Please enter your choice: "
  select DB_CHOICE in "PostgreSQL" "MySQL" "MariaDB"; do
    case $DB_CHOICE in
      "PostgreSQL")
        msg_info "Setting up PostgreSQL"
        $STD apt-get install -y postgresql
        echo "" >>~/forgejo.creds
        echo -e "Database Type: \e[32mPostgresQL\e[0m" >>~/forgejo.creds
        echo -e "PostgresQL Database Host: \e[32m127.0.0.1:5432\e[0m" >>~/forgejo.creds
        echo -e "Forgejo PostgresQL Database User: \e[32m$DB_USER\e[0m" >>~/forgejo.creds
        echo -e "Forgejo PostgresQL Database Password: \e[32m$DB_PASS\e[0m" >>~/forgejo.creds
        echo -e "Forgejo PostgresQL Database Name: \e[32m$DB_NAME\e[0m" >>~/forgejo.creds
        $STD sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';"
        $STD sudo -u postgres psql -c "CREATE DATABASE $DB_NAME WITH OWNER $DB_USER ENCODING 'UTF8' TEMPLATE template0;"
        $STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET client_encoding TO 'utf8';"
        $STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';"
        $STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET timezone TO 'UTC'"
        HBA_FILE=$(sudo -u postgres psql -t -P format=unaligned -c 'SHOW hba_file' 2>/dev/null)
        tee -a "$HBA_FILE" > /dev/null <<EOL
# Allow Forgejo database user to access the database
local   forgejodb       forgejo         scram-sha-256
host    forgejodb       forgejo         127.0.0.1/32            scram-sha-256  # IPv4 local connections
host    forgejodb       forgejo         ::1/128                 scram-sha-256  # IPv6 local connections
EOL
        $STD systemctl restart postgresql
        msg_ok "Setup PostgreSQL"
        break
        ;;
      "MySQL")
        msg_info "Setting up MySQL"
        $STD apt-get install -y mysql-server
        ADMIN_PASS="$(openssl rand -base64 18 | cut -c1-13)"
        echo "" >>~/forgejo.creds
        echo -e "Database Type: \e[32mMySQL\e[0m" >>~/forgejo.creds
        echo -e "MySQL Database Host: \e[32m127.0.0.1:3306\e[0m" >>~/forgejo.creds
        echo -e "MySQL Admin Password: \e[32m$ADMIN_PASS\e[0m" >>~/forgejo.creds
        echo -e "Forgejo MySQL Database User: \e[32m$DB_USER\e[0m" >>~/forgejo.creds
        echo -e "Forgejo MySQL Database Password: \e[32m$DB_PASS\e[0m" >>~/forgejo.creds
        echo -e "Forgejo MySQL Database Name: \e[32m$DB_NAME\e[0m" >>~/forgejo.creds
        mysql -uroot -p"$ADMIN_PASS" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ADMIN_PASS'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION; CREATE USER '$DB_USER' IDENTIFIED BY '$DB_PASS'; CREATE DATABASE $DB_NAME CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'; FLUSH PRIVILEGES;"
        $STD systemctl restart mysql
        msg_ok "Setup MySQL"
        break
        ;;
      "MariaDB")
        msg_info "Setting up MariaDB"
        $STD apt-get install -y mariadb-server
        ADMIN_PASS="$(openssl rand -base64 18 | cut -c1-13)"
        echo "" >>~/forgejo.creds
        echo -e "Database Type: \e[32mMariaDB\e[0m" >>~/forgejo.creds
        echo -e "MariaDB Database Host: \e[32mlocalhost:3306\e[0m" >>~/forgejo.creds
        echo -e "MariaDB Admin Password: \e[32m$ADMIN_PASS\e[0m" >>~/forgejo.creds
        echo -e "Forgejo MariaDB Database User: \e[32m$DB_USER\e[0m" >>~/forgejo.creds
        echo -e "Forgejo MariaDB Database Password: \e[32m$DB_PASS\e[0m" >>~/forgejo.creds
        echo -e "Forgejo MariaDB Database Name: \e[32m$DB_NAME\e[0m" >>~/forgejo.creds
        mariadb -uroot -p"$ADMIN_PASS" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ADMIN_PASS'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION; CREATE USER '$DB_USER' IDENTIFIED BY '$DB_PASS'; CREATE DATABASE $DB_NAME CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'; FLUSH PRIVILEGES;"
        $STD systemctl restart mariadb
        msg_ok "Setup MariaDB"
        break
        ;;
      *)
        echo "Invalid option. Please select again."
        ;;
    esac
  done
else
  msg_ok "Database ${BL}SQLite${CL} will be used"
fi

if [[ -n "${DB_CHOICE:-}" ]]; then
  read -r -p "Would you like to add Adminer? <y/N> " prompt
  if [[ "${prompt,,}" =~ ^(y|yes)$ ]]; then
    msg_info "Installing Adminer"
    $STD apt install -y adminer
    $STD a2enconf adminer
    systemctl reload apache2
    IP=$(hostname -I | awk '{print $1}')
    echo "" >>~/forgejo.creds
    echo -e "Adminer Interface: \e[32m$IP/adminer/\e[0m" >>~/forgejo.creds
    if [[ "$DB_CHOICE" == "PostgreSQL" ]]; then
      echo -e "Adminer System: \e[32mPostgreSQL\e[0m" >>~/forgejo.creds
      echo -e "Adminer Server: \e[32mlocalhost:5432\e[0m" >>~/forgejo.creds
    elif [[ "$DB_CHOICE" == "MySQL" || "$DB_CHOICE" == "MariaDB" ]]; then
      echo -e "Adminer System: \e[32mMySQL\e[0m" >>~/forgejo.creds
      echo -e "Adminer Server: \e[32mlocalhost:3306\e[0m" >>~/forgejo.creds
    fi
    echo -e "Adminer Username: \e[32m$DB_USER\e[0m" >>~/forgejo.creds
    echo -e "Adminer Password: \e[32m$DB_PASS\e[0m" >>~/forgejo.creds
    echo -e "Adminer Database: \e[32m$DB_NAME\e[0m" >>~/forgejo.creds
    msg_ok "Installed Adminer"
  fi
fi

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/forgejo.service
[Unit]
Description=Forgejo
After=syslog.target
After=network.target
$(if [[ -n "${DB_CHOICE:-}" && "${DB_CHOICE}" == "PostgreSQL" ]]; then
echo -e "Wants=postgresql.service"
echo -e "After=postgresql.service"
fi)
$(if [[ -n "${DB_CHOICE:-}" && "$DB_CHOICE" == "MySQL" ]]; then
echo -e "Wants=mysql.service"
echo -e "After=mysql.service"
fi)
$(if [[ -n "${DB_CHOICE:-}" && "$DB_CHOICE" == "MariaDB" ]]; then
echo -e "Wants=mariadb.service"
echo -e "After=mariadb.service"
fi)
[Service]
# Uncomment the next line if you have repos with lots of files and get a HTTP 500 error because of that
# LimitNOFILE=524288:524288
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/forgejo/ 
ExecStart=/usr/local/bin/forgejo web --config /etc/forgejo/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/forgejo
[Install]
WantedBy=multi-user.target
EOF
$STD systemctl enable --now forgejo
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
