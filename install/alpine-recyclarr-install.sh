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
$STD apk add newt
$STD apk add curl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
$STD apk add bash
$STD apk add tzdata
$STD apk add supercronic
$STD apk add git
$STD apk add tini
msg_ok "Installed Dependencies"

var_recyclarr_url="https://github.com/recyclarr/recyclarr/releases/latest/download/recyclarr-linux-x64.tar.xz"
var_config="/opt/recyclarr"
var_recyclarr_cron_path="/etc/periodic/daily/recyclarr"

msg_info "Installing Alpine-Recyclarr"
curl -s -L "$var_recyclarr_url" | tar xJ --overwrite -C /usr/local/bin
msg_ok "Installed Alpine-Recyclarr"

msg_info "Creating Alpine-Recyclarr Config at $var_config"
mkdir -p "$var_config"
recyclarr config create --path "$var_config/recyclarr.yml"
msg_info "Created Alpine-Recyclarr Config at $var_config"

msg_info "Scheduling Alpine-Recyclarr in $var_recyclarr_cron_path"
cat <<EOF >$var_recyclarr_cron_path
#!/usr/bin/env bash
echo
echo "-------------------------------------------------------------"
echo " Executing Tasks: $(date)"
echo "-------------------------------------------------------------"
PATH="\${PATH}:/app/recyclarr"
RECYCLARR_APP_DATA=$var_config
COMPlus_EnableDiagnostics=0

recyclarr sync
EOF
msg_info "Scheduled Alpine-Recyclarr in $var_recyclarr_cron_path"

motd_ssh
customize
