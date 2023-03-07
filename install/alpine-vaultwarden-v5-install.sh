#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

if [ "$VERBOSE" = "yes" ]; then set -x; STD=""; else STD="silent"; fi
silent() { "$@" > /dev/null 2>&1; }
if [ "$DISABLEIPV6" == "yes" ]; then echo "net.ipv6.conf.all.disable_ipv6 = 1" >>/etc/sysctl.conf; $STD sysctl -p; fi
YW=$(echo "\033[33m")
RD=$(echo "\033[01;31m")
BL=$(echo "\033[36m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
RETRY_NUM=10
RETRY_EVERY=3
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR="\\r\\033[K"
HOLD="-"
set -Eeuo pipefail
trap 'error_handler $LINENO' ERR
function error_handler() {
  local exit_code="$?"
  local line_number="$1"
  local command="$2"
  local error_message="${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}"
  echo -e "\n$error_message\n"
}

function msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

function msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

set +e
trap - ERR

RESOLVEDIP=$(getent hosts github.com | awk '{ print $1 }')
if [[ -z "$RESOLVEDIP" ]]; then msg_error "DNS Lookup Failure"; else msg_ok "DNS Resolved github.com to ${BL}$RESOLVEDIP${CL}"; fi
set -e
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

msg_info "Updating Container OS"
$STD apk update
$STD apk upgrade
msg_ok "Updated Container OS"

msg_info "Installing Dependencies"
$STD apk add bash
$STD apk add curl
$STD apk add openssl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
msg_ok "Installed Dependencies"

msg_info "Installing Vaultwarden"
$STD apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing vaultwarden
cat <<EOF >/etc/conf.d/vaultwarden
export DATA_FOLDER=/var/lib/vaultwarden
export WEB_VAULT_ENABLED=true
export ADMIN_TOKEN=$(openssl rand -base64 48)
export ROCKET_ADDRESS=0.0.0.0
EOF
$STD rc-service vaultwarden start
$STD rc-update add vaultwarden default
msg_ok "Installed Vaultwarden"
echo -e "$APPLICATION LXC provided by https://tteck.github.io/Proxmox/\n" > /etc/motd
if [[ "${SSH_ROOT}" == "yes" ]]; then 
  $STD rc-update add sshd
  $STD /etc/init.d/sshd start
fi
