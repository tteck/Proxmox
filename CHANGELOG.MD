
# Change Log
All notable changes to this project will be documented in this file.
 
 
## Initial Catch up - 2022-01-23
 
### Changed

- **Zwavejs2MQTT LXC**
  - created new script to solve no auto start at boot
- **Nginx Proxy Manager LXC** 
  - created new script to use Debian 11
- **Ubuntu 21.10 LXC** 
  - created new script
- **Mariadb LXC** 
  - added MariaDB Package Repository
- **MQTT LXC** 
  - added Eclipse Mosquitto Repository
- **Home Assistant Container LXC** 
  - added if the script detects ZFS filesystem it's an automatic installation of static fuse-overlayfs.  
  - added script for easy Home Assistant update
- **Home Assistant Container LXC (Podman)** 
  - added if the script detects ZFS filesystem it's an automatic installation of static fuse-overlayfs.
- **Home Assistant OS VM** 
  - changed disk type from SATA to SCSI to follow Proxmox official recommendations of choosing VirtIO-SCSI with SCSI disk
  - cleaned up script
- **Proxmox VE 7 Post Install** 
  - new *No-Nag* method
