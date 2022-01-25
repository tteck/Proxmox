#!/usr/bin/env bash
while true; do
    read -p "This will Install Webmin, Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'
echo -e "Loading Script..."
echo -e "${CHECKMARK} \e[1;92m Installing Prerequisites... \e[0m"
apt update &>/dev/null
apt-get -y install libnet-ssleay-perl libauthen-pam-perl libio-pty-perl unzip shared-mime-info &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Downloading Webmin... \e[0m"
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.984_all.deb &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Installing Webmin... \e[0m"
dpkg --install webmin_1.984_all.deb &>/dev/null
echo -e "${CHECKMARK} \e[1;92m Setting Default Webmin usermame & password to root... \e[0m"
/usr/share/webmin/changepass.pl /etc/webmin root root &>/dev/null
rm -rf /webmin_1.984_all.deb
echo -e    "Install Complete, Now Go To https:// IP:10000"


# bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/webmin.sh)"
