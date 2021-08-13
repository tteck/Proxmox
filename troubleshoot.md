If no device is found after running `ls -l /dev/serial/by-id` reboot the zigbee2mqtt lxc and try again.

Make sure Proxmox sees the device by running `ls -l /dev/serial/by-id` from the Proxmox web shell.

If Proxmox sees your device, you can try setting autodev by running the below script from the Proxmox web shell.
```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/tteck/Proxmox/main/autodev.sh)" -s 100
```
:warning: change `100` to your LXC ID.

Note: The changes will apply after a reboot of the LXC
________________________________________________________________________________________________________________________________________
