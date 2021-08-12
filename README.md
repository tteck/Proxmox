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

<h1 align="center" id="heading"> Proxmox 6 Home Assistant LXC Container </h1>

To create a new Proxmox 6 Home Assistant Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pve6_ha_container.sh)"
```
<h3 align="center" id="heading">:zap: Default Settings:  4GB RAM - 32GB Storage - 2vCPU :zap:</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

For Home Assistant interface http:// (LXC IP) :8123

For Portainer interface http:// (LXC IP) :9000

Path to HA configuration.yaml
```
/var/lib/docker/volumes/hass_config/_data
 ```

</details>

</details>


<details>
<summary>PVE7 Home Assistant Container LXC</summary>

<h1 align="center" id="heading"> Proxmox 7 Home Assistant LXC Container </h1>

To create a new Proxmox 7 Home Assistant Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pve7_ha_container.sh)"
```
 
<h3 align="center" id="heading">:zap: Default Settings:  4GB RAM - 32GB Storage - 2vCPU :zap:</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

For Home Assistant interface http:// (LXC IP) :8123

For Portainer interface http:// (LXC IP) :9000

Path to HA configuration.yaml
```
/var/lib/docker/volumes/hass_config/_data
 ```
 
</details>

</details>


<details>
<summary>ESPHome LXC</summary>

<h1 align="center" id="heading"> Proxmox ESPHome LXC Container </h1>

To create a new Proxmox ESPHome LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/esphome_container.sh)"
```

 
</details>


</details>


<details>
<summary>MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox MQTT LXC Container </h1>

To create a new Proxmox MQTT LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/mqtt_container.sh)"
```
### The commands below are entered through the newly created mqtt lxc console.
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
password_file /etc/mosquitto/passwd
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

 
</details>

 </details>


<details>
<summary>Mariadb LXC</summary>

<h1 align="center" id="heading"> Proxmox Mariadb LXC Container </h1>

To create a new Proxmox Mariadb LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/mariadb_container.sh)"
```
To enable MariaDB to listen to remote connections, you need to edit your defaults file. To do this, open the console in your MariaDB lxc:
```
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```
Un-comment port, and comment skip-networking and bind-address. (match below)
```user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
socket                  = /run/mysqld/mysqld.sock
port                    = 3306
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql
# skip-external-locking
# skip-networking
# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
# bind-address            = 127.0.0.1
```

For new MariaDB installations, the next step is to run the included security script. This script changes some of the less secure default options. We will use it to block remote root logins and to remove unused database users.

Run the security script:
```
sudo mysql_secure_installation
```
This will take you through a series of prompts where you can make some changes to your MariaDB installation’s security options. The first prompt will ask you to enter the current database root password. Since we have not set one up yet, press ENTER to indicate “none”.

The next prompt asks you whether you’d like to set up a database root password. Type N and then press ENTER. In Debian, the root account for MariaDB is tied closely to automated system maintenance, so we should not change the configured authentication methods for that account. Doing so would make it possible for a package update to break the database system by removing access to the administrative account. Later, we will cover how to optionally set up an additional administrative account for password access if socket authentication is not appropriate for your use case.

From there, you can press Y and then ENTER to accept the defaults for all the subsequent questions. This will remove some anonymous users and the test database, disable remote root logins, and load these new rules so that MariaDB immediately respects the changes you have made.


The root MariaDB user is set to authenticate using the unix_socket plugin by default rather than with a password. This allows for some greater security and usability in many cases, but it can also complicate things when you need to allow an external program (e.g., phpMyAdmin) administrative rights.

Because the server uses the root account for tasks like log rotation and starting and stopping the server, it is best not to change the root account’s authentication details. Changing credentials in the /etc/mysql/debian.cnf configuration file may work initially, but package updates could potentially overwrite those changes. Instead of modifying the root account, the package maintainers recommend creating a separate administrative account for password-based access.

To do so, we will create a new account called admin with the same capabilities as the root account, but configured for password authentication. 
```
sudo mysql
``` 
Prompt will change to ```MariaDB [(none)]>```

Now, we will create the user admin with root privileges and password-based access that can connect from anywhere on my local area network (LAN), which has addresses in the subnet 192.168.100.0/24. This is an improvement because opening a MariaDB server up to the Internet and granting access to all hosts is bad practice.. Change the username, password and subnet to match your preferences:
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
Checking status.
```
sudo systemctl status mariadb
``` 
Change your recorder: db_url: in the HA configuration.yaml ```mysql://admin:password@192.168.100.lxc-ip:3306/homeassistant?charset=utf8mb4```

 
</details>

</details>


<details>
<summary>PVE6 Zigbee2MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox PVE6 Zigbee2MQTT LXC Container </h1>

To create a new Proxmox 6 [Zigbee2MQTT](https://www.zigbee2mqtt.io/) LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pve6_zigbee2mqtt_container.sh)"
```

Determine the location of your adapter (Run in the zigbee2mqtt console)
```
ls -l /dev/serial/by-id
```
Example Output: ```lrwxrwxrwx 1 root root 13 Jun 19 17:30 usb-1a86_USB_Serial-if00-port0 -> ../../ttyUSB0```

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
 
</details>

</details>


<details>
<summary>PVE7 Zigbee2MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox PVE7 Zigbee2MQTT LXC Container </h1>

To create a new Proxmox 7 [Zigbee2MQTT](https://www.zigbee2mqtt.io/) LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pve7_zigbee2mqtt_container.sh)"
```

Determine the location of your adapter (Run in the zigbee2mqtt console)
```
ls -l /dev/serial/by-id
```
Example Output: ```lrwxrwxrwx 1 root root 13 Jun 19 17:30 usb-1a86_USB_Serial-if00-port0 -> ../../ttyUSB0```

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
 
</details>
