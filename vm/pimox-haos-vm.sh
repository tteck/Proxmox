#!/bin/bash
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR
function error_exit() {
    REASON=$1
    MSG="\e[91mERROR: \e[93m$EXIT@"
    if [ -z "$REASON" ]; then
        MSG="$MSG$LINE:"
        REASON="Unknown failure occured."
    else
        MSG="$MSG`echo $(( $LINE - 1 ))`:"
    fi
    echo -e "$MSG \e[97m$REASON\e[39m\e[49m"
    exit $EXIT
}
function cleanup() {
    popd >/dev/null
    rm -rf $TMP
}
trap cleanup EXIT
TMP=`mktemp -d`
pushd $TMP >/dev/null

VMID=$(cat<<EOF | python3
import json
with open('/etc/pve/.vmlist') as vmlist:
    vmids = json.load(vmlist)
if 'ids' not in vmids:
    print(100)
else:
    last_vm = sorted(vmids['ids'].keys())[-1:][0]
    print(int(last_vm)+1)
EOF
)
echo -e "Getting latest HAOS Info \n" 
URL=$(cat<<EOF | python3
import requests
url = 'https://api.github.com/repos/home-assistant/hassos/releases/latest'
r = requests.get(url).json()
if 'message' in r:
        exit()
for asset in r['assets']:
        if asset['name'].endswith('qcow2.xz'):
                print(asset['browser_download_url'])
EOF
)
if [ -z "$URL" ]; then
        echo "Github has returned an error. A rate limit may have been applied to your connection. Please wait a while, then try again."
        exit 1
fi

echo -e "Downloading HAOS \n" 
wget -q --show-progress $URL 
FILE=$(basename $URL) 

echo -e "\n Extracting HAOS \n" 
xz -d $FILE

echo -e "Creating new HAOS VM \n" 
qm create $VMID -agent 1 -bios ovmf -cores 2 -memory 4096 -bootdisk scsi0 \
        -efidisk0 local:vm-${VMID}-disk-0,size=128K \
        -name test -net0 virtio,bridge=vmbr0 \
        -onboot 1 -ostype l26 -scsi0 local:vm-${VMID}-disk-1,size=32G \
        -scsihw virtio-scsi-pci && \
pvesm alloc local $VMID vm-${VMID}-disk-0 128 1>&/dev/null && \
qm importdisk $VMID ${FILE%".xz"} local 1>&/dev/null
echo -e "Completed Successfully, New VM ID is $VMID \n" 
