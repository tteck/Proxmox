# Set up a Home Assistant OS VM using Proxmox VE 7 (2022)

This guide will help you set up a Home Assistant OS VM, on almost any x86/64 machine type you choose using Proxmox VE 7 as the operating system.
This guide also utilizes scripts to simplify the installation process, always remember to use due diligence when sourcing scripts and automation tasks from third-party sites.

This installation uses an **Official KVM Image provided by the Home Assistant Team and is considered a supported installation method**. This method of installation is considered easy/medium difficulty and some knowledge of how to use and interact with Linux is suggested.

If you have an existing Home Assistant installation and would like to know how to backup your current configuration to restore later, please see the documentation on [backing up and restoring your configuration](https://www.home-assistant.io/common-tasks/supervised/#making-a-backup-from-the-ui).

## Installing Proxmox VE 7

* You will want to ensure **UEFI Boot & Virtualisation is enabled and Secure Boot is disabled** in the [bios](https://www.lifewire.com/how-to-enter-bios-2624481) of your machine.

* Download the [Proxmox VE 7.x ISO Installer](https://www.proxmox.com/en/downloads/category/iso-images-pve).

* You will now need to make a bootable USB drive using [balenaEtcher](https://www.balena.io/etcher/). Using a USB drive of at least **8gb**, insert it into your PC, open Etcher, select the Proxmox VE image you just downloaded, select your USB drive, then click Flash.

* Insert the bootable USB drive you just made into the machine you wish to install Proxmox VE on. Connect a monitor, Ethernet cable, keyboard, mouse, and power on the machine. If the machine doesn't boot from the USB drive automatically, you will need to enter the boot options menu by pressing Esc, F2, F10 or F12, (This relies on the company of the computer or motherboard) on your keyboard immediately when the machine is powering on. 

* When you see the first screen, select Install Proxmox VE and press Enter. The installer will perform some automated tasks for 1-2 minutes.

* On the EULA screen, select, I Agree.

* On the Proxmox Virtualization Environment (PVE) screen, you will get the option to choose which disk you want to install Proxmox VE on. When finished, click Next.

* On the Location and Time Zone selection, Type your country, then select your time zone and change the keyboard layout if needed. When finished, click Next

* On the Administration password and E-mail address screen, choose a password (**make sure you don’t forget it**), confirm your password and enter a valid email address. When finished, click Next

* On the Management network configuration screen.
   * Management interface Should auto populate with the network interface (Ethernet) of your machine. If not, select the network interface.
   * Hostname (FQDN) - The first part of the hostname is what your node will be called under Datacenter, you might want to change this to something more friendly now, the default is “pve” (eg. proxmox.lan).
   * IP Address - Should auto populate. If the IP address looks odd here and not at all like the address range of your other devices, it’s possible you may not be connected to your network, so check your network cable and start again.
   * Netmask - Should auto populate and be something like `255.255.255.0` depending on your network configuration.
   * Gateway - Should auto populate to the IP address of your router. If not, make sure you're connected to your network
   * DNS server - Should auto populate to the same IP address as your gateway. Or, input one of your choosing. When finished, click Next

* Next on the Summary screen, confirm that all of the details are correct. When confirmed click Install.

Proxmox VE will install and is finished once it displays its IP address on the screen. **Take note of the IP address!** It's needed to access Proxmox via a web browser. Remove the USB drive, and click Reboot. While the machine is rebooting, you can unplug the monitor, keyboard and mouse, as they're no longer needed.

After 1-2 minutes, you should be able to access Proxmox VE via a web browser using the noted IP address from above (eg. `http://192.168.1.10:8006`) If you see a message "Warning: Potential Security Risk Ahead", you can safely ignore this, accept the risk and continue. Login with User name: `root` and the password you created on the Administration password and E-mail address screen. 

## Configuring and Updating Proxmox VE 7

Before installing Home Assistant OS, you will want to make sure that Proxmox VE has the latest updates and security patches installed. This has been made very simple with a [script](https://github.com/tteck/Proxmox/raw/main/misc/post-install-v3.sh).

To run the Proxmox VE 7 Post Install script, copy and paste the following command in the Proxmox Shell.
```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-install-v3.sh)"
```
It's recommended to answer `y` to all questions.

## Installing Home Assistant OS

Installing Home Assistant OS using Proxmox VE has been made very simple with a [script](https://github.com/tteck/Proxmox/raw/main/vm/haos-vm-v3.sh).

To run the Home Assistant OS VM install script, copy and paste the following command in the Proxmox Shell.

```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/vm/haos-vm-v3.sh)"
```
It's recommended to press [ENTER] to use the default settings. (Advanced settings are available for changing settings such as mac, bridge, vlan, ect...) It will then download the Official KVM Image from the Home Assistant github and configure it in Proxmox VE for you. This will take 2-20 minutes depending on your internet connection and machine.

Once this has finished, you will see **✓ Completed Successfully!**.

The Home Assistant OS VM will be assigned a different IP address than the one Proxmox VE is using. To find the IP address of the newly created Home Assistant OS VM, click on the VM (eg. haos8.2) then click Summary from the menu list, wait for Guest Agent to start. The IP address listed here is needed to access Home Assistant via a web browser using port 8123 (eg. `http://192.168.1.50:8123`).

Once you can see the login screen, the setup has been completed and you can create a new account and password (or restore a backup).

That’s it, you have now set up Home Assistant OS using Proxmox VE 7

This guide uses many resources from the famous "Installing Home Assistant OS using Proxmox 7" guide from @kanga_who

The above scripts (and more) can be found at https://github.com/tteck/Proxmox
