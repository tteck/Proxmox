#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
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
$STD apt-get install -y python3 python3-pip imagemagick
msg_ok "Installed Dependencies"

msg_info "Installing calibre-web"
mkdir -p /opt/kepubify
cd /opt/kepubify
curl -fsSLO https://github.com/pgaskin/kepubify/releases/latest/download/kepubify-linux-64bit &>/dev/null
chmod +x kepubify-linux-64bit
mkdir -p /opt/calibre-web
wget https://github.com/janeczku/calibre-web/raw/master/library/metadata.db -P /opt/calibre-web
if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
CHOICES=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "CALIBRE-WEB OPTIONS" --separate-output --checklist "Choose Additional Options" 15 125 8 \
  "1" "Enables gdrive as storage backend for your ebooks" OFF \
  "2" "Enables sending emails via a googlemail account without enabling insecure apps" OFF \
  "3" "Enables displaying of additional author infos on the authors page" OFF \
  "4" "Enables login via LDAP server" OFF \
  "5" "Enables login via google or github oauth" OFF \
  "6" "Enables extracting of metadata from epub, fb2, pdf files, and also extraction of covers from cbr, cbz, cbt files" OFF \
  "7" "Enables extracting of metadata from cbr, cbz, cbt files" OFF \
  "8" "Enables syncing with your kobo reader" OFF 3>&1 1>&2 2>&3)
spinner &
SPINNER_PID=$!
if [ ! -z "$CHOICES" ]; then
  declare -a options
  for CHOICE in $CHOICES; do
    case "$CHOICE" in
    "1")
      options+=( gdrive )
      ;;
    "2")
      options+=( gmail )
      ;;
    "3")
      options+=( goodreads )
      ;;
    "4")
      options+=( ldap )
      apt-get install -qqy libldap2-dev libsasl2-dev
      ;;
    "5")
      options+=( oauth )
      ;;
    "6")
      options+=( metadata )
      ;;
    "7")
      options+=( comics )
      ;;
    "8")
      options+=( kobo )
      ;;
    *)
      echo "Unsupported item $CHOICE!" >&2
      exit 1
      ;;
    esac
  done
fi
if [ ! -z "$options" ] && [ ${#options[@]} -gt 0 ]; then
  cps_options=$(IFS=, ; echo "${options[*]}")
  echo $cps_options > /opt/calibre-web/options.txt
  $STD pip install calibreweb[$cps_options]
else
  $STD pip install calibreweb
fi
msg_ok "Installed calibre-web"

msg_info "Creating Service"
service_path="/etc/systemd/system/cps.service"
echo "[Unit]
Description=Calibre-Web Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/calibre-web
ExecStart=/usr/local/bin/cps
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target" >$service_path
systemctl enable --now -q cps.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"

msg_ok "Default login user: admin"
msg_ok "Default login password: admin123"