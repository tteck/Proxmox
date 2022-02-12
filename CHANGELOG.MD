
# Change Log
All notable changes to this project will be documented in this file.

## 2022-02-12

### Changed

- **Home Assistant Container LXC (Podman)**
  - Add Yacht web interface for managing Podman containers
  - new GUI script (ha-copy-data-podman.sh) to copy data from a **Home Assistant LXC** to a **Podman Home Assistant LXC**

## 2022-02-10

### Changed

- **GamUntu LXC**
  - New script
- **Jellyfin Media Server LXC**
  - new script to fix [start issue](https://github.com/tteck/Proxmox/issues/29#issue-1127457380)
- **MotionEye NVR LXC**
  - New script

## 2022-02-09

### Changed

- **Zigbee2MQTT LXC**
  - added USB passthrough during installation (no extra script)
  - Improve documentation
- **Zwavejs2MQTT LXC**
  - added USB passthrough during installation (no extra script)
- **Jellyfin Media Server LXC**
  - Moved to testing due to issues. 
  - Changed install method.
- **Home Assistant Container LXC (Podman)** 
  - add script for easy Home Assistant update

## 2022-02-06

### Changed

- **Debian 11 LXC**
  - Add Docker Support
- **Ubuntu 21.10 LXC**
  - Add Docker Support

## 2022-02-05

### Changed

- **Vaultwarden LXC**
  - New script

## 2022-02-01

### Changed

- **All Scripts**
  - Fix issue where some networks were slow to assign a IP address to the container causing scripts to fail.

## 2022-01-30

### Changed

- **Zigbee2MQTT LXC**
  - Clean up / Improve script
  - Improve documentation

## 2022-01-29

### Changed

- **Node-Red LXC**
  - Clean up / Improve script
  - Improve documentation

## 2022-01-25

### Changed

- **Jellyfin Media Server LXC**
  - new script

## 2022-01-24

### Changed

- **Plex Media Server LXC**
  - better Hardware Acceleration Support
  - `va-driver-all` is preinstalled
  - now using Ubuntu 21.10
- **misc**
  - new GUI script [(Screenshot)](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/pms-copy-data.png) to copy data from one Plex Media Server LXC to another Plex Media Server LXC 


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
