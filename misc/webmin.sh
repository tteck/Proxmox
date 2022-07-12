#!/usr/bin/env bash

YW=`echo "\033[33m"`
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
while true; do
    read -p "This will Install Webmin, Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear

echo -en "${GN} Installing Prerequisites... "
apt update &>/dev/null
apt-get -y install libnet-ssleay-perl libauthen-pam-perl libio-pty-perl unzip shared-mime-info &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Downloading Webmin... "
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.996_all.deb &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Installing Webmin... "
dpkg --install webmin_1.996_all.deb &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Setting Default Webmin usermame & password to root... "
/usr/share/webmin/changepass.pl /etc/webmin root root &>/dev/null
rm -rf /root/webmin_1.996_all.deb
echo -e "${CM}${CL} \r"
IP=$(hostname -I | cut -f1 -d ' ')
echo -e    "${BL} Successfully Installed Webmin, Now Go To https://${IP}:10000 ${CL}"


# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/webmin.sh)"
