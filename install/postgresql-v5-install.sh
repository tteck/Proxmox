#!/usr/bin/env bash
if [ "$VERBOSE" == "yes" ]; then set -x;  STD=""; fi
if [ "$VERBOSE" != "yes" ]; then STD="silent"; fi
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
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
function error_handler() {
  local exit_code="$?"
  local line_number="$1"
  local command="$2"
  local error_message="${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}: while executing command ${YW}$command${CL}"
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

msg_info "Setting up Container OS "
sed -i "/$LANG/ s/\(^# \)//" /etc/locale.gen
locale-gen >/dev/null
for ((i=RETRY_NUM; i>0; i--)); do
  if [ "$(hostname -I)" != "" ]; then
    break
  fi
  echo 1>&2 -en "${CROSS}${RD} No Network! "
  sleep $RETRY_EVERY
done
if [ "$(hostname -I)" = "" ]; then
  echo 1>&2 -e "\n${CROSS}${RD} No Network After $RETRY_NUM Tries${CL}"
  echo -e " 🖧  Check Network Settings"
  exit 1
fi
msg_ok "Set up Container OS"
msg_ok "Network Connected: ${BL}$(hostname -I)"

set +e
if nc -zw1 8.8.8.8 443; then msg_ok "Internet Connected"; else
  msg_error "Internet NOT Connected"
    read -r -p "Would you like to continue anyway? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
      echo -e " ⚠️  ${RD}Expect Issues Without Internet${CL}"
    else
      echo -e " 🖧  Check Network Settings"
      exit 1
    fi
fi
RESOLVEDIP=$(nslookup "github.com" | awk -F':' '/^Address: / { matched = 1 } matched { print $2}' | xargs)
if [[ -z "$RESOLVEDIP" ]]; then msg_error "DNS Lookup Failure"; else msg_ok "DNS Resolved github.com to ${BL}$RESOLVEDIP${CL}"; fi
set -e

msg_info "Updating Container OS"
$STD apt-get update
$STD apt-get -y upgrade
msg_ok "Updated Container OS"

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y gnupg
msg_ok "Installed Dependencies"

msg_info "Setting up PostgreSQL Repository"
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
$STD apt-key add <(curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc)
msg_ok "Setup PostgreSQL Repository"

msg_info "Installing PostgreSQL"
$STD apt-get update
$STD apt-get install -y postgresql

cat <<EOF >/etc/postgresql/15/main/pg_hba.conf
# PostgreSQL Client Authentication Configuration File
local   all             postgres                                peer
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             0.0.0.0/24              md5
# IPv6 local connections:
host    all             all             ::1/128                 scram-sha-256
host    all             all             0.0.0.0/0               md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
EOF

cat <<EOF >/etc/postgresql/15/main/postgresql.conf
# -----------------------------
# PostgreSQL configuration file
# -----------------------------

#------------------------------------------------------------------------------
# FILE LOCATIONS
#------------------------------------------------------------------------------

data_directory = '/var/lib/postgresql/15/main'       
hba_file = '/etc/postgresql/15/main/pg_hba.conf'     
ident_file = '/etc/postgresql/15/main/pg_ident.conf'   
external_pid_file = '/var/run/postgresql/15-main.pid'                   

#------------------------------------------------------------------------------
# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------------------

# - Connection Settings -

listen_addresses = '*'                 
port = 5432                             
max_connections = 100                  
unix_socket_directories = '/var/run/postgresql' 

# - SSL -

ssl = on
ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'

#------------------------------------------------------------------------------
# RESOURCE USAGE (except WAL)
#------------------------------------------------------------------------------

shared_buffers = 128MB                
dynamic_shared_memory_type = posix      

#------------------------------------------------------------------------------
# WRITE-AHEAD LOG
#------------------------------------------------------------------------------

max_wal_size = 1GB
min_wal_size = 80MB

#------------------------------------------------------------------------------
# REPORTING AND LOGGING
#------------------------------------------------------------------------------

# - What to Log -

log_line_prefix = '%m [%p] %q%u@%d '           
log_timezone = 'Etc/UTC'

#------------------------------------------------------------------------------
# PROCESS TITLE
#------------------------------------------------------------------------------

cluster_name = '15/main'                

#------------------------------------------------------------------------------
# CLIENT CONNECTION DEFAULTS
#------------------------------------------------------------------------------

# - Locale and Formatting -

datestyle = 'iso, mdy'
timezone = 'Etc/UTC'
lc_messages = 'C'                      
lc_monetary = 'C'                       
lc_numeric = 'C'                        
lc_time = 'C'                           
default_text_search_config = 'pg_catalog.english'

#------------------------------------------------------------------------------
# CONFIG FILE INCLUDES
#------------------------------------------------------------------------------

include_dir = 'conf.d'                  
EOF

sudo systemctl restart postgresql
msg_ok "Installed PostgreSQL"

read -r -p "Would you like to add Adminer? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
  ADMINER="Y"
else
  ADMINER="N"
fi

if [[ $ADMINER == "Y" ]]; then
  msg_info "Installing Adminer"
  $STD apt install -y adminer
  $STD sudo a2enconf adminer
  $STD systemctl reload apache2
  msg_ok "Installed Adminer"
fi

echo "export TERM='xterm-256color'" >>/root/.bashrc
if ! getent shadow root | grep -q "^root:[^\!*]"; then
  msg_info "Customizing Container"
if [ "$PCT_OSTYPE" == "debian" ]; then rm -rf /etc/motd /etc/update-motd.d/10-uname; else chmod -x /etc/update-motd.d/*; fi
  touch ~/.hushlogin
  GETTY_OVERRIDE="/etc/systemd/system/container-getty@1.service.d/override.conf"
  mkdir -p $(dirname $GETTY_OVERRIDE)
  cat <<EOF >$GETTY_OVERRIDE
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear --keep-baud tty%I 115200,38400,9600 \$TERM
EOF
  systemctl daemon-reload
  systemctl restart $(basename $(dirname $GETTY_OVERRIDE) | sed 's/\.d//')
  msg_ok "Customized Container"
fi
if [[ "${SSH_ROOT}" == "yes" ]]; then sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config; systemctl restart sshd; fi

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
