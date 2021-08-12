<h1 align="center" id="heading"> Select Proxmox Helper Below </h1>
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
