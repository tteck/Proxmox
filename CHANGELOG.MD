
# Change Log
All notable changes to this project will be documented in this file.
 
## 2022-01-24

### Changed

- **Plex Media Server LXC**
  - better Hardware Acceleration Support
  - `va-driver-all` is preinstalled
  - now using Ubuntu 21.10
- **misc**
  - new GUI script (pms-copy-data.sh) to copy data from one Plex Media Server LXC to another Plex Media Server LXC (info inside script)


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
  - change if ZFS filesystem is detected, execute automatic installation of static fuse-overlayfs
  - add script for easy Home Assistant update
- **Home Assistant Container LXC (Podman)** 
  - change if ZFS filesystem is detected, execute automatic installation of static fuse-overlayfs
- **Home Assistant OS VM** 
  - change disk type from SATA to SCSI to follow Proxmox official recommendations of choosing VirtIO-SCSI with SCSI disk
  - clean up
- **Proxmox VE 7 Post Install** 
  - new *No-Nag* method
- **misc**
  - new GUI script (ha-copy-data.sh) to copy data from one Home Assistant LXC to another Home Assistant LXC (info inside script)
  - new GUI script (z2m-copy-data.sh) to copy data from one Zigbee2MQTT LXC to another Zigbee2MQTT LXC (info inside script)
