#!/usr/bin/env bash

while true; do
    read -p "This will install Intel Drivers on your Plex Media Server LXC. 
    Do you want to Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
function error_exit() {
  trap - ERR
  local DEFAULT='Unknown failure occured.'
  local REASON="\e[97m${1:-$DEFAULT}\e[39m"
  local FLAG="\e[91m[ERROR] \e[93m$EXIT@$LINE"
  msg "$FLAG $REASON"
  exit $EXIT
}
function msg() {
  local TEXT="$1"
  echo -e "$TEXT"
}

mkdir neo

cd neo
wget https://github.com/intel/compute-runtime/releases/download/22.03.22192/intel-gmmlib_22.0.0_amd64.deb
wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.9933/intel-igc-core_1.0.9933_amd64.deb
wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.9933/intel-igc-opencl_1.0.9933_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/22.03.22192/intel-opencl-icd_22.03.22192_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/22.03.22192/intel-level-zero-gpu_1.2.22192_amd64.deb

sudo dpkg -i *.deb






echo -e "\e[1;33m Finished....Please Reboot the LXC to apply the changes \e[0m"


















