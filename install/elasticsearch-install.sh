#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: T.H. (ELKozel)
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
$STD apt-get install -y wget
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y ca-certificates
$STD apt-get install apt-transport-https
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

msg_info "Setting up Elastic Repository"
mkdir -p /etc/apt/keyrings
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" >/etc/apt/sources.list.d/elastic-8.x.list
msg_ok "Set up Elastic Repository"

msg_info "Installing Elastcisearch"
$STD apt-get update
$STD apt-get install elasticsearch
msg_ok "Installed Elastcisearch"

msg_info "Configuring Elasticsearch Memory"
$STD sed -i -E 's/## -Xms[0-9]+[Ggm]/-Xms3g/' /etc/elasticsearch/jvm.options
$STD sed -i -E 's/## -Xmx[0-9]+[Ggm]/-Xmx3g/' /etc/elasticsearch/jvm.options
msg_ok "Elastcisearch Configured to user 3GB of RAM, adjust if needed by editing /etc/elasticsearch/jvm.options"

msg_info "Creating Service"
$STD /bin/systemctl daemon-reload
$STD /bin/systemctl enable elasticsearch.service
$STD /bin/systemctl start elasticsearch.service
msg_ok "Created Service"

msg_info "Checking Health"
ELASTIC_USER=elastic
ELASTIC_PASSWORD=$(/usr/share/elasticsearch/bin/elasticsearch-reset-password -u $ELASTIC_USER -b -s -f)
ELASTIC_IP=$IP
ELASTIC_PORT=9200
echo $ELASTIC_USER
echo $ELASTIC_PASSWORD
echo $ELASTIC_IP
curl -XGET --insecure --fail --user $ELASTIC_USER:$ELASTIC_PASSWORD https://$ELASTIC_IP:$ELASTIC_PORT/_cluster/health?pretty
msg_ok "Checked Health"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
