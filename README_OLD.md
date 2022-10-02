<h1 align="center" id="heading"> Select a Proxmox Helper </h1>

<p align="center"><sub> Always remember to use due diligence when sourcing scripts and automation tasks from third-party sites. </sub></p>

<a href="https://github.com/tteck/Proxmox/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" ></a> <a href="https://github.com/tteck/Proxmox/discussions"><img src="https://img.shields.io/badge/%F0%9F%92%AC-Discussions-orange" /></a> <a href="https://github.com/tteck/Proxmox/blob/main/CHANGELOG.MD"><img src="https://img.shields.io/badge/🔶-Changelog-blue" /></a> <a
href="https://ko-fi.com/D1D7EP4GF"><img src="https://img.shields.io/badge/%E2%98%95-Buy%20me%20a%20coffee-red" /></a>

<details>
<summary markdown="span"> Proxmox VE 7 Post Install</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/proxmoxve/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Proxmox VE 7 Post Install </h1>

The script will give options to Disable the Enterprise Repo, Add/Correct PVE7 Sources, Enable the No-Subscription Repo, Add Test Repo, Disable Subscription Nag, Update Proxmox VE and Reboot PVE.
 
Run the following in the Proxmox Shell. ⚠️ **PVE7 ONLY**

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pve-install.sh)"
```

It's recommended to answer `y` to all options.

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
<summary markdown="span"> Proxmox Edge Kernel Tool</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/proxmoxve/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading">Proxmox Edge Kernel Tool </h1>

Proxmox [Edge Kernels](https://github.com/fabianishere/pve-edge-kernel) are custom Linux Kernels for Proxmox VE 7. Keeping up with new Kernel releases instead of LTS

Run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/edge-kernel.sh)"
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
<summary markdown="span"> Proxmox LXC Updater</summary>
 
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
<summary markdown="span"> Proxmox Backup Server Post Install</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/proxmoxve/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Proxmox Backup Server Post Install </h1>

The script will give options to Disable the Enterprise Repo, Add/Correct PBS Sources, Enable the No-Subscription Repo, Add Test Repo, Disable Subscription Nag, Update Proxmox Backup Server and Reboot PBS.
 
Run the following in the Proxmox Shell. ⚠️ **Proxmox Backup Server ONLY**

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pbs-install.sh)"
```

It's recommended to answer `y` to all options.

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Home Assistant OS VM</summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/haos.png?raw=true"/></p>
 
<h1 align="center" id="heading"> Home Assistant OS VM </h1>
<h3 align="center"> Option to create VM using Stable, Beta or Dev Image </h3>

The script automates the manual process of finding, downloading and extracting the Official KVM (qcow2) disk image provided by the Home Assistant Team, creating a VM with user defined settings, importing and attaching the disk, setting the boot order and starting the VM. No hidden (kpartx, unzip, ect...) installs of any kind. Supports lvmthin, zfspool, nfs, dir and btrfs storage types.

To create a new Proxmox Home Assistant OS VM, run the following in the Proxmox Shell

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/vm/haos-vm-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  4GB RAM - 32GB Storage - 2vCPU - Stable Image⚡</h3>
 
After the script completes, click on the VM, then on the **_Summary_** tab to find the VM IP.

**Home Assistant Interface - IP:8123**

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> 🔸PiMox HAOS VM</summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/pimox.png?raw=true" width="100" height="100"/></p>
 
<h1 align="center" id="heading"> PiMox HAOS VM </h1>
<h3 align="center"> Option to create VM using Stable, Beta or Dev Image </h3>

The script automates the manual process of finding, downloading and extracting the aarch64 (qcow2) disk image provided by the Home Assistant Team, creating a VM with user defined settings, importing and attaching the disk, setting the boot order and starting the VM.

To create a new PiMox HAOS VM, run the following in the Proxmox Shell

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/vm/pimox-haos-vm-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  4GB RAM - 32GB Storage - 2vCPU - Stable Image⚡</h3>
 
After the script completes, click on the VM Console to find the Home Assistant IP.

**Home Assistant Interface - IP:8123**

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> Home Assistant Container LXC </summary>
 
<p align="center"><img src="https://www.docker.com/sites/default/files/d8/2019-07/vertical-logo-monochromatic.png" alt="Docker Logos | Docker" width="100" height="100"/>
<img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/><img src="https://avatars1.githubusercontent.com/u/22225832?s=400&amp;v=4" alt="GitHub - portainer/portainer-docs: Portainer documentation" width="100" height="100"/></p>

<h1 align="center" id="heading"> Home Assistant Container LXC </h1>

A standalone container-based installation of Home Assistant Core

🛈 *If the LXC is created Privileged, the script will automatically set up USB passthrough.*

To create a new Proxmox Home Assistant Container LXC, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/homeassistant-v4.sh)"
```
 
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 16GB Storage - 2vCPU ⚡</h3>

**Home Assistant Interface - IP:8123**

**Portainer Interface - IP:9000**

⚙️ **Path to HA /config**
```yaml
/var/lib/docker/volumes/hass_config/_data
 ```
⚙️ **To Edit the HA configuration.yaml** (Recommend Using File Browser)
 
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
____________________________________________________________________________________________ 
</details>

<details>
<summary markdown="span"> 🔸Home Assistant Core LXC </summary>
 
<p align="center"><img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" width="100" height="100"/></p>

<h1 align="center" id="heading"> Home Assistant Core LXC </h1>

A standalone installation of Home Assistant Core

🛈 *If the LXC is created Privileged, the script will automatically set up USB passthrough.*

To create a new Proxmox Home Assistant Core LXC, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/homeassistant-core-v4.sh)"
```
 
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 8GB Storage - 2vCPU ⚡</h3>

⚠️ Initialize Home Assistant-Core (Only required once)

<sub>Run in the LXC console</sub>
```yaml
cd /srv/homeassistant && python3 -m venv . && source bin/activate && hass
```

***Home Assistant Interface - IP:8123***

⚙️ **Edit the HA configuration.yaml**

<sub>Run in the LXC console</sub>
```yaml
nano .homeassistant/configuration.yaml
```
<sub>Save and exit the editor with “Ctrl+O”, “Enter” and “Ctrl+X”</sub>
 
⚙️ **Install HACS:**

<sub>Run in the LXC console</sub>
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/hacs-core.sh)"
```
<sub>After install, reboot Home Assistant and **clear browser cache** then Add HACS integration.</sub>

⚙️ **Update Home Assistant**

<sub>Run in the LXC console</sub>
```yaml
systemctl stop homeassistant.service && source /srv/homeassistant/bin/activate && pip3 install --upgrade homeassistant && systemctl start homeassistant.service && exit
```
____________________________________________________________________________________________ 
</details>

<details>
<summary markdown="span"> Podman Home Assistant Container LXC </summary>
 
<p align="center"><img src="https://heise.cloudimg.io/width/223/q50.png-lossy-50.webp-lossy-50.foil1/_www-heise-de_/imgs/18/2/5/8/2/8/1/0/podman_logo-670078d7ea1d15a6.png" width="100" height="100"/>
<img src="https://avatars.githubusercontent.com/u/13844975?s=200&amp;v=4" alt="@home-assistant" width="100" height="100"/><img/><img src="https://raw.githubusercontent.com/SelfhostedPro/Yacht/master/readme_media/Yacht_logo_1_dark.png" height="80"/><img/></p>
 
<h1 align="center" id="heading"> Podman Home Assistant Container LXC </h1>
A standalone container-based installation of Home Assistant Core

⚠️ Podman seems to need a privileged LXC

To create a new Proxmox Podman Home Assistant Container LXC, run the following in the Proxmox Shell. 

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/podman-homeassistant-v4.sh)"
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
<summary markdown="span"> ioBroker LXC</summary>
 
<p align="center"><img src="https://github.com/ioBroker/ioBroker/blob/master/img/logos/ioBroker_Logo_256px.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> ioBroker LXC </h1>
 
[ioBroker](https://www.iobroker.net/#en/intro) is an open source automation platform.
 
To create a new Proxmox ioBroker LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/iobroker-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
**ioBroker Interface - IP:8081**

⚙️ **To Update ioBroker**

```yaml
update from the ioBroker UI
```

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> openHAB LXC</summary>
 
<p align="center"><img src="https://www.openhab.org/openhab-logo-square.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> openHAB LXC </h1>
 
[openHAB](https://www.openhab.org/), a vendor and technology agnostic open source automation software for your home.
 
To create a new Proxmox openHAB LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/openhab-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
**openHAB Interface - IP:8080**

⚙️ **To Update openHAB**

```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> Homebridge LXC</summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.dingz.ch%2Fadmin%2Fdata%2Ffiles%2Fintegration%2Flogo%2F20%2F200514-em-logo-homebridge_logo.png%3Flm%3D1589459081&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading"> Homebridge LXC </h1>

[Homebridge](https://homebridge.io/) allows you to integrate with smart home devices that do not natively support HomeKit

To create a new Proxmox Homebridge LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/homebridge-v4.sh)"
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
<summary markdown="span"> ESPHome LXC</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/esphome/dark_icon@2x.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> ESPHome LXC </h1>

[ESPHome](https://esphome.io/) is a system to control your ESP8266/ESP32 by simple yet powerful configuration files and control them remotely through Home Automation systems.

To create a new Proxmox ESPHome LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/esphome-v4.sh)"
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

[Nginx Proxy Manager](https://nginxproxymanager.com/) Expose your services easily and securely

To create a new Proxmox Nginx Proxy Manager LXC Container, run the following in the Proxmox Shell.

```yaml
 bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nginx-proxy-manager-v4.sh)"
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

[Eclipse Mosquitto](https://mosquitto.org/) is an open source message broker that implements the MQTT protocol

To create a new Proxmox MQTT LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/mqtt-v4.sh)"
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
<summary markdown="span"> EMQX LXC </summary>
 
<p align="center"><img src="https://github.com/hassio-addons/repository/blob/master/emqx/icon.png?raw=true" height="100"/></p>


<h1 align="center" id="heading"> EMQX LXC </h1>

[EMQX](https://www.emqx.io/) is an Open-source MQTT broker with a high-performance real-time message processing engine, powering event streaming for IoT devices at massive scale.

To create a new Proxmox EMQX LXC, run the following in the Proxmox Shell.

```yaml
 bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/emqx-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>


**EMQX Interface - IP:18083** 
 
⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 public
 ```
⚙️ **Setup**

Access Control ➡ Authentication  ➡ Create ➡ Next ➡ Next ➡ Create ➡ Users ➡ Add ➡ Username / Password (to authenicate with MQTT) ➡ Save. You're now ready to enjoy a high-performance MQTT Broker.

⚙️ **To Update EMQX**

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
 
[Node-RED](https://nodered.org/) is a programming tool for wiring together hardware devices, APIs and online services in new and interesting ways.

To create a new Proxmox Node-RED LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/node-red-v4.sh)"
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
<summary markdown="span"> n8n LXC</summary>
 
<p align="center"><img src="https://docs.n8n.io/_images/n8n-docs-icon.svg" height="70"/></p>

<h1 align="center" id="heading"> n8n LXC </h1>
 
[n8n](https://n8n.io/) is an extendable workflow automation tool which enables you to connect anything to everything.
 
To create a new Proxmox n8n LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/n8n-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 3GB Storage - 2vCPU ⚡</h3>
 
**n8n Interface: IP:5678**

⚙️ **To Update n8n**

```yaml
npm update -g n8n
```

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> Mariadb LXC </summary>
 
<p align="center"><img src="https://mariadb.com/wp-content/webp-express/webp-images/doc-root/wp-content/themes/sage/dist/images/mariadb-logo-white.png.webp" alt="MariaDB"/><img src="https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/adminer_logo-cl.png" height="60"></p>

<h1 align="center" id="heading"> Mariadb LXC </h1>
<h3 align="center"> Option to Install Adminer</h3>

[MariaDB](https://mariadb.org/) is a community-developed, commercially supported fork of the MySQL relational database management system.

To create a new Proxmox Mariadb LXC, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/mariadb-v4.sh)"
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
 
Example:
```yaml
recorder:
  db_url: mysql://admin:password@192.168.100.26:3306/homeassistant?charset=utf8mb4
```
 
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
<summary markdown="span"> PostgreSQL LXC </summary>
 
<p align="center"><img src="https://wiki.postgresql.org/images/3/30/PostgreSQL_logo.3colors.120x120.png" height="100"/><img src="https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/adminer_logo-cl.png" height="60"></p>

<h1 align="center" id="heading"> PostgreSQL LXC </h1>
<h3 align="center"> Option to Install Adminer</h3>

[PostgreSQL](https://www.postgresql.org/), also known as Postgres, is a free and open-source relational database management system emphasizing extensibility and SQL compliance.

To create a new Proxmox PostgreSQL LXC, run the following in the Proxmox Shell.
 
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/postgresql-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 1vCPU ⚡</h3>

To make sure our PostgreSQL is secured with a strong password, set a password for its system user and then change the default database admin user account

Change user password
```yaml
passwd postgres
```
Login using Postgres system account
 
```yaml
su - postgres
```
Now, change the Admin database password 
```yaml
psql -c "ALTER USER postgres WITH PASSWORD 'your-password';"
```
Create a new user.
```yaml
psql
```
```yaml
CREATE USER admin WITH PASSWORD 'your-password';
```
Create a new database:
```yaml
CREATE DATABASE homeassistant;
```
Grant all rights or privileges on created database to the user
```yaml
GRANT ALL ON DATABASE homeassistant TO admin;
```
To exit psql
```yaml
\q
``` 
Then type exit to get back to root

Change the recorder: `db_url:` in your HA configuration.yaml
 
Example:
```yaml
recorder:
  db_url: postgresql://admin:your-password@192.168.100.20:5432/homeassistant?client_encoding=utf8
``` 
⚙️ **To Update PostgreSQL**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```
⚙️ [**Adminer**](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/adminer.png) (formerly phpMinAdmin) is a full-featured database management tool
 
 `http://your-PostgreSQL-lxc-ip/adminer/`

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Zigbee2MQTT LXC </summary>
 
<p align="center"><img src="https://github.com/Koenkk/zigbee2mqtt/blob/master/images/logo_bee_only.png?raw=true" height="100"/></p>


<h1 align="center" id="heading">Zigbee2MQTT LXC </h1>

[Zigbee2MQTT](https://www.zigbee2mqtt.io/) is a standalone nodejs application that connects a zigbee network to MQTT

To create a new Proxmox Zigbee2MQTT LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/zigbee2mqtt-v4.sh)"
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
cd /opt/zigbee2mqtt && npm start
```
⚙️ **To update Zigbee2MQTT**
 
Run in the LXC console
 ```yaml
cd /opt/zigbee2mqtt && bash update.sh
 ```
⚙️ **Copy Data From a Existing Zigbee2MQTT LXC to another Zigbee2MQTT LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/z2m-copy-data.sh)"
 ```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> deCONZ LXC </summary>
 
<p align="center"><img src="https://phoscon.de/img/phoscon-logo128x.svg" height="100"/></p>

<h1 align="center" id="heading"> deCONZ LXC </h1>

[deCONZ](https://www.phoscon.de/en/conbee2/software#deconz) is used to configure, control and display Zigbee networks.

To create a new Proxmox deCONZ LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/deconz-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>

**deCONZ Interface - IP:80**

⚙️ **To Update deCONZ**

Run in the LXC Console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Z-Wave JS UI LXC </summary>
 
<p align="center"><img src="https://github.com/zwave-js/zwave-js-ui/blob/master/docs/_images/app_logo.svg?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Z-Wave JS UI LXC </h1>

[Z-Wave JS UI](https://github.com/zwave-js/zwave-js-ui#) is a fully configurable Z-Wave to MQTT Gateway and Control Panel.

To create a new Proxmox Z-Wave JS UI LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/zwave-js-ui-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>

**Z-Wave JS UI Interface - IP:8091**

⚙️ **Copy Data From a Existing Zwavejs2MQTT LXC to a Z-Wave JS UI LXC**

Run in the Proxmox Shell
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/zwave-copy-data.sh)"
 ```
⚙️ **To Update Z-Wave JS UI**

Run in the LXC Console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/zwave-js-ui-update.sh)"
```

____________________________________________________________________________________________ 
</details>

<details>
<summary markdown="span"> NocoDB LXC </summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/nocodb.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> NocoDB LXC </h1>

[NocoDB](https://www.nocodb.com/) is an open source #NoCode platform that turns any database into a smart spreadsheet. Airtable Alternative.

To create a new Proxmox NocoDB LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nocodb-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 1vCPU ⚡</h3>

**NocoDB Interface - IP:8080/dashboard**

⚙️ **To Update NocoDB**

Run in the LXC console
```yaml
cd /opt/nocodb && npm run upgrade
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Prometheus LXC </summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/prome.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Prometheus LXC </h1>

[Prometheus](https://prometheus.io/) is an open-source systems monitoring and alerting toolkit

To create a new Proxmox Prometheus LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/prometheus-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 4GB Storage - 1vCPU ⚡</h3>

**Prometheus Interface - IP:9090**

⚙️ **To Update Prometheus**

```yaml
Working On
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> InfluxDB LXC </summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.hopisystems.com%2Fassets%2Fimages%2Fintegrations%2Finfluxdb.png&f=1&nofb=1" height="150"/></p>

<h1 align="center" id="heading"> InfluxDB LXC </h1>

<h3 align="center"> Option to Install Telegraf</h3>

[InfluxDB](https://www.influxdata.com/) is an open-source time series database developed by the company InfluxData.

[Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) is an open source plugin-driven server agent for collecting and reporting metrics.

To create a new Proxmox InfluxDB LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/influxdb-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

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

[Grafana](https://grafana.com/) is a multi-platform open source analytics and interactive visualization web application.

To create a new Proxmox Grafana LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/grafana-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
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
<h3 align="center"> Options to Install Portainer and/or Docker Compose V2</h3>

[Docker](https://www.docker.com/) is an open-source project for automating the deployment of applications as portable, self-sufficient containers.

To create a new Proxmox Docker LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/docker-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 4GB Storage - 2vCPU ⚡</h3>

**⚠ Run Compose V2 by replacing the hyphen (-) with a space, using docker compose, instead of docker-compose.**

**Portainer Interface - IP:9000**

⚙️ **To Update**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> CasaOS LXC </summary>

<p align="center"><img src="https://www.casaos.io/img/casa.svg" height="100"/></p>

<h1 align="center" id="heading"> CasaOS LXC </h1>
 
[CasaOS](https://www.casaos.io/) is a community-based open source software focused on delivering simple home cloud experience around Docker ecosystem.


To create a new Proxmox CasaOS LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/casaos-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

**CasaOS Interface - IP**

⚙️ **To Update CasaOS**

```yaml
update from the CasaOS UI
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Debian LXC </summary>
 
<p align="center"><img src="https://www.debian.org/Pics/debian-logo-1024x576.png" alt="Debian" height="100"/></p>

<h1 align="center" id="heading"> Debian LXC </h1>
<h3 align="center" id="heading"> Option to select version 10 or 11</h3>

To create a new Proxmox Debian (curl & sudo) LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/debian-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

⚙️ **To Update Debian**

Run in the LXC console
```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span"> Ubuntu LXC </summary>
 
<p align="center"><img src="https://assets.ubuntu.com/v1/29985a98-ubuntu-logo32.png" alt="Ubuntu" height="100"/></p>

<h1 align="center" id="heading"> Ubuntu LXC </h1>
<h3 align="center" id="heading"> Option to select version 18.04, 20.04, 21.10 or 22.04</h3>

To create a new Proxmox Ubuntu (curl & sudo) LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/ubuntu-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU - 22.04 ⚡</h3>

⚙️ **To Update Ubuntu**

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

<h3 align="center"> With Local Controller Option </h3>

An application designed to optimize UniFi home and business networks with ease.

To create a new Proxmox UniFi Network Application LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/unifi-v4.sh)"
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
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/omada-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

**Omada Interface - https:// IP:8043**

`tpeap status` show status of Omada Controller

`tpeap start`  start Omada Controller

`tpeap stop`   stop Omada Controller
 
⚙️ **To Update Omada**

[#403](https://github.com/tteck/Proxmox/issues/402#issue-1328460983)

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Plex Media Server LXC </summary>

<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/plex/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Plex Media Server LXC </h1>
<h3 align="center" id="heading"> With Hardware Acceleration Support </h3> 
To create a new Proxmox Plex Media Server LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/plex-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

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
<summary markdown="span"> Emby Media Server LXC </summary>
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/emby/icon.png?raw=true" height="100"/></p>
<h1 align="center" id="heading"> Emby Media Server LXC </h1>

[Emby](https://emby.media/) brings together your personal videos, music, photos, and live television.

To create a new Proxmox Emby Media Server LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/emby-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

**Emby Media Server Interface - IP:8096**

⚙️ **Emby Media Server Utilizes Automatic Updates**

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Jellyfin Media Server LXC </summary>
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/jellyfin/icon.png?raw=true" height="100"/></p>
<h1 align="center" id="heading"> Jellyfin Media Server LXC </h1>

[TurnKey has a LXC CT for Jellyfin](https://www.turnkeylinux.org/mediaserver)

To create a new Proxmox Jellyfin Media Server LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/jellyfin-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

**Jellyfin Media Server Interface - IP:8096**

FFmpeg path: `/usr/lib/jellyfin-ffmpeg/ffmpeg`

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

[Pi-hole](https://pi-hole.net/) is a Linux network-level advertisement and Internet tracker blocking application which acts as a DNS sinkhole and optionally a DHCP server.

To create a new Proxmox Pi-hole LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/pihole-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

⚠️ **Reboot Pi-hole LXC after install**

**Pi-hole Interface - http:// IP/admin**

⚙️ **To set your password:**
 
Run in the LXC console

```yaml
pihole -a -p
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Technitium DNS LXC</summary>
 
<p align="center"><img src="https://avatars.githubusercontent.com/u/12230362?s=100&v=4" height="100"/></p>

<h1 align="center" id="heading"> Technitium DNS LXC </h1>
An open source authoritative as well as recursive DNS server

To create a new Proxmox Technitium DNS LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/technitiumdns-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>
 
**Technitium DNS Interface - IP:5380**

⚙️ **To Update Technitium DNS**

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/technitiumdns-update.sh)"
```
__________________________________________________________________________________________ 

</details>
 
 
<details>
<summary markdown="span"> AdGuard Home LXC</summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/adguard/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> AdGuard Home LXC </h1>

To create a new Proxmox AdGuard Home LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/adguard-v4.sh)"
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
<summary markdown="span"> Uptime Kuma LXC </summary>
 
<p align="center"><img src="https://github.com/louislam/uptime-kuma/blob/master/public/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Uptime Kuma LXC </h1>

Uptime Kuma is a self-hosted, open source, fancy uptime monitoring and alerting system. It can monitor  HTTP(s) / TCP / HTTP(s) Keyword / Ping / DNS Record / Push / Steam Game Server.

To create a new Proxmox Uptime Kuma LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/uptimekuma-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 2GB Storage - 1vCPU ⚡</h3>

**Uptime Kuma Interface - IP:3001**

⚙️ **To Update Uptime Kuma**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/uptimekuma-update.sh)"
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Whoogle LXC </summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/whoogle.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Whoogle LXC </h1>

Get Google search results, but without any ads, javascript, AMP links, cookies, or IP address tracking.

To create a new Proxmox Whoogle LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/whoogle-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

**Whoogle Interface - IP:5000**

⚙️ **To Update Whoogle**

Run in the LXC console
```yaml
pip3 install whoogle-search --upgrade
```
____________________________________________________________________________________________ 

</details>


<details>
<summary markdown="span"> Paperless-ngx LXC </summary>
 
<p align="center"><img src="https://github.com/paperless-ngx/paperless-ngx/blob/main/resources/logo/web/svg/square.svg?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Paperless-ngx LXC </h1>
 
[Paperless-ngx](https://paperless-ngx.readthedocs.io/en/latest/#) is a document management system that transforms your physical documents into a searchable online archive so you can keep, well, less paper.

To create a new Proxmox Paperless-ngx LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/paperless-ngx-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2048MiB RAM - 4GB Storage - 2vCPU ⚡</h3>

**Paperless-ngx Interface - IP:8000**

🛈 A paperless.creds file is in root home directory that contains the usernames and passwords.

Run in the LXC Console
```yaml
cat paperless.creds
```

⚙️ **To Update Paperless-ngx**

Run in the LXC Console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/paperless-ngx-update.sh)"
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Trilium LXC </summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/zadam/trilium/master/images/app-icons/png/128x128.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Trilium LXC </h1>
 
[Trilium](https://github.com/zadam/trilium#trilium-notes) is a hierarchical note taking application with focus on building large personal knowledge bases.

To create a new Proxmox Trilium LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/trilium-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

**Trilium Interface - IP:8080**

⚙️ **To Update Trilium**

Run in the LXC Console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/trilium-update.sh)"
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Wiki.js LXC </summary>
 
<p align="center"><img src="https://static.requarks.io/logo/wikijs-butterfly.svg?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Wiki.js LXC </h1>
 
[Wiki.js](https://js.wiki/) is a modern, lightweight and powerful wiki app built on NodeJS. 

To create a new Proxmox Wiki.js LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/wikijs-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

**Wiki.js Interface - IP:3000**

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Heimdall Dashboard LXC</summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/heimdall.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Heimdall Dashboard LXC </h1>

[Heimdall Application Dashboard](https://camo.githubusercontent.com/bcfd4f74c93b25bea7b14eacbafd649206bf754a3d4b596329968f0ee569cf3c/68747470733a2f2f692e696d6775722e636f6d2f4d72433451704e2e676966) is a dashboard for all your web applications. It doesn't need to be limited to applications though, you can add links to anything you like.

To create a new Proxmox Heimdall Dashboard LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/heimdalldashboard-v4.sh)"
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
<summary markdown="span"> Homepage LXC </summary>

<p align="center"><img src="https://github.com/benphelps/homepage/raw/main/images/homepage-light.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Homepage LXC </h1>
 
[Homepage](https://github.com/benphelps/homepage) is a self-hosted dashboard.

To create a new Proxmox Homepage LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/homepage-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 3GB Storage - 2vCPU ⚡</h3>

[Configuration](https://github.com/benphelps/homepage/wiki) (bookmarks.yaml, services.yaml, widgets.yaml) path: `/opt/homepage/config/`

**Homepage Interface - IP:3000**

⚙️ **To Update Homepage**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/homepage-update.sh)"
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Dashy LXC</summary>
 
<p align="center"><img src="https://github.com/Lissy93/dashy/raw/master/public/web-icons/dashy-logo.png" height="100"/></p>

<h1 align="center" id="heading"> Dashy LXC </h1>

Dashy helps you organize your self-hosted services by making them accessible from a single place

To create a new Proxmox Dashy LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/dashy-v4.sh)"
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
<summary markdown="span"> grocy LXC </summary>
 
<p align="center"><img src="https://grocy.info/img/grocy_logo.svg" height="100"/></p>

<h1 align="center" id="heading"> grocy LXC </h1>

[grocy](https://grocy.info/) is a web-based self-hosted groceries & household management solution for your home.

To create a new Proxmox grocy LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/grocy-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

**grocy Interface: http:// IP**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 admin
 ```
 
⚙️ **To Update grocy**
 
Run in the LXC console
 ```yaml
bash /var/www/html/update.sh
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> MagicMirror Server LXC </summary>

<p align="center"><img src="https://github.com/MichMich/MagicMirror/raw/master/.github/header.png" height="100"/></p>

<h1 align="center" id="heading"> MagicMirror Server LXC </h1>
 
[MagicMirror²](https://docs.magicmirror.builders/) is an open source modular smart mirror platform.

To create a new MagicMirror Server LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/magicmirror-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings: 512MiB RAM - 3GB Storage - 1vCPU ⚡</h3>

**MagicMirror Interface - IP:8080**

⚙️ **[Configuration](https://docs.magicmirror.builders/configuration/introduction.html#configuring-your-magicmirror)**
```yaml
/opt/magicmirror/config/config.js
```
⚙️ **[Update MagicMirror](https://docs.magicmirror.builders/getting-started/upgrade-guide.html#upgrade-guide)**

Run in the LXC Console
```yaml
cd /opt/magicmirror && git pull && npm install --only=prod --omit=dev
```


____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Daemon Sync Server LXC</summary>
 
<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimg.informer.com%2Ficons_mac%2Fpng%2F128%2F350%2F350335.png&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading"> Daemon Sync Server LXC </h1>

Sync files from app to server, share photos & videos, back up your data and stay secure inside local network.

To create a new Proxmox Daemon Sync Server LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/daemonsync-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 8GB Storage - 1vCPU ⚡</h3>
 
**Daemon Sync Server Interface - IP:8084**
 
Search: `DAEMON Sync` in your favorite app store

__________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> NextCloudPi LXC</summary>
 
<p align="center"><img src="https://github.com/nextcloud/nextcloudpi/blob/master/ncp-app/img/app.svg?raw=true" height="100"/></p>

<h1 align="center" id="heading">NextCloudPi LXC </h1>

[NextCloudPi LXC](https://github.com/nextcloud/nextcloudpi#features) is the most popular self-hosted collaboration solution.

To create a new Proxmox NextCloudPi LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nextcloudpi-v4.sh)"
```
<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
❗1️. Set nc trusted domains

Run in the LXC console
```
sudo ncp-config
```
Go to config ➡ nc-trusted-domains, add `0.0.0.0` or a static NextCloudPi IP

Get back to the command prompt, and restart Apache2 `sudo service apache2 restart`

❗2. **NextCloudPi Interface - https:// IP/**

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> OpenMediaVault LXC </summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/omv.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> OpenMediaVault LXC </h1>

[OpenMediaVault](https://www.openmediavault.org/) is the next generation network attached storage (NAS) solution based on Debian Linux.

To create a new Proxmox OpenMediaVault LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/omv-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>

**OpenMediaVault Interface - IP**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 openmediavault
 ```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Navidrome LXC </summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/navidrome/navidrome/master/resources/logo-192x192.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Navidrome LXC </h1>
 
[Navidrome](https://www.navidrome.org/) allows you to enjoy your music collection from anywhere, by making it available through a modern Web UI and through a wide range of third-party compatible mobile apps, for both iOS and Android devices. 

To create a new Proxmox Navidrome LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/navidrome-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 4GB Storage - 2vCPU ⚡</h3>

To change Navidrome music folder path, edit: `/var/lib/navidrome/navidrome.toml`

**Navidrome Interface - IP:4533**

⚙️ **To Update Navidrome**

Run in the LXC Console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/navidrome-update.sh)"
```

____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> PhotoPrism LXC </summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/photoprism.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> PhotoPrism LXC </h1>
 
[PhotoPrism](https://photoprism.app/) is an AI-powered app for browsing, organizing & sharing your photo collection. 

To create a new Proxmox PhotoPrism LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/photoprism-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

**PhotoPrism Interface - IP:2342**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 changeme
 ```
[PhotoSync](https://www.photosync-app.com/home.html)

⚙️ **To Update or Change Branch**

Run in the LXC Console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/photoprism-update.sh)"
```
____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> MotionEye VMS LXC </summary>
 
<p align="center"><img src="https://github.com/home-assistant/brands/blob/master/core_integrations/motioneye/icon.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> MotionEye VMS LXC </h1>

To create a new Proxmox MotionEye VMS LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/motioneye-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>

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
<summary markdown="span"> File Browser</summary>
 
<p align="center"><img src="https://github.com/tteck/Proxmox/blob/main/misc/images/filebrowser.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> File Browser </h1>

To Install File Browser, ⚠️ run the following in the LXC console.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/filebrowser.sh)"
```

[File Browser](https://filebrowser.org/features) is a create-your-own-cloud-kind of software where you can install it on a server, direct it to a path and then access your files through a nice web interface. Many available features!



**File Browser Interface - http:// IP:8080**

⚙️ **Initial Login**

**username** 
 ```yaml
 admin
 ```
 **password** 
 ```yaml
 changeme
 ```
 
⚙️ **To Update File Browser**

```yaml
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
```
___________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> VS Code Server</summary>
 
<p align="center"><img src="https://user-images.githubusercontent.com/674621/71187801-14e60a80-2280-11ea-94c9-e56576f76baf.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> VS Code Server </h1>

To Install VS Code Server, ⚠️ run the following in the LXC console.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/code-server.sh)"
```

[VS Code Server](https://code.visualstudio.com/docs/remote/vscode-server) is a service you can run on a remote development machine, like your desktop PC or a virtual machine (VM). It allows you to securely connect to that remote machine from anywhere through a vscode.dev URL, without the requirement of SSH.



**VS Code Server Interface - http:// IP:8680**

___________________________________________________________________________________________ 

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
<summary markdown="span"> Syncthing LXC</summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/syncthing/syncthing/6afaa9f20c8eb9c7af5abbe2f2d90fa2571aa7ad/assets/logo-only.svg?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Syncthing LXC </h1>
 
[Syncthing](https://syncthing.net/) is a continuous file synchronization program. It synchronizes files between two or more computers.
 
To create a new Proxmox Syncthing LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/syncthing-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  2GB RAM - 8GB Storage - 2vCPU ⚡</h3>
 
⚙️ For the initial start, run `syncthing --gui-address=0.0.0.0:8384` in the LXC console, then go to the LXC IP:8384 In settings set the LXC IP address under the GUI (also set the GUI Authentication User and GUI Authentication Password) and Connections tab's and save. Reboot the LXC. 

**Syncthing Interface - IP:8384**

⚙️ **To Update Syncthing**

```yaml
apt update && apt upgrade -y
```

____________________________________________________________________________________________ 
 
</details>

<details>
<summary markdown="span"> WireGuard LXC </summary>

<p align="center"><img src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn.icon-icons.com%2Ficons2%2F2699%2FPNG%2F512%2Fwireguard_logo_icon_168760.png&f=1&nofb=1" height="100"/></p>

<h1 align="center" id="heading"> WireGuard LXC </h1>
<h3 align="center"> With WGDashboard </h3>
 
To create a new Proxmox WireGuard LXC, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/wireguard-v4.sh)"
```

<h3 align="center" id="heading">⚡ Default Settings:  512MiB RAM - 2GB Storage - 1vCPU ⚡</h3>

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
<summary markdown="span"> MeshCentral LXC</summary>
 
<p align="center"><img src="https://github.com/Ylianst/MeshCentral/blob/master/public/favicon-303x303.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> MeshCentral LXC </h1>

[MeshCentral](https://meshcentral.com/info/) is a full computer management web site. With MeshCentral, you can run your own web server to remotely manage and control computers on a local network or anywhere on the internet.

To create a new Proxmox MeshCentral LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/meshcentral-v4.sh)"
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
<summary markdown="span"> Tailscale</summary>
 
<p align="center"><img src="https://avatars.githubusercontent.com/u/48932923?v=4&s=100"/></p>

<h1 align="center" id="heading"> Tailscale</h1>

[Tailscale](https://tailscale.com/) Creates a secure network between your servers, computers, and cloud instances. Even when separated by firewalls or subnets, Tailscale just works.

To Install Talescale on an existing LXC, run the following in the Proxmox Shell (replace `106` with your LXC ID).

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/add-tailscale-lxc.sh)" -s 106
```
After the script finishes, reboot the LXC then run `tailscale up` in the LXC console

[**Tailscale Login**](https://login.tailscale.com/start)

⚙️ **To Update Tailscale**
 
Run in the LXC console
 ```yaml
apt update && apt upgrade -y
```

___________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> CrowdSec</summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/crowdsecurity/crowdsec-docs/main/crowdsec-docs/static/img/crowdsec_no_txt.png?raw=true" height="100"/></p>

<h1 align="center" id="heading"> CrowdSec</h1>

To Install CrowdSec, ⚠️ run the following in the LXC console.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/crowdsec.sh)"
```

[CrowdSec](https://crowdsec.net/) is a free, open-source and collaborative IPS. Analyze behaviors, respond to attacks & share signals across the community.

[**Control center for your CrowdSec machines.**](https://app.crowdsec.net/product-tour)

___________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Keycloak LXC</summary>
 
<p align="center"><img src="https://www.keycloak.org/resources/images/keycloak_icon_512px.svg?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Keycloak LXC</h1>

To create a new Proxmox Keycloak LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/keycloak-v4.sh)"
```

[Keycloak](https://www.keycloak.org/) is an Open Source Identity and Access Management solution for modern Applications and Services.

**Keycloak Interface - http:// IP:8080** (First start can take a few minutes)

⚙️ **Initial Login**

The initial admin user can be added manually using the web frontend when accessed from localhost or automatically using environment variables.

To add the initial admin user using environment variables, set `KEYCLOAK_ADMIN` for the initial admin username and `KEYCLOAK_ADMIN_PASSWORD` for the initial admin password.
 
First, stop Keycloak
```yaml
systemctl stop keycloak.service
```
then start Keycloak by coping & pasting the following (only needed once)
```yaml
cd /opt/keycloak
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=changeme

bin/kc.sh start-dev 
```
⚙️ **To Update Keycloak**

```yaml
working On
```
___________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Mikrotik RouterOS VM </summary>
 
<p align="center"><img src="https://mikrotik.com/img/mtv2/newlogo.svg?raw=true" height="100"/></p>

<h1 align="center" id="heading"> Mikrotik RouterOS VM </h1>
 
[Mikrotik RouterOS](https://wiki.mikrotik.com/wiki/Manual:TOC) can be installed on a PC and will turn it into a router with all the necessary features - routing, firewall, bandwidth management, wireless access point, backhaul link, hotspot gateway, VPN server and more. 

To create a new Proxmox Mikrotik RouterOS VM, run the following in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/vm/mikrotik-routeros-v4.sh)"
```
Setup is done via VM console.

<h3 align="center" id="heading">⚡ Default Settings:  1GB RAM - 2GB Storage - 1CPU ⚡</h3>


____________________________________________________________________________________________ 

</details>

<details>
<summary markdown="span"> Vaultwarden LXC</summary>
 
<p align="center"><img src="https://raw.githubusercontent.com/dani-garcia/vaultwarden/main/resources/vaultwarden-icon-white.svg" width="100" height="100"/></p>

<h1 align="center" id="heading"> Vaultwarden LXC </h1>

Alternative implementation of the Bitwarden server API written in Rust and compatible with upstream [Bitwarden clients](https://bitwarden.com/download/), perfect for self-hosted deployment where running the official resource-heavy service might not be ideal.
 
To create a new Proxmox Vaultwarden LXC, run the following in the Proxmox Shell.

```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/vaultwarden-v4.sh)"
```
⚠️ Vaultwarden needs to be behind a proxy (Nginx Proxy Manager) to obtain HTTPS and to allow clients to connect.

The script builds from source, which takes time and resources. After the build, the script will automatically set resources to Normal Settings. 

Expect 30+ minute install time.
<h3 align="center" id="heading">⚡ Build Settings:  2048Mib RAM - 6GB Storage - 2vCPU ⚡</h3>
<h3 align="center" id="heading">⚡ Normal Settings:  512Mib RAM - 6GB Storage - 1vCPU ⚡</h3>

**Vaultwarden Interface: CTIP:8000**

⚙️ **Path to Vaultwarden .env file** (to find the `ADMIN_TOKEN`)
```yaml
/opt/vaultwarden/.env
```
 
⚙️ **To Update Vaultwarden (post 2022-05-29 installs only)**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/vaultwarden-update.sh)"
```
⚙️ **To Update Web-vault (any)**

Run in the LXC console
```yaml
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/web-vault-update.sh)"
```

____________________________________________________________________________________________ 

</details>
