
# Change Log
All notable changes to this project will be documented in this file.
 
 
## Initial Catch up - 2022-01-23
 
### Changed

- **Plex Media Server LXC**
  - add Hardware Acceleration Support
  - add script to install Intel Drivers
- **Zwavejs2MQTT LXC**
  - new script to solve no auto start at boot
- **Nginx Proxy Manager LXC** 
  - new script to use Debian 11
- **Ubuntu 21.10 LXC** 
  - new script
- **Mariadb LXC** 
  - add MariaDB Package Repository
- **MQTT LXC** 
  - add Eclipse Mosquitto Package Repository
- **Home Assistant Container LXC** 
  - change if ZFS filesystem is detected, automatic installation of static fuse-overlayfs is executed.  
  - add script for easy Home Assistant update
- **Home Assistant Container LXC (Podman)** 
  - change if ZFS filesystem is detected, automatic installation of static fuse-overlayfs is executed. 
- **Home Assistant OS VM** 
  - change disk type from SATA to SCSI to follow Proxmox official recommendations of choosing VirtIO-SCSI with SCSI disk
  - clean up
- **Proxmox VE 7 Post Install** 
  - new *No-Nag* method
- **misc**
  - new GUI script (ha-copy-data.sh) to copy data from a Home Assistant LXC to another Home Assistant LXC (info inside script)
  - new GUI script (z2m-copy-data.sh) to copy data from a Zigbee2MQTT LXC to another Zigbee2MQTT LXC (info inside script)
