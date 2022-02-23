<h1 align="center" id="heading"> Select a Proxmox Helper Below </h1>



🔸<sub> updated in the past 7 days</sub> <sub> [Changelog](https://github.com/tteck/Proxmox/blob/main/CHANGELOG.MD) </sub>


<details>
<summary markdown="span">Proxmox VE 7 Post Install</summary>
 
<p align="center"><img src="https://www.proxmox.com/images/proxmox/Proxmox_logo_standard_hex_400px.png" alt="Proxmox Server Solutions" height="55"/></p>

<h1 align="center" id="heading"> Proxmox VE 7 Post Install </h1>

This script will Disable the Enterprise Repo, Add & Enable the No-Subscription Repo, Add & Disable Test Repo (repo's can be enabled/disabled via the UI in Repositories) 
and attempt the *No-Nag* fix. 
 
Run the following in the Proxmox Shell. ⚠️ **PVE7 ONLY**

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/post_install.sh)"
```

It's recommended to update Proxmox after running this script, before adding any VM/CT.

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span">Proxmox Dark Theme</summary>
 
<p align="center"><img src="https://camo.githubusercontent.com/f6f33a09f8c1207dfb3dc1cbd754c2f3393562c11b1c999751ad9a91a656834a/68747470733a2f2f692e696d6775722e636f6d2f536e6c437948462e706e67" height="100"/></p>

<h1 align="center" id="heading"> Proxmox Discord Dark Theme </h1>

A dark theme for the Proxmox Web UI by [Weilbyte](https://github.com/Weilbyte/PVEDiscordDark)
 
Run the following in the Proxmox Shell.

```yaml
bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install
```

To uninstall the theme, simply run the script with the `uninstall` command.

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span">Home Assistant OS VM</summary>
 
<p align="center"><img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/></p>
 
<h1 align="center" id="heading"> Home Assistant OS VM </h1>

To create a new Proxmox Home Assistant OS VM, run the following in the Proxmox Shell

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/vm/haos_vm.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  4GB RAM - 32GB Storage - 2vCPU ⚡</h3>
 
After the script completes, click on the VM, then on the **_Summary_** tab to find the VM IP.

**Home Assistant Interface - IP:8123**

____________________________________________________________________________________________ 
 
</details>



<details>
<summary markdown="span"> Home Assistant Container LXC (Podman) </summary>
 
<p align="center"><img src="https://heise.cloudimg.io/width/223/q50.png-lossy-50.webp-lossy-50.foil1/_www-heise-de_/imgs/18/2/5/8/2/8/1/0/podman_logo-670078d7ea1d15a6.png" width="100" height="100"/>
<img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/><img/><img src="https://raw.githubusercontent.com/SelfhostedPro/Yacht/master/readme_media/Yacht_logo_1_dark.png" height="80"/><img/></p>
 
<h1 align="center" id="heading"> Podman Home Assistant Container LXC </h1>
<h3 align="center" id="heading"> With ZFS Filesystem Support </h3>
To create a new Proxmox Podman Home Assistant Container, run the following in the Proxmox Shell. 

 ([What is Podman?](https://youtu.be/lkg5QJsoCCQ))

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/podman_ha_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**Home Assistant Interface - IP:8123**
 
**Yacht Interface - IP:8000**

⚙️ **Path to HA /config**
```yaml
/var/lib/containers/storage/volumes/hass_config/_data
 ```
⚙️ **To edit the HA configuration.yaml**
 
Run in the LXC console
```yaml
nano /var/lib/containers/storage/volumes/hass_config/_data/configuration.yaml
```
Save and exit the editor with “Ctrl+O”, “Enter” and “Ctrl+X”

⚙️ **Import Data From a Existing Home Assistant LXC to a Podman Home Assistant LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/ha-copy-data-podman.sh)"
 ```

⚙️ **To allow USB device passthrough:**
 
Run in the Proxmox Shell. (**replace `106` with your LXC ID**)
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/usb-passthrough.sh)" -s 106
```
 
Reboot the LXC to apply the changes

⚙️ **To Install HACS:**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/podman_hacs.sh)"
```
After install, reboot Home Assistant and **clear browser cache** then Add HACS integration.

⚙️ **To Update Home Assistant:**

Run in the LXC console
```yaml
./update.sh
```
⚙️ **Initial Yacht Login**

**username** 
 ```yaml
 admin@yacht.local
 ```
 **password** 
 ```yaml
 pass
 ```

____________________________________________________________________________________________ 
</details>


<details>
<summary markdown="span"> 🔸Home Assistant Container LXC </summary>
 
<p align="center"><img src="https://www.docker.com/sites/default/files/d8/2019-07/vertical-logo-monochromatic.png" alt="Docker Logos | Docker" width="100" height="100"/>
<img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/><img src="https://avatars1.githubusercontent.com/u/22225832?s=400&amp;v=4" alt="GitHub - portainer/portainer-docs: Portainer documentation" width="100" height="100"/></p>

<h1 align="center" id="heading"> Home Assistant Container LXC </h1>
<h3 align="center" id="heading"> With ZFS Filesystem Support </h3> 
To create a new Proxmox Home Assistant Container, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/ha_container.sh)"
```
To create a new Proxmox **Unprivileged** Home Assistant Container, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/unpriv/unprivileged-homeassistant.sh)"
```
 
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**Home Assistant Interface - IP:8123**

**Portainer Interface - IP:9000**

⚙️ **Path to HA /config**
```yaml
/var/lib/docker/volumes/hass_config/_data
 ```
⚙️ **To Edit the HA configuration.yaml** (Recommend Using Webmin System Administration)
 
Run in the LXC console
```yaml
nano /var/lib/docker/volumes/hass_config/_data/configuration.yaml
```
Save and exit the editor with “Ctrl+O”, “Enter” and “Ctrl+X”

⚙️ **Import Data From a Existing Home Assistant LXC to another Home Assistant LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/ha-copy-data.sh)"
 ```

⚙️ **To Allow USB Device Passthrough:**
 
Run in the Proxmox Shell. (**replace `106` with your LXC ID**)
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/usb-passthrough.sh)" -s 106
```
 
Reboot the LXC to apply the changes


⚙️ **To Install HACS:**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/hacs.sh)"
```
After install, reboot Home Assistant and **clear browser cache** then Add HACS integration.


⚙️ [**Update Menu**](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/update-menu.png)

Run in the LXC console
```yaml
./update
```
⚙️ **Migrate to the latest Update Menu**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/latest-update-menu.sh)"
```
 
____________________________________________________________________________________________ 
</details>




<details>
<summary markdown="span">ESPHome LXC</summary>
 
<p align="center"><img src="https://esphome.io/_static/logo-text.svg" alt="Logo" height="90"/></p>

<h1 align="center" id="heading"> ESPHome LXC Container </h1>

To create a new Proxmox ESPHome LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/esphome_container.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>
 
**ESPHome Interface - IP:6052**

⚙️ **To Update ESPHome**

Run in the LXC console
```yaml
pip3 install esphome --upgrade
```

____________________________________________________________________________________________ 
 
</details>



<details>
<summary markdown="span"> 🔸Nginx Proxy Manager LXC </summary>
 
<p align="center"><img src="https://nginxproxymanager.com/logo.png" alt="hero" height="100"/></p>


<h1 align="center" id="heading"> Nginx Proxy Manager LXC Container </h1>

To create a new Proxmox Nginx Proxy Manager LXC Container, run the following in the Proxmox Shell.

```yaml
 bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/npm_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 3GB Storage - 1vCPU ⚡</h3>

____________________________________________________________________________________
 
Forward port `80` and `443` from your router to your Nginx Proxy Manager LXC IP.

Add the following to your `configuration.yaml` in Home Assistant.
```yaml
 http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.100.27 ###(Nginx Proxy Manager LXC IP)###
```

**Nginx Proxy Manager Interface - IP:81**
 
⚙️ **Initial Login**

**username** 
 ```yaml
 admin@example.com
 ```
 **password** 
 ```yaml
 changeme
 ```
⚙️ **To Update Nginx Proxy Manager**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/npm_update.sh)"
```

 ____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> 🔸MQTT LXC</summary>
 
<p align="center"><img src="https://mosquitto.org/images/mosquitto-text-side-28.png" height="75"/></p>


<h1 align="center" id="heading"> MQTT LXC Container </h1>

To create a new Proxmox MQTT LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/mqtt_container.sh)"
```
To create a new Proxmox **Unprivileged** MQTT LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/unpriv/unprivileged-mqtt.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
Mosquitto comes with a password file generating utility called mosquitto_passwd.
```yaml
sudo mosquitto_passwd -c /etc/mosquitto/passwd <usr>
```
Password: < password >

Create a configuration file for Mosquitto pointing to the password file we have just created.
```yaml
sudo nano /etc/mosquitto/conf.d/default.conf
```
This will open an empty file. Paste the following into it.
```yaml
allow_anonymous false
persistence true
password_file /etc/mosquitto/passwd
listener 1883
```
Save and exit the text editor with "Ctrl+O", "Enter" and "Ctrl+X".

Now restart Mosquitto server.
```yaml
sudo systemctl restart mosquitto
```

⚙️ **To Update MQTT:**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> 🔸Node-Red LXC </summary>
 
<p align="center"><img src="https://nodered.org/about/resources/media/node-red-icon.png" alt="@node-red" width="100" height="100"/></p>

<h1 align="center" id="heading"> Node-Red LXC Container </h1>
 

To create a new Proxmox Node-RED LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/node-red_container.sh)"
```
To create a new Proxmox **Unprivileged** Node-RED LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/unpriv/unprivileged-node-red.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 1vCPU ⚡</h3>
 
**Node-Red Interface - IP:1880**
 
⚙️ **To Restart Node-Red:**

Run in the LXC console
```yaml
node-red-restart
```

⚙️ **To Update Node-Red:**

Run in the LXC console (Restart after update)
```yaml
npm install -g --unsafe-perm node-red
```

⚙️ **To Install Node-Red Themes** ⚠️ **Backup your flows before running this script!!**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/node-red-themes.sh)"
```

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> 🔸Mariadb LXC </summary>
 
<p align="center"><img src="https://mariadb.com/wp-content/webp-express/webp-images/doc-root/wp-content/themes/sage/dist/images/mariadb-logo-white.png.webp" alt="MariaDB"/><img src="https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/adminer_logo-cl.png" height="60"></p>

<h1 align="center" id="heading"> Mariadb LXC Container </h1>

To create a new Proxmox Mariadb LXC Container, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/mariadb_container.sh)"
```
To create a new Proxmox **Unprivileged** Mariadb LXC Container, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/unpriv/unprivileged-mariadb.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 1vCPU ⚡</h3>
 
To enable MariaDB to listen to remote connections, you need to edit your defaults file. To do this, open the console in your MariaDB lxc:
```yaml
nano /etc/mysql/my.cnf
```
Un-comment `port =3306`
Save and exit the editor with "Ctrl+O", "Enter" and "Ctrl+X".

```yaml
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```
Comment `bind-address  = 127.0.0.1`
Save and exit the editor with "Ctrl+O", "Enter" and "Ctrl+X".

For new MariaDB installations, the next step is to run the included security script. This script changes some of the less secure default options. We will use it to block remote root logins and to remove unused database users.

Run the security script:
```yaml
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
```yaml
sudo mysql
``` 
Prompt will change to ```MariaDB [(none)]>```

Create a new local admin (Change the username and password to match your preferences)
```yaml
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
```
Give local admin root privileges (Change the username and password to match above)
```yaml
GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
```

Now, we'll give the user admin root privileges and password-based access that can connect from anywhere on your local area network (LAN), which has addresses in the subnet 192.168.100.0/24. This is an improvement because opening a MariaDB server up to the Internet and granting access to all hosts is bad practice.. Change the **_username_**, **_password_** and **_subnet_** to match your preferences:
```yaml
GRANT ALL ON *.* TO 'admin'@'192.168.100.%' IDENTIFIED BY 'password' WITH GRANT OPTION;
```
Flush the privileges to ensure that they are saved and available in the current session:
```yaml
FLUSH PRIVILEGES;
```
Following this, exit the MariaDB shell:
```yaml
exit
```
Log in as the new database user you just created:
```yaml
mysql -u admin -p
```
Create a new database:
```yaml
CREATE DATABASE homeassistant;
```
Following this, exit the MariaDB shell:
```yaml
exit
```
⚠️ Reboot the lxc 

Checking status.
```yaml
sudo systemctl status mariadb
``` 
Change the recorder: `db_url:` in your HA configuration.yaml
 
Example: `mysql://admin:password@192.168.100.26:3306/homeassistant?charset=utf8mb4`
 
⚙️ **To Update Mariadb:**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```
⚙️ [**Adminer**](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/adminer.png) (formerly phpMinAdmin) is a full-featured database management tool
 
 `http://your-mariadb-lxc-ip/adminer/`

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Zigbee2MQTT LXC </summary>
 
<p align="center"><img src="https://github.com/Koenkk/zigbee2mqtt/blob/master/images/logo.png?raw=true" alt="logo.png" width="100" height="100"/></p>


<h1 align="center" id="heading">Zigbee2MQTT LXC Container</h1>

To create a new Proxmox Zigbee2MQTT LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/zigbee2mqtt_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>

 
⚙️ **Determine the location of your adapter**
 
Run in the LXC console
```yaml
ls -l /dev/serial/by-id
```
Example Output: ```lrwxrwxrwx 1 root root 13 Jun 19 17:30 usb-1a86_USB_Serial-if00-port0 -> ../../ttyUSB0```


⚙️ ⚠️ **Before you start Zigbee2MQTT you need to edit the [configuration.yaml](https://www.zigbee2mqtt.io/guide/configuration/)**
 
Run in the LXC console
```yaml
nano /opt/zigbee2mqtt/data/configuration.yaml
```

Save and exit the editor with “Ctrl+O”, “Enter” and “Ctrl+X”

Example:
```yaml
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
  #adapter: deconz            #(uncomment for ConBee II)
advanced:
  pan_id: GENERATE
  network_key: GENERATE
  channel: 20
```
⚙️ **Zigbee2MQTT can be started after completing the configuration**
 
Run in the LXC console
```yaml
cd /opt/zigbee2mqtt
npm start
```
⚙️ **To update Zigbee2MQTT**
 
Run in the LXC console
 ```yaml
bash /opt/zigbee2mqtt/update.sh
 ```
⚙️ **Import Data From a Existing Zigbee2MQTT LXC to another Zigbee2MQTT LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/z2m-copy-data.sh)"
 ```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Zwavejs2MQTT LXC </summary>
 
<p align="center"><img src="https://github.com/zwave-js/zwavejs2mqtt/raw/master/docs/_images/zwavejs_logo.svg" height="100"/></p>

<h1 align="center" id="heading"> Zwavejs2MQTT LXC Container </h1>

To create a new Proxmox Zwavejs2MQTT LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/zwavejs2mqtt_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>

**Zwavejs2MQTT Interface - IP:8091**


____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> 🔸Debian 11 LXC </summary>
 
<p align="center"><img src="https://www.debian.org/Pics/debian-logo-1024x576.png" alt="Debian" height="100"/></p>

<h1 align="center" id="heading"> Debian 11 LXC Container </h1>

To create a new Proxmox Debian 11 (curl. sudo, auto login) LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/debian11_container.sh)"
```
To create a new Proxmox **Unprivileged** Debian 11 (curl. sudo, auto login) LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/unpriv/unprivileged-debian.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

⚙️ **To Update Debian 11**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span"> 🔸Ubuntu 21.10 LXC </summary>
 
<p align="center"><img src="https://assets.ubuntu.com/v1/29985a98-ubuntu-logo32.png" alt="Ubuntu" height="100"/></p>

<h1 align="center" id="heading"> Ubuntu 21.10 LXC Container </h1>

To create a new Proxmox Ubuntu 21.10 (curl. sudo, auto login) LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/ubuntu_container.sh)"
```
To create a new Proxmox **Unprivileged** Ubuntu 21.10 (curl. sudo, auto login) LXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/unpriv/unprivileged-ubuntu.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

⚙️ **To Update Ubuntu 21.10**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> GamUntu LXC</summary>
 <p align="center"><img src="https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/gamuntu1.png" alt="GamUntu" height="100"/></p>
<h1 align="center" id="heading"> GamUntu LXC Container </h1>

GamUntu is Ubuntu 21.10, Docker, Docker Compose, ZFS Support, USB Passthrough, Webmin System Administration and Hardware Acceleration all baked in!

To create a new Proxmox GamUntuLXC Container, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/gamuntu_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

⚙️ **To Update GamUntu**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Plex Media Server LXC </summary>

<p align="center"><img src="https://www.plex.tv/wp-content/themes/plex/assets/img/plex-logo.svg" height="80"/></p>

<h1 align="center" id="heading"> Plex Media Server LXC </h1>
<h3 align="center" id="heading"> With Hardware Acceleration Support </h3> 
To create a new Proxmox Plex Media Server LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/plex_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**Plex Media Server Interface - IP:32400/web**

⚙️ **To Update Plex Media Server:**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```
⚙️ **Import Data From a Existing Plex Media Server LXC to another Plex Media Server LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/pms-copy-data.sh)"
 ```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Jellyfin Media Server LXC </summary>
<p align="center"><img src="https://jellyfin.org/images/banner-dark.svg" height="80"/></p>
<h1 align="center" id="heading"> Jellyfin Media Server LXC </h1>

To create a new Proxmox Jellyfin Media Server LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/jellyfin_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**Jellyfin Media Server Interface - IP:8096**

⚙️ **To Update Jellyfin Media Server**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span">Pi-hole LXC</summary>
 
<p align="center"><img src="https://camo.githubusercontent.com/9426a93d32aa9f5ad757b2befcdb762a270d344efd6b8d287a2cea2c4c2233b8/68747470733a2f2f70692d686f6c652e6769746875622e696f2f67726170686963732f566f727465782f566f727465785f776974685f576f72646d61726b2e737667" alt="Pi-hole" width="100" height="100"/></p>

<h1 align="center" id="heading"> Pi-hole LXC </h1>

To create a new Proxmox Pi-hole LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/pihole_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
⚙️ **To set your password:**
 
Run in the LXC console

```yaml
pihole -a -p
```
⚙️ **To Update Pi-hole:**

```yaml
Update from the Pi-hole UI
```

____________________________________________________________________________________________ 

</details>

 
 
<details>
<summary markdown="span">AdGuard Home LXC</summary>
 
<p align="center"><img src="https://dashboard.snapcraft.io/site_media/appmedia/2020/04/256.png" width="100" height="100"/></p>

<h1 align="center" id="heading"> AdGuard Home LXC </h1>

To create a new Proxmox AdGuard Home LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/adguard_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
**AdGuard Home Setup Interface - IP:3000  (After Setup use only IP)**
 
 <sub>(For the Home Assistant Integration, use port `80` not `3000`)</sub>

⚙️ **To Update Adguard**

```yaml
Update from the Adguard UI
```
__________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> MotionEye NVR LXC </summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/motioneye-256x256.png" width="100" height="100"/></p>

<h1 align="center" id="heading"> MotionEye NVR LXC </h1>

To create a new Proxmox MotionEye NVR LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/motioneye_container.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**MotionEye Interface - IP:8765**

⚙️ **Initial Login**

**username** 
 `admin`
 
 **password** 
 `Leave Blank`
 
⚙️ **To Update MotionEye**
 
Run in the LXC console
 ```yaml
pip install motioneye --upgrade
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span">Webmin System Administration</summary>
 
<p align="center"><img src="https://github.com/webmin/webmin/blob/master/images/webmin-blue.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Webmin System Administration </h1>

To Install Webmin System Administration [(Screenshot)](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/file-manager.png), ⚠️ run the following in the LXC console.

```yaml
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/misc/webmin.sh)"
```

If you prefer to manage all aspects of your Proxmox LXC from a graphical interface instead of the command line interface, Webmin might be right for you.

Benefits include automatic daily security updates, backup and restore, file manager with editor, web control panel, and preconfigured system monitoring with optional email alerts.



**Webmin Interface - https:// IP:10000 (https)**

⚙️ **Initial Login**

**username** 
 `root`
 
 **password** 
 `root`
 
⚙️ **To Update Webmin**

```yaml
Update from the Webmin UI
```
⚙️ **To Uninstall Webmin**
```yaml
bash /etc/webmin/uninstall.sh
```
___________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> 🔸Vaultwarden LXC</summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/dani-garcia/vaultwarden/main/resources/vaultwarden-icon-white.svg" width="100" height="100"/></p>

<h1 align="center" id="heading"> Vaultwarden LXC </h1>

To create a new Proxmox Vaultwarden LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/ct/vault_container.sh)"
```
Vaultwarden needs to be behind a proxy (Nginx Proxy Manager) to obtain HTTPS and to allow clients to connect.

It builds from source, which takes time and resources. After the installation, resources can be set to Normal Settings. 

Expect 30+ minute install time.
<h3 align="center" id="heading">⚡ Normal Settings:  512Mib RAM - 8GB Storage - 1vCPU ⚡</h3>

[Clients](https://bitwarden.com/download/)
 
**Vaultwarden Interface - IP:8000**

____________________________________________________________________________________________ 

</details>
