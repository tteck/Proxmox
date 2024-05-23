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
$STD apt-get install -y tzdata
$STD apt-get install -y git
$STD apt-get install -y tini
msg_ok "Installed Dependencies"

var_recyclarr_url="https://github.com/recyclarr/recyclarr/releases/latest/download/recyclarr-linux-x64.tar.xz"
var_app_dir="/opt/recyclarr"
var_app_file="$var_app_dir/recyclarr"
var_config_file="$var_app_dir/recyclarr.yml"
var_recyclarr_cron_file="$var_app_dir/recyclarr.cron"

msg_info "Installing Alpine-Recyclarr"
mkdir -p "$var_app_dir"
chmod 775 "$var_app_dir"
wget "$var_recyclarr_url" -O - | tar xJ --overwrite -C "$var_app_dir"
msg_ok "Installed Alpine-Recyclarr"

msg_info "Configuring Alpine-Recyclarr"
chmod +x "$var_app_file"
export PATH="${PATH}:$var_app_dir"
recyclarr config create --path "$var_config_file"

cat <<EOF >$var_recyclarr_cron_file
#!/usr/bin/env bash
echo
echo "-------------------------------------------------------------"
echo " Executing Tasks: $(date)"
echo "-------------------------------------------------------------"
export PATH="\${PATH}:$var_app_dir"
export RECYCLARR_APP_DATA="$var_app_dir"
export COMPlus_EnableDiagnostics=0

recyclarr sync
EOF
chmod +x "$var_recyclarr_cron_file"
msg_ok "Configured Alpine-Recyclarr"

msg_info "Scheduling Alpine-Recyclarr with Crontab"
echo "1 6     * * *   root    $var_recyclarr_cron_file" >> /etc/crontab
msg_ok "Scheduled Alpine-Recyclarr with Crontab"

motd_ssh
customize
