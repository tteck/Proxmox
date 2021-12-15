<h1 align="center" id="heading"> Select a Proxmox Helper Below </h1>



<details>
<summary markdown="span">Proxmox VE 7 Post Install</summary>
 
<p align="center"><img src="https://www.proxmox.com/images/proxmox/Proxmox_logo_standard_hex_400px.png" alt="Proxmox Server Solutions" height="55"/></p>

<h1 align="center" id="heading"> Proxmox VE 7 Post Install </h1>

This script will Disable the Enterprise Repo, Add & Enable the No-Subscription Repo, Add & Disable Test Repo (repo's can be enabled/disabled via the UI in Repositories) 
and attempt the *No-Nag* fix. 
 
Run the following in the Proxmox Web Shell. ⚠️ **PVE7 ONLY**

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/post_install.sh)"
```

It's recommended to update Proxmox after running this script, before adding any VM/CT.

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span">Proxmox Dark Theme</summary>
 
<p align="center"><img src="https://camo.githubusercontent.com/f6f33a09f8c1207dfb3dc1cbd754c2f3393562c11b1c999751ad9a91a656834a/68747470733a2f2f692e696d6775722e636f6d2f536e6c437948462e706e67" height="100"/></p>

<h1 align="center" id="heading"> Proxmox Discord Dark Theme </h1>

A dark theme for the Proxmox Web UI by [Weilbyte](https://github.com/Weilbyte/PVEDiscordDark)
 
Run the following in the Proxmox Web Shell.

```
bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install
```

To uninstall the theme, simply run the script with the `uninstall` command.

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span">Home Assistant OS VM</summary>
 
<p align="center"><img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/></p>
 
<h1 align="center" id="heading"> Proxmox Home Assistant OS VM </h1>

To create a new Proxmox VM with the latest version of Home Assistant OS, run the following from Proxmox web shell

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/haos_vm.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  4GB RAM - 32GB Storage - 2vCPU ⚡</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the VM, then on the **_Hardware_** tab and change the **_Memory_** and **_Processors_** settings to what you desire. Once all changes have been made, **_Start_** the VM.

**Home Assistant Interface - IP:8123**

____________________________________________________________________________________________ 
 
</details>



<details>
<summary markdown="span">Home Assistant Container LXC (Podman)</summary>
 
<p align="center"><img src="https://heise.cloudimg.io/width/223/q50.png-lossy-50.webp-lossy-50.foil1/_www-heise-de_/imgs/18/2/5/8/2/8/1/0/podman_logo-670078d7ea1d15a6.png" width="100" height="100"/>
<img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/><img/></p>

<h1 align="center" id="heading"> Proxmox Podman Home Assistant Container LXC </h1>

To create a new Proxmox Podman Home Assistant Container, run the following from Proxmox web shell. 

 ([What is Podman?](https://github.com/tteck/Proxmox/blob/main/Podman.md))

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/podman_ha_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

**Home Assistant Interface - IP:8123**

⚙️ **Path to HA /config**
```
/var/lib/containers/storage/volumes/hass_config/_data
 ```
⚙️ **To edit the HA configuration.yaml**
 
Run from the LXC console
```
nano /var/lib/containers/storage/volumes/hass_config/_data/configuration.yaml
```
Save and exit the editor with “Ctrl+O”, “Enter” and “Ctrl+X”

⚙️ **To autostart Home Assistant at every boot:**
 
Run from the LXC console
```
podman generate systemd \
    --new --name homeassistant \
    > /etc/systemd/system/homeassistant.service
systemctl enable homeassistant
```
⚙️ **Start the homeassistant service:**
 
Run from the LXC console
```
systemctl start homeassistant
```

⚙️ **To install HACS:**

Run the from the LXC console
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/podman_hacs.sh)"
```
After install, reboot Home Assistant and **clear browser cache** then Add HACS integration.


____________________________________________________________________________________________ 
</details>


<details>
<summary markdown="span">Home Assistant Container LXC </summary>
 
<p align="center"><img src="https://www.docker.com/sites/default/files/d8/2019-07/vertical-logo-monochromatic.png" alt="Docker Logos | Docker" width="100" height="100"/>
<img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/><img src="https://avatars1.githubusercontent.com/u/22225832?s=400&amp;v=4" alt="GitHub - portainer/portainer-docs: Portainer documentation" width="100" height="100"/></p>

<h1 align="center" id="heading"> Proxmox Home Assistant Container LXC </h1>

To create a new Proxmox Home Assistant Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ha_container.sh)"
```
 
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

**Home Assistant Interface - IP:8123**

**Portainer Interface - IP:9000**

⚙️ **Path to HA /config**
```
/var/lib/docker/volumes/hass_config/_data
 ```
⚙️ **To edit the HA configuration.yaml**
 
Run from the LXC console
```
nano /var/lib/docker/volumes/hass_config/_data/configuration.yaml
```
Save and exit the editor with “Ctrl+O”, “Enter” and “Ctrl+X”


⚙️ **To allow device passthrough:**
 
In the Proxmox web shell run (**replace `106` with your LXC ID**)
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/autodev.sh)" -s 106
```
 
Reboot the LXC to apply the changes


⚙️ **To install HACS:**

Run the from the LXC console
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/hacs.sh)"
```
After install, reboot Home Assistant and **clear browser cache** then Add HACS integration.

____________________________________________________________________________________________ 
</details>




<details>
<summary markdown="span">ESPHome LXC</summary>
 
<p align="center"><img src="https://esphome.io/_static/logo-text.svg" alt="Logo" height="90"/></p>

<h1 align="center" id="heading"> Proxmox ESPHome LXC Container </h1>

To create a new Proxmox ESPHome LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/esphome_container.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>
 
**ESPHome Interface - IP:6052**

____________________________________________________________________________________________ 
 
</details>



<details>
<summary markdown="span">Nginx Proxy Manager LXC</summary>
 
<p align="center"><img src="https://nginxproxymanager.com/logo.png" alt="hero" height="100"/></p>


<h1 align="center" id="heading"> Proxmox Nginx Proxy Manager LXC Container </h1>

To create a new Proxmox Nginx Proxy Manager LXC Container, run the following from Proxmox web shell.

```
 curl -sL https://raw.githubusercontent.com/ej52/proxmox/main/lxc/nginx-proxy-manager/create.sh | bash -s
```
<h3 align="center" id="heading">⚡ Alpine  Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

____________________________________________________________________________________
 
Forward port `80` and `443` from your router to your Nginx Proxy Manager LXC IP.

Add the following to your `configuration.yaml` in Home Assistant.
```
 http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.100.27 ###(Nginx Proxy Manager LXC IP)###
```

**Nginx Proxy Manager Interface - IP:81**
 
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

 ____________________________________________________________________________________________ 

</details>




<details>
<summary markdown="span">MQTT LXC</summary>
 
<p align="center"><img src="https://mqtt.org/assets/img/mqtt-logo-transp.svg" height="75"/></p>


<h1 align="center" id="heading"> Proxmox MQTT LXC Container </h1>

To create a new Proxmox MQTT LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/mqtt_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
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

____________________________________________________________________________________________ 
 
</details>





<details>
<summary markdown="span">Node-Red LXC</summary>
 
<p align="center"><img src="https://avatars.githubusercontent.com/u/5375661?s=200&amp;v=4" alt="@node-red" width="100" height="100"/></p>

<h1 align="center" id="heading"> Proxmox Node-Red LXC Container </h1>
 

To create a new Proxmox Node-RED LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/node-red_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 1vCPU ⚡</h3>
 
From your nodered LXC console, the following commands can be run
 
`node-red-start`  to start Node-Red

`sudo systemctl enable nodered.service`  to autostart Node-RED at every boot

`node-red-restart`  to restart Node-Red

`sudo systemctl disable nodered.service` to disable autostart on boot
 
`sudo npm install -g --unsafe-perm node-red` to update Node-Red (`node-red-restart` after update)

**Node-Red Interface - IP:1880**

____________________________________________________________________________________________ 
 
</details>



<details>
<summary markdown="span">Mariadb LXC</summary>
 
<p align="center"><img src="https://mariadb.com/wp-content/webp-express/webp-images/doc-root/wp-content/themes/sage/dist/images/mariadb-logo-white.png.webp" alt="MariaDB"/></p>


<h1 align="center" id="heading"> Proxmox Mariadb LXC Container </h1>

To create a new Proxmox Mariadb LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/mariadb_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 1vCPU ⚡</h3>
 
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
⚠️ Reboot the lxc 

Checking status.
```
sudo systemctl status mariadb
``` 
Change the recorder: `db_url:` in your HA configuration.yaml
 
Example: `mysql://admin:password@192.168.100.26:3306/homeassistant?charset=utf8mb4`
 
____________________________________________________________________________________________ 

</details>





<details>
<summary markdown="span">Zigbee2MQTT LXC </summary>
 
<p align="center"><img src="https://github.com/Koenkk/zigbee2mqtt/blob/master/images/logo.png?raw=true" alt="logo.png" width="100" height="100"/></p>


<h1 align="center" id="heading"> Proxmox Zigbee2MQTT LXC Container </h1>

To create a new Proxmox [Zigbee2MQTT](https://www.zigbee2mqtt.io/) LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/zigbee2mqtt_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>
 

⚙️ **To allow device passthrough:**
 
In the Proxmox web shell run (**replace `106` with your LXC ID**)
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/autodev.sh)" -s 106
```
 
Reboot the LXC to apply the changes

 
⚙️ **Determine the location of your adapter**
 
Run in the zigbee2mqtt console
```
ls -l /dev/serial/by-id
```
Example Output: ```lrwxrwxrwx 1 root root 13 Jun 19 17:30 usb-1a86_USB_Serial-if00-port0 -> ../../ttyUSB0```


⚠️ **Before you can start Zigbee2MQTT you need to edit the [configuration.yaml](https://www.zigbee2mqtt.io/guide/configuration/)**
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
⚙️ **Zigbee2mqtt can be started after completing the configuration**
```
sudo systemctl start zigbee2mqtt
```
⚙️ **To start Zigbee2MQTT automatically on boot**
 ```
sudo systemctl enable zigbee2mqtt.service
 ```
⚙️ **To update Zigbee2Mqtt**
 ```
cd /opt/zigbee2mqtt
bash update.sh
 ```

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span">Zwavejs2MQTT LXC </summary>
 
<p align="center"><img src="https://github.com/zwave-js/zwavejs2mqtt/raw/master/docs/_images/zwavejs_logo.svg" height="100"/></p>

<h1 align="center" id="heading"> Proxmox Zwavejs2MQTT LXC Container </h1>

To create a new Proxmox Zwavejs2MQTT LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/zwavejs2mqtt_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>

⚙️ **To start Zwavejs2Mqtt**
 
Run from the LXC console
 ```
cd zwavejs2mqtt
./zwavejs2mqtt
 ```
**Zwavejs2MQTT Interface - IP:8091**

⚙️ **To allow device passthrough:**
 
In the Proxmox web shell run (**replace `106` with your LXC ID)**
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/autodev.sh)" -s 106
```
 
Reboot the LXC to apply the changes

____________________________________________________________________________________________ 

</details>



<details>
<summary markdown="span">Debian 11+ LXC</summary>
 
<p align="center"><img src="https://www.debian.org/Pics/debian-logo-1024x576.png" alt="Debian" height="100"/></p>

<h1 align="center" id="heading"> Proxmox Debian 11 LXC Container </h1>

To create a new Proxmox Debian 11 (curl. sudo, auto login) LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/debian11_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

____________________________________________________________________________________________ 

</details>




<details>
<summary markdown="span">Pi-hole LXC</summary>
 
<p align="center"><img src="https://camo.githubusercontent.com/9426a93d32aa9f5ad757b2befcdb762a270d344efd6b8d287a2cea2c4c2233b8/68747470733a2f2f70692d686f6c652e6769746875622e696f2f67726170686963732f566f727465782f566f727465785f776974685f576f72646d61726b2e737667" alt="Pi-hole" width="100" height="100"/></p>

<h1 align="center" id="heading"> Pi-hole LXC </h1>

To create a new Proxmox Pi-hole LXC, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/pihole_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
⚙️ **To set your password:**
 
Run from the LXC console

```
pihole -a -p
```

____________________________________________________________________________________________ 

</details>

 
 
<details>
<summary markdown="span">AdGuard Home LXC</summary>
 
<p align="center"><img src="https://dashboard.snapcraft.io/site_media/appmedia/2020/04/256.png" width="100" height="100"/></p>

<h1 align="center" id="heading"> AdGuard Home LXC </h1>

To create a new Proxmox AdGuard Home LXC, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/adguard_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
**AdGuard Home Interface - IP:3000**

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span">Webmin System Administration</summary>
 
<p align="center"><img src="https://github.com/webmin/webmin/blob/master/images/webmin-blue.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Webmin System Administration </h1>

To Install [Webmin System Administration](https://www.webmin.com/index.html), run the following in a LXC console.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/webmin.sh)"
```

If you prefer to manage all aspects of your Proxmox LXC from a graphical interface instead of the command line interface, Webmin might be right for you.

Benefits include automatic daily security updates, backup and restore, file manager with editor, web control panel, and preconfigured system monitoring with optional email alerts.



**Webmin Interface - https:// IP:10000 (https)**

⚙️ **Initial Login**

**username** 
 `root`
 
 **password** 
 `root`
 
____________________________________________________________________________________________ 

</details>
