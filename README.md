<h1 align="center" id="heading"> Select a Proxmox Helper </h1>
<p align="center"><sub> Always remember to use due diligence when sourcing scripts and automation tasks from third-party sites. </sub></p>

<a href="https://github.com/tteck/Proxmox/blob/main/LICENSE"><img src="https://badgen.net/github/license/tteck/Proxmox" ></a> <a href="https://tteck.github.io/Proxmox/"><img src="https://badgen.net/github/checks/tteck/Proxmox/main/"></a> <a href="https://github.com/tteck/Proxmox/discussions"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/discussions.png?raw=true" height="21" /></a> <a href="https://github.com/tteck/Proxmox/blob/main/CHANGELOG.MD"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/change.png?raw=true" height="21" /></a>🔸

<details>
<summary markdown="span"> 🔸Proxmox VE 7 Post Install</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/proxmoxve/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Proxmox VE 7 Post Install </h1>

This script will Disable the Enterprise Repo, Add & Enable the No-Subscription Repo, Add & Disable Test Repo (repo's can be enabled/disabled via the UI in Repositories) 
and attempt the *No-Nag* fix. 
 
Run the following in the Proxmox Shell. ⚠️ **PVE7 ONLY**

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post_install.sh)"
```

It's recommended to update Proxmox after running this script, before adding any VM/CT.

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Proxmox Kernel Clean</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/proxmoxve/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading">Proxmox Kernel Clean </h1>

Cleaning unused kernel images is not only good because of a reduced grub menu, but also gains some disk space.
 
Run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/kernel-clean.sh)"
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Proxmox CPU Scaling Governor</summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/cpu.png?raw=true" height="100"/></p>

<h1 align="center" id="heading">Proxmox CPU Scaling Governor </h1>

CPU Scaling Governor enables the operating system to scale the CPU frequency up or down in order to save power or improve performance.

[Generic Scaling Governors](https://www.kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html?#generic-scaling-governors)
 
Run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/scaling-governor.sh)"
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> 🔸Proxmox LXC Updater</summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Felpuig.xeill.net%2FMembers%2Fvcarceler%2Farticulos%2Fcontenedores-con-lxd-lxc%2Fcontainers.png&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading">Proxmox LXC Updater </h1>

Update All LXC's Fast & Easy
 
Run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/update-lxcs.sh)"
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Proxmox Dark Theme</summary>
 
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
<summary markdown="span"> 🔸Home Assistant OS VM</summary>
 
<p align="center"><img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/></p>
 
<h1 align="center" id="heading"> Home Assistant OS VM </h1>

To create a new Proxmox Home Assistant OS VM, run the following in the Proxmox Shell

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/vm/haos-vm.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  4GB RAM - 32GB Storage - 2vCPU ⚡</h3>
 
After the script completes, click on the VM, then on the **_Summary_** tab to find the VM IP.

**Home Assistant Interface - IP:8123**

____________________________________________________________________________________________ 
 
</details>


<details>
<summary markdown="span"> 🔸Home Assistant Container LXC </summary>
 
<p align="center"><img src="https://www.docker.com/sites/default/files/d8/2019-07/vertical-logo-monochromatic.png" alt="Docker Logos | Docker" width="100" height="100"/>
<img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/><img src="https://avatars1.githubusercontent.com/u/22225832?s=400&amp;v=4" alt="GitHub - portainer/portainer-docs: Portainer documentation" width="100" height="100"/></p>

<h1 align="center" id="heading"> Home Assistant Container LXC </h1>
 
To create a new Proxmox Home Assistant Container LXC, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/homeassistant-v3.sh)"
```
 
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 16GB Storage - 2vCPU ⚡</h3>

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

⚙️ **Copy Data From a Existing Home Assistant LXC to another Home Assistant LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/ha-copy-data.sh)"
 ```

⚙️ **To Allow USB Device Passthrough:**
 
Run in the Proxmox Shell. (**replace `106` with your LXC ID**)
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/usb-passthrough.sh)" -s 106
```
 
Reboot the LXC to apply the changes


⚙️ **To Install HACS:**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/hacs.sh)"
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
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/latest-update-menu.sh)"
```
 
____________________________________________________________________________________________ 
</details>

<details>
<summary markdown="span"> 🔸Podman Home Assistant Container LXC </summary>
 
<p align="center"><img src="https://heise.cloudimg.io/width/223/q50.png-lossy-50.webp-lossy-50.foil1/_www-heise-de_/imgs/18/2/5/8/2/8/1/0/podman_logo-670078d7ea1d15a6.png" width="100" height="100"/>
<img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/><img/><img src="https://raw.githubusercontent.com/SelfhostedPro/Yacht/master/readme_media/Yacht_logo_1_dark.png" height="80"/><img/></p>
 
<h1 align="center" id="heading"> Podman Home Assistant Container LXC </h1>
To create a new Proxmox Podman Home Assistant Container LXC, run the following in the Proxmox Shell. 

 ([What is Podman?](https://youtu.be/lkg5QJsoCCQ)) ⚠️ Podman seems to need a priviliged LXC

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/podman-homeassistant-v3.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 16GB Storage - 2vCPU ⚡</h3>
 
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

⚙️ **Copy Data From a Existing Home Assistant LXC to a Podman Home Assistant LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/ha-copy-data-podman.sh)"
 ```

⚙️ **To allow USB device passthrough:**
 
Run in the Proxmox Shell. (**replace `106` with your LXC ID**)
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/usb-passthrough.sh)" -s 106
```
 
Reboot the LXC to apply the changes

⚙️ **To Install HACS:**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/podman_hacs.sh)"
```
After install, reboot Home Assistant and **clear browser cache** then Add HACS integration.

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
<summary markdown="span"> Homebridge LXC</summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.dingz.ch%2Fadmin%2Fdata%2Ffiles%2Fintegration%2Flogo%2F20%2F200514-em-logo-homebridge_logo.png%3Flm%3D1589459081&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading"> Homebridge LXC </h1>
Homebridge allows you to integrate with smart home devices that do not natively support HomeKit

To create a new Proxmox Homebridge LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/homebridge.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 1vCPU ⚡</h3>
 
**Homebridge Interface - IP:8581**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 admin
 ```
Config File Path	`/var/lib/homebridge/config.json`
 
Storage Path	`/var/lib/homebridge`
 
Restart Command	`sudo hb-service restart`
 
Stop Command	`sudo hb-service stop`
 
Start Command	`sudo hb-service start`
 
View Logs Command	`sudo hb-service logs`
 
Systemd Service File	`/etc/systemd/system/homebridge.service`
 
Systemd Env File	`/etc/default/homebridge`

⚙️ **To Update Homebridge**

```yaml
Update from the Homebridge UI
```

 ___________________________________________________________________________________________ 
 
</details>



<details>
<summary markdown="span"> 🔸ESPHome LXC</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/esphome/dark_icon@2x.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> ESPHome LXC </h1>

To create a new Proxmox ESPHome LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/esphome-v3.sh)"
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
<summary markdown="span"> Nginx Proxy Manager LXC </summary>
 
<p align="center"><img src="https://nginxproxymanager.com/logo.png" alt="hero" height="100"/></p>


<h1 align="center" id="heading"> Nginx Proxy Manager LXC </h1>

To create a new Proxmox Nginx Proxy Manager LXC Container, run the following in the Proxmox Shell (V2).

```yaml
 bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nginx-proxy-manager.sh)"
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
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/npm_update.sh)"
```

 ____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> MQTT LXC</summary>
 
<p align="center"><img src="https://mosquitto.org/images/mosquitto-text-side-28.png" height="75"/></p>


<h1 align="center" id="heading"> MQTT LXC </h1>

To create a new Proxmox MQTT LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/mqtt.sh)"
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
<summary markdown="span"> Node-Red LXC </summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/custom_integrations/nodered/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Node-Red LXC </h1>
 

To create a new Proxmox Node-RED LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/node-red.sh)"
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
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/node-red-themes.sh)"
```

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> Mariadb LXC </summary>
 
<p align="center"><img src="https://mariadb.com/wp-content/webp-express/webp-images/doc-root/wp-content/themes/sage/dist/images/mariadb-logo-white.png.webp" alt="MariaDB"/><img src="https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/adminer_logo-cl.png" height="60"></p>

<h1 align="center" id="heading"> Mariadb LXC </h1>

To create a new Proxmox Mariadb LXC, run the following in the Proxmox Shell (V2).
 
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/mariadb.sh)"
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
<summary markdown="span"> 🔸Zigbee2MQTT LXC </summary>
 
<p align="center"><img src="https://github.com/Koenkk/zigbee2mqtt/blob/master/images/logo_bee_only.png?raw=true" height="100"/></p>


<h1 align="center" id="heading">Zigbee2MQTT LXC </h1>

To create a new Proxmox Zigbee2MQTT LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/zigbee2mqtt-v3.sh)"
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
cd /opt/zigbee2mqtt
bash update.sh
 ```
⚙️ **Copy Data From a Existing Zigbee2MQTT LXC to another Zigbee2MQTT LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/z2m-copy-data.sh)"
 ```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> 🔸Zwavejs2MQTT LXC </summary>
 
<p align="center"><img src="https://github.com/zwave-js/zwavejs2mqtt/raw/master/docs/_images/zwavejs_logo.svg" height="100"/></p>

<h1 align="center" id="heading"> Zwavejs2MQTT LXC </h1>

To create a new Proxmox Zwavejs2MQTT LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/zwavejs2mqtt-v3.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>

**Zwavejs2MQTT Interface - IP:8091**

⚙️ **Copy Data From a Existing Zwavejs2MQTT LXC to another Zwavejs2MQTT LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/zwave-copy-data.sh)"
 ```
⚙️ **To Update Zwavejs2MQTT**

Run in the LXC Console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/zwavejs2mqtt-update.sh)"
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> NocoDB LXC </summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/nocodb.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> NocoDB LXC </h1>

NocoDB is an open source #NoCode platform that turns any database into a smart spreadsheet. Airtable Alternative.

To create a new Proxmox NocoDB LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nocodb.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 1vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**NocoDB Interface - IP:8080/dashboard**

⚙️ **To Update**


```yaml
Working on
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> InfluxDB/Telegraf LXC </summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.hopisystems.com%2Fassets%2Fimages%2Fintegrations%2Finfluxdb.png&f=1&nofb=1" height="150"/></p>

<h1 align="center" id="heading"> InfluxDB/Telegraf LXC </h1>

To create a new Proxmox InfluxDB LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/influxdb.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

⚙️ **InfluxDB Configuration**

Run in the LXC console
```yaml
nano /etc/influxdb/influxdb.conf
```

⚙️ **Telegraf Configuration**

Run in the LXC console
```yaml
nano /etc/telegraf/telegraf.conf
```

⚙️ **To Update InfluxDB/Telegraf**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Grafana LXC </summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fdocs.checkmk.com%2Flatest%2Fimages%2Fgrafana_logo.png&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading"> Grafana LXC </h1>

To create a new Proxmox Grafana LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/grafana.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**Grafana Interface - IP:3000**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 admin
 ```

⚙️ **To Update Grafana**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Docker LXC </summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/docker.png" height="100"/></p>

<h1 align="center" id="heading"> Docker LXC </h1>
<h3 align="center"> With Selectable ZFS Storage Drivers & Option to Add Portainer and/or Docker Compose</h3>

To create a new Proxmox Docker LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/docker.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 4GB Storage - 2vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**Portainer Interface - IP:9000**

⚙️ **To Update**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> 🔸Debian 11 LXC </summary>
 
<p align="center"><img src="https://www.debian.org/Pics/debian-logo-1024x576.png" alt="Debian" height="100"/></p>

<h1 align="center" id="heading"> Debian 11 LXC </h1>

To create a new Proxmox Debian 11 (curl. sudo) LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/debian-v3.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

⚙️ **To Update Debian 11**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span"> Ubuntu 21.10 LXC </summary>
 
<p align="center"><img src="https://assets.ubuntu.com/v1/29985a98-ubuntu-logo32.png" alt="Ubuntu" height="100"/></p>

<h1 align="center" id="heading"> Ubuntu 21.10 LXC </h1>

To create a new Proxmox Ubuntu 21.10 (curl. sudo) LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/ubuntu.sh)"
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
<summary markdown="span"> UniFi Network Application LXC</summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fblog.ui.com%2Fwp-content%2Fuploads%2F2016%2F10%2Funifi-app-logo-300x108.png&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading"> UniFi Network Application LXC </h1>

An application designed to optimize UniFi home and business networks with ease.

To create a new Proxmox UniFi Network Application LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/unifi.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

**UniFi Interface - https:// IP:8443**

⚙️ **To Update UniFi**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/unifi-update.sh)"
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Omada Controller LXC</summary>
 
<p align="center"><img src="https://www.enterpriseitpro.net/wp-content/uploads/2020/12/logo-omada.png" height="100"/></p>

<h1 align="center" id="heading"> Omada Controller LXC </h1>

Omada Controller is software which is used to manage the EAP

To create a new Proxmox Omada Controller LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/omada.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

**Omada Interface - https:// IP:8043**

`tpeap status` show status of Omada Controller

`tpeap start`  start Omada Controller

`tpeap stop`   stop Omada Controller
 
⚙️ **To Update Omada**

```yaml
Working On
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> MeshCentral LXC</summary>
 
<p align="center"><img src="https://github.com/Ylianst/MeshCentral/blob/master/public/favicon-303x303.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> MeshCentral LXC </h1>

MeshCentral is a full computer management web site. With MeshCentral, you can run your own web server to remotely manage and control computers on a local network or anywhere on the internet.

To create a new Proxmox MeshCentral LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/meshcentral.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

**MeshCentral Interface - http:// IP**

⚙️ **To Update MeshCentral**

```yaml
Update from the MeshCentral UI
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Plex Media Server LXC </summary>

<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/plex/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Plex Media Server LXC </h1>
<h3 align="center" id="heading"> With Hardware Acceleration Support </h3> 
To create a new Proxmox Plex Media Server LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/plex_container.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**Plex Media Server Interface - IP:32400/web**

⚙️ **To Update Plex Media Server:**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```
⚙️ **Copy Data From a Existing Plex Media Server LXC to another Plex Media Server LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/pms-copy-data.sh)"
 ```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Jellyfin Media Server LXC </summary>
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/jellyfin/icon.png?raw=true" height="100"/></p>
<h1 align="center" id="heading"> Jellyfin Media Server LXC </h1>

[TurnKey has a LXC CT for Jellyfin](https://www.turnkeylinux.org/mediaserver)

To create a new Proxmox Jellyfin Media Server LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/jellyfin_container.sh)"
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
<summary markdown="span"> Pi-hole LXC</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/pi_hole/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Pi-hole LXC </h1>

To create a new Proxmox Pi-hole LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/pihole.sh)"
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
<summary markdown="span"> 🔸Technitium DNS LXC</summary>
 
<p align="center"><img src="https://avatars.githubusercontent.com/u/12230362?s=100&v=4" height="100"/></p>

<h1 align="center" id="heading"> Technitium DNS LXC </h1>
An open source authoritative as well as recursive DNS server

To create a new Proxmox Technitium DNS LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/technitiumdns-v3.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
**Technitium DNS Interface - IP:5380**

⚙️ **To Update**

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/technitiumdns-update.sh)"
```
__________________________________________________________________________________________ 

</details>
 
 
<details>
<summary markdown="span"> AdGuard Home LXC</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/adguard/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> AdGuard Home LXC </h1>

To create a new Proxmox AdGuard Home LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/adguard.sh)"
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
<summary markdown="span"> 🔸Uptime Kuma LXC </summary>
 
<p align="center"><img src="https://github.com/louislam/uptime-kuma/blob/master/public/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Uptime Kuma LXC </h1>

Uptime Kuma is a self-hosted, open source, fancy uptime monitoring and alerting system. It can monitor  HTTP(s) / TCP / HTTP(s) Keyword / Ping / DNS Record / Push / Steam Game Server.

To create a new Proxmox Uptime Kuma LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/uptimekuma.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**Uptime Kuma Interface - IP:3001**

⚙️ **To Update**


```yaml
Working on
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Heimdall Dashboard LXC</summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/heimdall.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Heimdall Dashboard LXC </h1>

[Heimdall Application Dashboard](https://camo.githubusercontent.com/bcfd4f74c93b25bea7b14eacbafd649206bf754a3d4b596329968f0ee569cf3c/68747470733a2f2f692e696d6775722e636f6d2f4d72433451704e2e676966) is a dashboard for all your web applications. It doesn't need to be limited to applications though, you can add links to anything you like.

To create a new Proxmox Heimdall Dashboard LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/heimdalldashboard.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
**Heimdall Dashboard Interface - IP:7990**

⚙️ **To Update Heimdall Dashboard**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/heimdalldashboard-all-update.sh)"
```

__________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span"> Dashy LXC</summary>
 
<p align="center"><img src="https://github.com/Lissy93/dashy/raw/master/public/web-icons/dashy-logo.png" height="100"/></p>

<h1 align="center" id="heading"> Dashy LXC </h1>

Dashy helps you organize your self-hosted services by making them accessible from a single place

To create a new Proxmox Dashy LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/dashy.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 3GB Storage - 2vCPU ⚡</h3>
 
**Dashy Interface - IP:4000**
 
After getting everything setup the way you want in interactive mode and saved to disk, you have to go into update configuration and rebuild application.

⚙️ **To Update Dashy**

Run in the LXC Console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/dashy-update.sh)"
```

__________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span"> PhotoPrism LXC </summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/photoprism.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> PhotoPrism LXC </h1>
 
PhotoPrism® is an AI-powered app for browsing, organizing & sharing your photo collection. 

To create a new Proxmox PhotoPrism LXC, run the following in the Proxmox Shell (V2).

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/photoprism.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**PhotoPrism Interface - IP:2342**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 admin
 ```
[PhotoSync](https://www.photosync-app.com/home.html)

⚙️ **To Update PhotoPrism**

Run in the LXC Console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/photoprism-update.sh)"
```


____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Daemon Sync Server LXC</summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimg.informer.com%2Ficons_mac%2Fpng%2F128%2F350%2F350335.png&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading"> Daemon Sync Server LXC </h1>

Sync files from app to server, share photos & videos, back up your data and stay secure inside local network.

To create a new Proxmox Daemon Sync Server LXC, run the following in the Proxmox Shell (V2).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/daemonsync.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 8GB Storage - 1vCPU ⚡</h3>
 
**Daemon Sync Server Interface - IP:8084**
 
Search: `DAEMON Sync` in your favorite app store

__________________________________________________________________________________________ 

</details>
 
<details>
<summary markdown="span"> MotionEye VMS LXC </summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/motioneye/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> MotionEye VMS LXC </h1>

To create a new Proxmox MotionEye VMS LXC, run the following in the Proxmox Shell (V2).

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/motioneye.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**MotionEye Interface - IP:8765**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 
 ```
 
 
⚙️ **To Update MotionEye**
 
Run in the LXC console
 ```yaml
pip install motioneye --upgrade
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Webmin System Administration</summary>
 
<p align="center"><img src="https://github.com/webmin/webmin/blob/master/images/webmin-blue.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Webmin System Administration </h1>

To Install Webmin System Administration [(Screenshot)](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/file-manager.png), ⚠️ run the following in the LXC console.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/webmin.sh)"
```

If you prefer to manage all aspects of your Proxmox LXC from a graphical interface instead of the command line interface, Webmin might be right for you.

Benefits include automatic daily security updates, backup and restore, file manager with editor, web control panel, and preconfigured system monitoring with optional email alerts.



**Webmin Interface - https:// IP:10000 (https)**

⚙️ **Initial Login**

**username** 
 ```yaml
 root
 ```
 **password** 
 ```yaml
 root
 ```
 
⚙️ **To Update Webmin**

```yaml
Update from the Webmin UI
```
⚙️ **To Uninstall Webmin**
 
Run in the LXC console
```yaml
bash /etc/webmin/uninstall.sh
```
___________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> WireGuard LXC </summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn.icon-icons.com%2Ficons2%2F2699%2FPNG%2F512%2Fwireguard_logo_icon_168760.png&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading"> WireGuard LXC </h1>
<h3 align="center"> With WGDashboard </h3>
 
To create a new Proxmox WireGuard LXC, run the following in the Proxmox Shell (V2).

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/wireguard.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the settings to what you desire. Changes are immediate.

**WGDashboard Interface - http:// IP:10086**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 admin
 ```
 
⚙️ **Host Configuration**
 
Run in the LXC console
 ```yaml
 nano /etc/pivpn/wireguard/setupVars.conf
 ```
 ⚙️**Add Clients** 
 
 Run in the LXC console
 ```yaml
 pivpn add
 ```
⚙️ **To Update WireGuard**
 
Run in the LXC console
 ```yaml
apt update && apt upgrade -y
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Vaultwarden LXC</summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/dani-garcia/vaultwarden/main/resources/vaultwarden-icon-white.svg" width="100" height="100"/></p>

<h1 align="center" id="heading"> Vaultwarden LXC </h1>

To create a new Proxmox Vaultwarden LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/vaultwarden.sh)"
```
⚠️ Vaultwarden needs to be behind a proxy (Nginx Proxy Manager) to obtain HTTPS and to allow clients to connect.
 
⚠️ If you find the Vaultwarden Interface unreachable,  `nano /etc/vaultwarden.env` and uncomment `ROCKET_ADDRESS=0.0.0.0` and reboot

It builds from source, which takes time and resources. After the installation, resources can be set to Normal Settings. 

Expect 30+ minute install time.
<h3 align="center" id="heading">⚡ Normal Settings:  512Mib RAM - 8GB Storage - 1vCPU ⚡</h3>

[Clients](https://bitwarden.com/download/)
 
**Vaultwarden Interface - IP:8000**

⚙️ **To Update Vaultwarden**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/vaultwarden-update.sh)"
```

____________________________________________________________________________________________ 

</details>
