#!/usr/bin/env bash
# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/node-red-dark.sh)"
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
trap die ERR
trap 'die "Script interrupted."' INT

function error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR:LXC] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}
clear
echo -en "${GN} Updating Container OS... "
apt-get update &>/dev/null
apt-get -qqy upgrade &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing midnight-red Theme... "
cd /root/.node-red
npm install @node-red-contrib-themes/midnight-red &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Writing Settings... "
cat <<EOF > /root/.node-red/settings.js
module.exports = { uiPort: process.env.PORT || 1880,

    mqttReconnectTime: 15000,

    serialReconnectTime: 15000,

    debugMaxLength: 1000,

    functionGlobalContext: {
    },
    exportGlobalContextKeys: false,


    // Configure the logging output
    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    },

    // Customising the editor
    editorTheme: {
        theme: "midnight-red"
    },
        projects: {
            // To enable the Projects feature, set this value to true
            enabled: true
    }
}
EOF
echo -e "${CM}${CL} \r"

echo -en "${GN} Restarting Node-Red... "
node-red-restart
echo -e "${CM}${CL} \r"

echo -en "${GN} Finished... ${CL} \n"
exit


