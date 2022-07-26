<a href="https://tteck.github.io/Proxmox/"><img src="https://github-readme-stats.vercel.app/api?username=tteck&theme=blue-green" height="130"/></a>

# Change Log
All notable changes to this project will be documented in this file.

## 2022-07-26

### Changed

- **Home Assistant OS VM** 
  - Set the real time clock (RTC) to local time.
  - Disable the USB tablet device (save resources / not needed).

## 2022-07-24

### Changed

- **Home Assistant OS VM** 
  - Present the drive to the guest as a solid-state drive rather than a rotational hard disk. There is no requirement that the underlying storage actually be backed by SSD's. 
  - When the VM’s filesystem marks blocks as unused after deleting files, the SCSI controller will relay this information to the storage, which will then shrink the disk image accordingly.
  - 👉 [more info](https://github.com/tteck/Proxmox/discussions/378)

## 2022-07-22

### Changed

- **n8n LXC** (thanks to @cyakimov)
  - NEW Script

## 2022-07-21

### Changed

- **grocy LXC**
  - NEW Script

## 2022-07-17

### Changed

- **Vaultwarden LXC**
  - NEW Vaultwarden Update (post 2022-05-29 installs only) Script
  - NEW Web-vault Update (any) Script

## 2022-07-14

### Changed

- **MagicMirror Server LXC**
  - NEW Script

## 2022-07-13

### Changed

- **Proxmox Edge Kernel Tool**
  - NEW Script

## 2022-07-11

### Changed

- **Home Assistant OS VM**
  - Supports lvmthin, zfspool, nfs, dir and btrfs storage types.

## 2022-07-08

### Changed

- **openHAB LXC**
  - NEW Script

## 2022-07-03

### Changed

- **Tailscale**
  - NEW Script

## 2022-07-01

### Changed

- **Home Assistant OS VM**
  - Allow different storage types (lvmthin, nfs, dir).

## 2022-06-30

### Changed

- **Prometheus LXC**
  - NEW Script

## 2022-06-06

### Changed

- **Whoogle LXC**
  - NEW Script

## 2022-05-29

### Changed

- **Vaultwarden LXC**
  - Code refactoring
- **CrowdSec**
  - NEW Script

## 2022-05-21

### Changed

- **Home Assistant OS VM**
  - Code refactoring

## 2022-05-19

### Changed

- **Keycloak LXC**
  - NEW Script

## 2022-05-18

### Changed

- **File Browser**
  - NEW Script

## 2022-05-13

### Changed

- **PostgreSQL LXC**
  - NEW Script

## 2022-05-10

### Changed

- **deCONZ LXC**
  - NEW Script

## 2022-05-07

### Changed

- **NocoDB LXC**
  - ADD update script

## 2022-05-06

### Changed

- **PhotoPrism LXC**
  - ADD GO Dependencies for full functionality

## 2022-05-05

### Changed

- **Ubuntu LXC**
  - ADD option to define version (18.04 20.04 21.10 22.04)

## 2022-04-28

### Changed

- **v3 Script**
  - Remove Internet Check

## 2022-04-27

### Changed

- **Home Assistant OS VM**
  - ADD Option to set Bridge, VLAN and MAC Address
- **v3 Script**
  - Improve Internet Check (prevent ‼ ERROR 4@57)

## 2022-04-26

### Changed

- **Home Assistant OS VM**
  - Fixed bad path
  - ADD Option to create VM using Latest or Stable image
- **UniFi Network Application LXC**
  - ADD Local Controller Option

## 2022-04-25

### Changed

- **v3 Script**
  - Improve Error Handling

## 2022-04-23

### Changed

- **v3 Script**
  - ADD Internet Connection Check
- **Proxmox VE 7 Post Install**
  - NEW v3 Script
- **Proxmox Kernel Clean**
  - NEW v3 Script

## 2022-04-22

### Changed

- **Omada Controller LXC**
  - Update script to install version 5.1.7
- **Uptime Kuma LXC**
  - ADD Update script

## 2022-04-20

### Changed

- **Ubuntu LXC**
  - ADD option to install version 20.04 or 21.10
- **v3 Script**
  - ADD option to set Bridge

## 2022-04-19

### Changed

- **ALL LXC's**
  - New [V3 Install Script](https://github.com/tteck/Proxmox/issues/162) 
- **ioBroker LXC**
  - New Script V3

## 2022-04-13

### Changed

- **Uptime Kuma LXC**
  - New Script V2

## 2022-04-11

### Changed

- **Proxmox LXC Updater**
  - ADD option to skip stopped containers
- **Proxmox VE 7 Post Install**
  - ADD PVE 7 check

## 2022-04-10

### Changed

- **Debian 11 LXC**
  - ADD An early look at the v3 install script

## 2022-04-09

### Changed

- **NocoDB LXC**
  - New Script V2

## 2022-04-05

### Changed

- **MeshCentral LXC**
  - New Script V2

## 2022-04-01

### Changed

- **Scripts** (V2)
  - FIX Pressing enter without making a selection first would cause an Error 

## 2022-03-28

### Changed

- **Docker LXC**
  - Add Docker Compose Option (@wovalle)

## 2022-03-27

### Changed

- **Heimdall Dashboard LXC**
  - New Update Script

## 2022-03-26

### Changed

- **UniFi Network Application LXC**
  - New Script V2
- **Omada Controller LXC**
  - New Script V2

## 2022-03-25

### Changed

- **Proxmox CPU Scaling Governor**
  - New Script


## 2022-03-24

### Changed

- **Plex Media Server LXC**
  - Switch to Ubuntu 20.04 to support HDR tone mapping
- **Docker LXC**
  - Add Portainer Option

## 2022-03-23

### Changed

- **Heimdall Dashboard LXC**
  - New Script V2

## 2022-03-20

### Changed

- **Scripts** (V2)
  - ADD choose between Automatic or Manual DHCP  

## 2022-03-18

### Changed

- **Technitium DNS LXC**
  - New Script V2
- **WireGuard LXC**
  - Add WGDashboard

## 2022-03-17

### Changed

- **Docker LXC**
  - New Script V2

## 2022-03-16

### Changed

- **PhotoPrism LXC**
  - New Update/Branch Script

## 2022-03-15

### Changed

- **Dashy LXC**
  - New Update Script

## 2022-03-14

### Changed

- **Zwavejs2MQTT LXC**
  - New Update Script

## 2022-03-12

### Changed

- **PhotoPrism LXC**
  - New Script V2

## 2022-03-11

### Changed

- **Vaultwarden LXC**
  - New V2 Install Script

## 2022-03-08

### Changed

- **Scripts** (V2)
  - Choose between Privileged or Unprivileged CT and Automatic or Password Login 
- **ESPHome LXC**
  - New V2 Install Script
- **Zwavejs2MQTT LXC**
  - New V2 Install Script
- **Motioneye LXC**
  - New V2 Install Script
- **Pihole LXC**
  - New V2 Install Script
- **GamUntu LXC**
  - New V2 Install Script

## 2022-03-06

### Changed

- **Zwavejs2MQTT LXC**
  - New GUI script to copy data from one Zwavejs2MQTT LXC to another Zwavejs2MQTT LXC

## 2022-03-05

### Changed

- **Homebridge LXC**
  - New Script V2

## 2022-03-04

### Changed

- **Proxmox Kernel Clean**
  - New Script

## 2022-03-03

### Changed

- **WireGuard LXC**
  - New Script V2

## 2022-03-02

### Changed

- **Proxmox LXC Updater**
  - New Script
- **Dashy LXC**
  - New Script V2
- **Grafana LXC**
  - New Script V2
- **InfluxDB/Telegraf LXC**
  - New Script V2

## 2022-03-01

### Changed

- **Daemon Sync Server LXC**
  - New Script V2

## 2022-02-28

### Changed

- **Vaultwarden LXC**
  - Add Update Script

## 2022-02-24

### Changed

- **Nginx Proxy Manager LXC**
  - New V2 Install Script

## 2022-02-23

### Changed

- **Adguard Home LXC**
  - New V2 Install Script
- **Zigbee2MQTT LXC**
  - New V2 Install Script
- **Home Assistant Container LXC**
  - Update Menu usability improvements

## 2022-02-22

### Changed

- **Home Assistant Container LXC**
  - New V2 Install Script
- **Node-Red LXC**
  - New V2 Install Script
- **Mariadb LXC**
  - New V2 Install Script
- **MQTT LXC**
  - New V2 Install Script
- **Debian 11 LXC**
  - New V2 Install Script
- **Ubuntu 21.10 LXC**
  - New V2 Install Script

## 2022-02-20

### Changed

- **Home Assistant Container LXC**
  - New Script to migrate to the latest Update Menu

## 2022-02-19

### Changed

- **Nginx Proxy Manager LXC**
  - Add Update Script
- **Vaultwarden LXC**
  - Make unattended install & Cleanup Script

## 2022-02-18

### Changed

- **Node-Red LXC**
  - Add Install [Themes Script](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/node-red-themes.png)

## 2022-02-16

### Changed

- **Home Assistant Container LXC**
  - Add Options to [Update Menu](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/update-menu.png)

## 2022-02-14

### Changed

- **Home Assistant Container LXC**
  - Add [Update Menu](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/update-menu.png)

## 2022-02-13

### Changed

- **Mariadb LXC**
  - Add [Adminer](https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/adminer.png) (formerly phpMinAdmin), a full-featured database management tool

## 2022-02-12

### Changed

- **Home Assistant Container LXC (Podman)**
  - Add Yacht web interface for managing Podman containers
  - new GUI script to copy data from a **Home Assistant LXC** to a **Podman Home Assistant LXC**
  - Improve documentation for several LXC's

## 2022-02-10

### Changed

- **GamUntu LXC**
  - New Script
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
  - new GUI script to copy data from one Home Assistant LXC to another Home Assistant LXC
  - new GUI script to copy data from one Zigbee2MQTT LXC to another Zigbee2MQTT LXC
