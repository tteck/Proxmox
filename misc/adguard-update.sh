#!/usr/bin/env bash
echo -e "\nStarting Update\n"
sleep 3
wget -q --show-progress https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz
tar -xvf AdGuardHome_linux_amd64.tar.gz &>/dev/null
systemctl stop AdGuardHome
mkdir -p adguard-backup
cp -r /opt/AdGuardHome/AdGuardHome.yaml /opt/AdGuardHome/data adguard-backup/
cp AdGuardHome/AdGuardHome /opt/AdGuardHome/AdGuardHome
cp -r adguard-backup/* /opt/AdGuardHome/
systemctl start AdGuardHome
rm -rf AdGuardHome_linux_amd64.tar.gz AdGuardHome adguard-backup
echo -e "\nFinished\n"
