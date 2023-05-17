<h3><div align="center">Exploring the Scripts and Steps Involved in an Application LXC Installation</div></h3>

In the case of the AdGuard Home LXC, the process involves running multiple scripts for each application or service.<br>
Initially, the [adguard.sh](https://github.com/tteck/Proxmox/blob/main/ct/adguard.sh) script is executed to collect system parameters.<br>
Next, the [build.func](https://github.com/tteck/Proxmox/blob/main/misc/build.func) script adds user settings and integrates all the collected information.<br>
Then, the [create_lxc.sh](https://github.com/tteck/Proxmox/blob/main/ct/create_lxc.sh) script constructs the LXC container.<br>
Following that, the [adguard-install.sh](https://github.com/tteck/Proxmox/blob/main/install/adguard-install.sh) script is executed, which utilizes the functions exported from the [install.func](https://github.com/tteck/Proxmox/blob/main/misc/install.func) script for installing the required applications.<br>
Finally, the process returns to the [adguard.sh](https://github.com/tteck/Proxmox/blob/main/ct/adguard.sh) script to display the completion message.<br>

Thoroughly evaluating the [adguard-install.sh](https://github.com/tteck/Proxmox/blob/main/install/adguard-install.sh) script is crucial to gain a better understanding of the application installation process.<br>
Every application installation utilizes the same set of reusable scripts: [build.func](https://github.com/tteck/Proxmox/blob/main/misc/build.func), [create_lxc.sh](https://github.com/tteck/Proxmox/blob/main/ct/create_lxc.sh), and [install.func](https://github.com/tteck/Proxmox/blob/main/misc/install.func). These scripts are not specific to any particular application.<br>
