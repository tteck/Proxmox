#!/bin/sh
set -e
dotnetDir="/opt/dotnet"
dnsDir="/etc/dns"
dnsTar="/etc/dns/DnsServerPortable.tar.gz"
dnsUrl="https://download.technitium.com/dns/DnsServerPortable.tar.gz"

mkdir -p $dnsDir
installLog="$dnsDir/install.log"
echo "" > $installLog

echo ""
echo "==============================="
echo "Technitium DNS Server Update"
echo "==============================="

if dotnet --list-runtimes 2> /dev/null | grep -q "Microsoft.NETCore.App 6.0."; 
then
	dotnetFound="yes"
else
	dotnetFound="no"
fi

	if [ -d $dotnetDir ]
	then
	    dotnetUpdate="yes"
		echo "Updating .NET 6 Runtime..."
	fi

	curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin -c 6.0 --runtime dotnet --no-path --install-dir $dotnetDir --verbose >> $installLog 2>&1

	if [ ! -f "/usr/bin/dotnet" ]
	then
		ln -s $dotnetDir/dotnet /usr/bin >> $installLog 2>&1
	fi

	if dotnet --list-runtimes 2> /dev/null | grep -q "Microsoft.NETCore.App 6.0."; 
	then
		if [ "$dotnetUpdate" = "yes" ]
		then
			echo ".NET 6 Runtime was updated successfully!"
		fi
	else
		echo "Failed to update .NET 6 Runtime. Please try again."
		exit 1
	fi

if curl -o $dnsTar --fail $dnsUrl >> $installLog 2>&1
then
	if [ -d $dnsDir ]
	then
		echo "Updating Technitium DNS Server..."
	fi
	
	tar -zxf $dnsTar -C $dnsDir >> $installLog 2>&1
	
	if [ "$(ps --no-headers -o comm 1 | tr -d '\n')" = "systemd" ] 
	then
		if [ -f "/etc/systemd/system/dns.service" ]
		then
			echo "Restarting systemd service..."
			systemctl restart dns.service >> $installLog 2>&1
		fi
	
		echo ""
		echo "Technitium DNS Server was updated successfully!"
	else
		echo ""
		echo "Failed to update Technitium DNS Server: systemd was not detected."
		exit 1
	fi
else
	echo ""
	echo "Failed to download Technitium DNS Server from: $dnsUrl"
	exit 1
fi
