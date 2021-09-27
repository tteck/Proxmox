<h1 align="center" id="heading"> Select a Proxmox Helper Below </h1>
</details>

<details>
<summary>Home Assistant OS VM</summary>
 
<h1 align="center" id="heading"> Proxmox VM with Home Assistant OS </h1>

To create a new Proxmox VM with the latest version of Home Assistant OS, run the following from Proxmox web shell

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/haos_vm.sh)"
```
### <h3 align="center" id="heading">:zap: Default Settings:  4GB RAM - 32GB Storage - 2vCPU :zap:</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the VM, then on the **_Hardware_** tab and change the **_Memory_** and **_Processors_** settings to what you desire. Once all changes have been made, **_Start_** the VM.

 
</details>

</details>


<details>
<summary>PVE6 Home Assistant Container LXC</summary>

<h1 align="center" id="heading"> Proxmox 6 Home Assistant Container LXC </h1>

To create a new Proxmox 6 Home Assistant Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pve6_ha_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  4GB RAM - 16GB Storage - 2vCPU :zap:</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

For Home Assistant interface http:// (LXC IP) :8123

For Portainer interface http:// (LXC IP) :9000

Path to HA configuration.yaml
```
/var/lib/docker/volumes/hass_config/_data
 ```
[To pass through a device for ZHA](https://github.com/tteck/Proxmox/blob/main/Alternative.md#zha-device-pass-through)

</details>

</details>


<details>
<summary>PVE7 Home Assistant Container LXC</summary>

<h1 align="center" id="heading"> Proxmox 7 Home Assistant Container LXC </h1>

To create a new Proxmox 7 Home Assistant Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pve7_ha_container.sh)"
```
 
<h3 align="center" id="heading">:zap: Default Settings:  4GB RAM - 16GB Storage - 2vCPU :zap:</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

For Home Assistant interface http:// (LXC IP) :8123

For Portainer interface http:// (LXC IP) :9000

Path to HA configuration.yaml
```
/var/lib/docker/volumes/hass_config/_data
 ```
[To pass through a device for ZHA](https://github.com/tteck/Proxmox/blob/main/Alternative.md#zha-device-pass-through)
 
</details>

</details>


<details>
<summary>ESPHome LXC</summary>

<h1 align="center" id="heading"> Proxmox ESPHome LXC Container </h1>

To create a new Proxmox ESPHome LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/esphome_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 2vCPU :zap:</h3>
 
For ESPHome interface http:// (LXC IP) :6052
 
</details>

</details>


<details>
<summary>Nginx Proxy Manager LXC</summary>

<h1 align="center" id="heading"> Proxmox Nginx Proxy Manager LXC Container </h1>

To create a new Proxmox Nginx Proxy Manager LXC Container, run the following from Proxmox web shell.

```
 curl -sL https://raw.githubusercontent.com/ej52/proxmox/main/lxc/nginx-proxy-manager/create.sh | bash -s
```
<h3 align="center" id="heading">:zap: Alpine  Default Settings:  512MiB RAM - 2GB Storage - 1vCPU :zap:</h3>

____________________________________________________________________________________
 
Forward port `80` and `443` from your router to your Nginx Proxy Manager LXC IP.

Add the following to your `configuration.yaml` in Home Assistant.
```
 http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.100.27 ###(Nginx Proxy Manager LXC IP)###
```

**Initial Login**

**username** 
 ```
 admin@example.com
 ```
 **password** 
 ```
 changeme
 ```
 
Thanks to [ej52](https://github.com/ej52/proxmox-scripts/blob/main/lxc/nginx-proxy-manager/README.md) for his hard work.

 
</details>

</details>


<details>
<summary>MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox MQTT LXC Container </h1>

To create a new Proxmox MQTT LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/mqtt_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  512MiB RAM - 2GB Storage - 1vCPU :zap:</h3>
 
Mosquitto comes with a password file generating utility called mosquitto_passwd.
```
sudo mosquitto_passwd -c /etc/mosquitto/passwd <usr>
```
Password: < password >

Create a configuration file for Mosquitto pointing to the password file we have just created.
```
sudo nano /etc/mosquitto/conf.d/default.conf
```
This will open an empty file. Paste the following into it.
```
allow_anonymous false
persistence true
password_file /etc/mosquitto/passwd
listener 1883
```
Save and exit the text editor with "Ctrl+O", "Enter" and "Ctrl+X".

Now restart Mosquitto server.
```
sudo systemctl restart mosquitto
```

 
</details>


</details>


<details>
<summary>Node-Red LXC</summary>

<h1 align="center" id="heading"> Proxmox Node-Red LXC Container </h1>

To create a new Proxmox Node-RED LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/node-red_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 1vCPU :zap:</h3>
 
</details>

 </details>


<details>
<summary>Mariadb 10.5 LXC</summary>

<h1 align="center" id="heading"> Proxmox Mariadb 10.5 LXC Container </h1>

To create a new Proxmox Mariadb LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/mariadb_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 1vCPU :zap:</h3>
 
To enable MariaDB to listen to remote connections, you need to edit your defaults file. To do this, open the console in your MariaDB lxc:
```
nano /etc/mysql/my.cnf
```
Un-comment `port =3306`
Save and exit the editor with "Ctrl+O", "Enter" and "Ctrl+X".

```
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```
Comment `bind-address  = 127.0.0.1`
Save and exit the editor with "Ctrl+O", "Enter" and "Ctrl+X".

For new MariaDB installations, the next step is to run the included security script. This script changes some of the less secure default options. We will use it to block remote root logins and to remove unused database users.

Run the security script:
```
sudo mysql_secure_installation
```
Enter current password for root (enter for none): `enter`
 
Switch to unix_socket authentication [Y/n] `y` 
 
Change the root password? [Y/n] `n` 
 
Remove anonymous users? [Y/n] `y` 
 
Disallow root login remotely? [Y/n] `y` 
 
Remove test database and access to it? [Y/n] `y` 
 
Reload privilege tables now? [Y/n] `y` 

We will create a new account called admin with the same capabilities as the root account, but configured for password authentication. 
```
sudo mysql
``` 
Prompt will change to ```MariaDB [(none)]>```

Create a new local admin (Change the username and password to match your preferences)
```
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
```
Give local admin root privileges (Change the username and password to match above)
```
GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
```

Now, we'll give the user admin root privileges and password-based access that can connect from anywhere on your local area network (LAN), which has addresses in the subnet 192.168.100.0/24. This is an improvement because opening a MariaDB server up to the Internet and granting access to all hosts is bad practice.. Change the **_username_**, **_password_** and **_subnet_** to match your preferences:
```
GRANT ALL ON *.* TO 'admin'@'192.168.100.%' IDENTIFIED BY 'password' WITH GRANT OPTION;
```
Flush the privileges to ensure that they are saved and available in the current session:
```
FLUSH PRIVILEGES;
```
Following this, exit the MariaDB shell:
```
exit
```
Log in as the new database user you just created:
```
mysql -u admin -p
```
Create a new database:
```
CREATE DATABASE homeassistant;
```
Following this, exit the MariaDB shell:
```
exit
```
:warning: Reboot the lxc 

Checking status.
```
sudo systemctl status mariadb
``` 
Change the recorder: `db_url:` in your HA configuration.yaml
 
Example: `mysql://admin:password@192.168.100.26:3306/homeassistant?charset=utf8mb4`
 

</details>



</details>


<details>
<summary>PVE6 Zigbee2MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox PVE6 Zigbee2MQTT LXC Container </h1>

To create a new Proxmox 6 [Zigbee2MQTT](https://www.zigbee2mqtt.io/) LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pve6_zigbee2mqtt_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 2vCPU :zap:</h3>
 
Determine the location of your adapter (Run in the zigbee2mqtt console)
```
ls -l /dev/serial/by-id
```
Example Output: ```lrwxrwxrwx 1 root root 13 Jun 19 17:30 usb-1a86_USB_Serial-if00-port0 -> ../../ttyUSB0```
 
 If you are having diffucuilty with device pass through or starting check the [Alternative method](https://github.com/tteck/Proxmox/blob/main/Alternative.md)

:warning: **Before you can start Zigbee2MQTT you need to edit the [configuration.yaml](https://www.zigbee2mqtt.io/information/configuration.html)**
```
nano /opt/zigbee2mqtt/data/configuration.yaml
```

Example:
```
frontend:
  port: 9442
homeassistant: true
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: 'mqtt://192.168.86.224:1883'
  user: usr
  password: pwd
  keepalive: 60
  reject_unauthorized: true
  version: 4
serial:
  port: /dev/serial/by-id/usb-1a86_USB_Serial-if00-port0
advanced:
  pan_id: GENERATE
  network_key: GENERATE
  channel: 20
  ```
Zigbee2mqtt can be started after completing the configuration by running
```
sudo systemctl start zigbee2mqtt
```
To start Zigbee2MQTT automatically on boot
 ```
 sudo systemctl enable zigbee2mqtt.service
 ```
To update Zigbee2Mqtt
 ```
 cd /opt/zigbee2mqtt
 bash update.sh
 ```

</details>

</details>


<details>
<summary>PVE7 Zigbee2MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox PVE7 Zigbee2MQTT LXC Container </h1>

To create a new Proxmox 7 [Zigbee2MQTT](https://www.zigbee2mqtt.io/) LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pve7_zigbee2mqtt_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 2vCPU :zap:</h3>
 
Determine the location of your adapter (Run in the zigbee2mqtt console)
```
ls -l /dev/serial/by-id
```
Example Output: ```lrwxrwxrwx 1 root root 13 Jun 19 17:30 usb-1a86_USB_Serial-if00-port0 -> ../../ttyUSB0```

 If you are having diffucuilty with device pass through or starting check the [Alternative method](https://github.com/tteck/Proxmox/blob/main/Alternative.md)

 :warning: **Before you can start Zigbee2MQTT you need to edit the [configuration.yaml](https://www.zigbee2mqtt.io/information/configuration.html)**
```
nano /opt/zigbee2mqtt/data/configuration.yaml
```

Example:
```
frontend:
  port: 9442
homeassistant: true
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: 'mqtt://192.168.86.224:1883'
  user: usr
  password: pwd
  keepalive: 60
  reject_unauthorized: true
  version: 4
serial:
  port: /dev/serial/by-id/usb-1a86_USB_Serial-if00-port0
advanced:
  pan_id: GENERATE
  network_key: GENERATE
  channel: 20
  ```
Zigbee2mqtt can be started after completing the configuration by running
```
sudo systemctl start zigbee2mqtt
```
To start Zigbee2MQTT automatically on boot
 ```
 sudo systemctl enable zigbee2mqtt.service
 ```
 To update Zigbee2Mqtt
 ```
 cd /opt/zigbee2mqtt
 bash update.sh
 ```

</details>

</details>


<details>
<summary>Base Debian 10 LXC</summary>

<h1 align="center" id="heading"> Proxmox Debian 10 LXC Container </h1>

To create a new Proxmox Debian 10 (curl. sudo, auto login) LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/debian10_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  512MiB RAM - 2GB Storage - 1vCPU :zap:</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

</details>

</details>


<details>
<summary>Base Debian 11 LXC</summary>

<h1 align="center" id="heading"> Proxmox Debian 11 LXC Container </h1>

To create a new Proxmox Debian 11 (curl. sudo, auto login) LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/debian11_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  512MiB RAM - 2GB Storage - 1vCPU :zap:</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

</details>


</details>


<details>
<summary>PVE7 Post Install</summary>

<h1 align="center" id="heading"> Proxmox PVE7 Post Install </h1>

This script will Disable the Enterprise Repo, Add & Enable the No-Subscription Repo, Add & Disable Test Repo (repo's can be enabled/disabled via the UI in Repositories) 
and attempt the *No-Nag* fix. 
 
Run the following in the Proxmox Web Shell. ⚠️ *_PVE7 ONLY_*

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/post_install.sh)"
```

I recommend updating Proxmox after running this script, before adding any VM/CT.

</details>
