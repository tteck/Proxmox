## Zigbee2MQTT Device Troubleshooting ##


**Alternative method:**

In the Proxmox web shell run (replace `105` with your lxc Id)
```
nano /etc/pve/lxc/105.conf
```
replace the last 4 lines
```
lxc.cgroup2.devices.allow: c 188:* rwm
lxc.mount.entry: /dev/serial/by-id               dev/serial/by-id        none bind,optional,create=dir
lxc.mount.entry: /dev/ttyUSB0                    dev/ttyUSB0             none bind,optional,create=file
lxc.mount.entry: /dev/ttyACM0                    dev/ttyACM0             none bind,optional,create=file
```
with these 4 lines (change `cgroup2` with `cgroup` for PVE6)
```
lxc.cgroup2.devices.allow: a
lxc.cap.drop: 
lxc.autodev: 1
lxc.hook.autodev: bash -c 'for char_dev in $(find /sys/dev/char -regextype sed  -regex ".*/1:1" -o -regex ".*/4:\([3-9]\|[1-5][0-9]\|6[0-3]\)" -o -regex ".*/4:\(6[4-9]\|[7-9][0-9]\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)" -o -regex ".*/10:200" -o -regex ".*/116:.*" -o -regex ".*/166:.*" -o -regex ".*/180:\([0-9]\|1[0-5]\)" -o -regex ".*/188:.*" -o -regex ".*/189:.*" -o -regex ".*/24[0-2]:.*"); do  dev="/dev/$(sed -n "/DEVNAME/ s/^.*=\(.*\)$/\1/p" ${char_dev}/uevent)";  mkdir -p $(dirname ${LXC_ROOTFS_MOUNT}${dev});  for link in $(udevadm info --query=property $dev | sed -n "s/DEVLINKS=//p"); do    mkdir -p ${LXC_ROOTFS_MOUNT}$(dirname $link);    cp -dpR $link ${LXC_ROOTFS_MOUNT}${link};  done;  cp -dpR $dev ${LXC_ROOTFS_MOUNT}${dev};done;'
```
Reboot the LXC
________________________________________________________________________________________________________________________________________
