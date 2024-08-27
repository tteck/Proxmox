#!/bin/bash

# Author: jpaveg
# Adapted from: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
header_info() {
    clear
    cat <<"EOF"
    ____                                                       
   / __ \_________  _  ______ ___  ____  _  __                 
  / /_/ / ___/ __ \| |/_/ __ `__ \/ __ \| |/_/                 
 / ____/ /  / /_/ />  </ / / / / / /_/ />  <                   
/_/   /_/   \____/_/|_/_/ /_/ /_/\____/_/|_|                   
                                                               
    ____                  __  __                           __  
   / __ \____ ___________/ /_/ /_  _________  __  ______ _/ /_ 
  / /_/ / __ `/ ___/ ___/ __/ __ \/ ___/ __ \/ / / / __ `/ __ \
 / ____/ /_/ (__  |__  ) /_/ / / / /  / /_/ / /_/ / /_/ / / / /
/_/    \__,_/____/____/\__/_/ /_/_/   \____/\__,_/\__, /_/ /_/ 
                                                 /____/        
   _____           _       __                                  
  / ___/__________(_)___  / /_                                 
  \__ \/ ___/ ___/ / __ \/ __/                                 
 ___/ / /__/ /  / / /_/ / /_                                   
/____/\___/_/  /_/ .___/\__/                                   
                /_/                                            
EOF
}

RD=$(echo "\033[01;31m")
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

set -euo pipefail
shopt -s inherit_errexit nullglob

GRUB_FILE="/etc/default/grub"
GRUB_FILE_BACKUP="/etc/default/grub.bak"
SYSTEMD_FILE="/etc/kernel/cmdline"
SYSTEMD_FILE_BACKUP="/etc/kernel/cmdline.bak"
MODULES_FILE="/etc/modules"
MODULES_FILE_BACKUP="/etc/modules.bak"

CPU_TYPE="unknown"

msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_error() {
    local msg="$1"
    echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

check_cpu_type() {
    msg_info "Checking CPU Type"
    # Check the Vendor ID using lscpu
    vendor_id=$(lscpu | grep "Vendor ID")
    vendor_id=$(echo $vendor_id | awk '{print $3}')

    if [ "$vendor_id" == "GenuineIntel" ]; then
        msg_info "Intel CPU detected"
        CPU_TYPE="intel"
    elif [ "$vendor_id" == "AuthenticAMD" ]; then
        msg_info "AMD CPU detected"
        CPU_TYPE="amd"
    else
        msg_error "Unknown CPU vendor, exiting"
        exit
    fi
}

modify_grub_cmdline() {
    # Make a backup of the GRUB file
    sudo cp $GRUB_FILE $GRUB_FILE_BACKUP

    # Extract the content of GRUB_CMDLINE_LINUX_DEFAULT using sed
    cmdline_flags=$(sed -n 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/\1/p' "$GRUB_FILE")

    # Initialize an associative array to hold key-value pairs
    declare -A kv_pairs
    # Initialize a string to hold flags
    flags=""

    # Iterate over each item in the cmdline_flags
    for item in $cmdline_flags; do
        if [[ "$item" != *"="* ]]; then
            # If it's a flag, add it to the flags string
            flags="$flags $item"
        else
            # If it's a key-value pair, split it and add to associative array
            IFS='=' read -r key value <<<"$item"
            kv_pairs["$key"]="$value"
        fi
    done

    # Use whiptail to ask user if they want to enable IOMMU passthrough mode
    if (whiptail --title "GRUB - IOMMU Passthrough" --yesno "Do you want to enable IOMMU passthrough mode?" 10 60); then
        kv_pairs["iommu"]="pt"
    else
        unset kv_pairs["iommu"] # Remove the key if the user selects "No"
    fi

    # Check if CPU_TYPE is Intel before enabling Intel IOMMU
    if [ "$CPU_TYPE" == "intel" ]; then
        if (whiptail --title "GRUB - Intel IOMMU" --yesno "Do you want to enable Intel IOMMU?" 10 60); then
            kv_pairs["intel_iommu"]="on"
        else
            unset kv_pairs["intel_iommu"] # Remove the key if the user selects "No"
        fi
    fi

    # Reconstruct the new GRUB_CMDLINE_LINUX_DEFAULT line
    new_cmdline_flags="$flags"
    for key in "${!kv_pairs[@]}"; do
        new_cmdline_flags="$new_cmdline_flags $key=${kv_pairs[$key]}"
    done

    # Remove leading space
    new_cmdline_flags=$(echo "$new_cmdline_flags" | sed 's/^ //')

    # Set the updated flags and key-value pairs in GRUB file
    msg_info "Setting GRUB_CMDLINE_LINUX_DEFAULT flags"
    sudo sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/ s/\(GRUB_CMDLINE_LINUX_DEFAULT=\).*/\1\"$new_cmdline_flags\"/" $GRUB_FILE

    # Output the updated GRUB_CMDLINE_LINUX_DEFAULT line for verification
    msg_ok "Modified /etc/default/grub: GRUB_CMDLINE_LINUX_DEFAULT=\"$new_cmdline_flags\""

    # Run update-grub to finish changes
    msg_info "Running update-grub to finalize changes to cmdline"
    # sudo update-grub
}

modify_systemd_boot_cmdline() {
    # Make a backup of the cmdline file
    sudo cp "$SYSTEMD_FILE" "$SYSTEMD_FILE_BACKUP"

    # Extract the content of the cmdline file
    cmdline_flags=$(cat "$SYSTEMD_FILE")

    # Initialize an associative array to hold key-value pairs
    declare -A kv_pairs
    # Initialize a string to hold flags
    flags=""

    # Iterate over each item in the cmdline_flags
    for item in $cmdline_flags; do
        if [[ "$item" != *"="* ]]; then
            # If it's a flag, add it to the flags string
            flags="$flags $item"
        else
            # If it's a key-value pair, split it and add to associative array
            IFS='=' read -r key value <<<"$item"
            kv_pairs["$key"]="$value"
        fi
    done

    # Use whiptail to ask user if they want to enable IOMMU passthrough mode
    if (whiptail --title "SYSTEMD - IOMMU Passthrough" --yesno "Do you want to enable IOMMU passthrough mode?" 10 60); then
        kv_pairs["iommu"]="pt"
    else
        unset kv_pairs["iommu"] # Remove the key if the user selects "No"
    fi

    # Check if CPU_TYPE is Intel before enabling Intel IOMMU
    if [ "$CPU_TYPE" == "intel" ]; then
        if (whiptail --title "SYSTEMD - Intel IOMMU" --yesno "Do you want to enable Intel IOMMU?" 10 60); then
            kv_pairs["intel_iommu"]="on"
        else
            unset kv_pairs["intel_iommu"] # Remove the key if the user selects "No"
        fi
    fi

    # Reconstruct the new kernel cmdline
    new_cmdline_flags="$flags"
    for key in "${!kv_pairs[@]}"; do
        new_cmdline_flags="$new_cmdline_flags $key=${kv_pairs[$key]}"
    done

    # Remove leading space
    new_cmdline_flags=$(echo "$new_cmdline_flags" | sed 's/^ //')

    # Set the updated flags and key-value pairs in cmdline file
    msg_info "Setting kernel cmdline flags"
    echo -n "$new_cmdline_flags" | sudo tee "$SYSTEMD_FILE" >/dev/null

    # Output the updated cmdline for verification
    msg_ok "Modified /etc/kernel/cmdline: \"$new_cmdline_flags\""

    # Run proxmox-boot-tool refresh to apply changes
    msg_info "Running proxmox-boot-tool refresh to apply changes"
    # sudo proxmox-boot-tool refresh
}

modify_kernel_modules() {
    # List of required modules
    required_modules=("vfio" "vfio_iommu_type1" "vfio_pci")

    # Check the kernel version
    KERNEL_VERSION=$(uname -r | cut -d'-' -f1)
    KERNEL_MAJOR=$(echo "$KERNEL_VERSION" | cut -d'.' -f1)
    KERNEL_MINOR=$(echo "$KERNEL_VERSION" | cut -d'.' -f2)

    # Add vfio_virqfd only if the kernel version is older than 6.2
    if [ "$KERNEL_MAJOR" -lt 6 ] || { [ "$KERNEL_MAJOR" -eq 6 ] && [ "$KERNEL_MINOR" -lt 2 ]; }; then
        echo $KERNEL_MAJOR $KERNEL_MINOR $KERNEL_VERSION
        required_modules+=("vfio_virqfd")
    fi

    # Make a backup of the current modules file
    sudo cp "$MODULES_FILE" "$MODULES_FILE_BACKUP"

    # Load current modules into an associative array for quick lookup
    declare -A current_modules
    if [ -f "$MODULES_FILE" ]; then
        while IFS= read -r line; do
            # Skip empty lines and comments
            [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]] && continue
            current_modules["$line"]=1
        done <"$MODULES_FILE"
    fi

    # Initialize a flag to track if we need to update the modules file
    update_needed=false

    # Check each required module and add it if not present
    for module in "${required_modules[@]}"; do
        # Use a default value for the lookup to avoid unbound variable errors
        if [[ -z "${current_modules[$module]+x}" ]]; then
            echo "$module" | sudo tee -a "$MODULES_FILE" >/dev/null
            update_needed=true
            msg_info "Added $module to $MODULES_FILE"
        else
            msg_ok "$module is already present in $MODULES_FILE"
        fi
    done

    # Refresh initramfs if we added any new modules
    if [ "$update_needed" = true ]; then
        msg_info "Updating initramfs to apply module changes"
        sudo update-initramfs -u -k all
        msg_ok "Initramfs updated successfully"
    else
        msg_ok "No changes needed for $MODULES_FILE"
    fi
}

# Main
start_routines() {
    header_info
    check_cpu_type

    # Display a whiptail menu for the user to choose an option
    OPTION=$(whiptail --title "Select Command Line Modification" --menu "Choose an option:" 15 60 4 \
        "1" "Modify GRUB cmdline" \
        "2" "Modify systemd-boot cmdline" \
        "3" "Modify both cmdlines" \
        "4" "Exit" 3>&1 1>&2 2>&3)

    # Act based on the user's choice
    case $OPTION in
    "1")
        modify_grub_cmdline
        ;;
    "2")
        modify_systemd_boot_cmdline
        ;;
    "3")
        modify_grub_cmdline || msg_error "There was an error modifying the GRUB cmdline, continuing to next step."
        modify_systemd_boot_cmdline || msg_error "There was an error modifying the SYSTEMD-BOOT cmdline, continuing to next step."
        ;;
    "4")
        echo "Exiting without making any changes."
        ;;
    *)
        echo "Invalid option. Exiting."
        ;;
    esac
    echo "Debug: Calling modify_kernel_modules"
    modify_kernel_modules
}

echo -e "\nThis script will modify your cmdline and kernel flags to enable passthrough & vfio.\n"
while true; do
    read -p "Start the Proxmox VE Passthrough Script (y/n)?" yn
    case $yn in
    [Yy]*) break ;;
    [Nn]*)
        clear
        exit
        ;;
    *) echo "Please answer yes or no." ;;
    esac
done

if ! pveversion | grep -Eq "pve-manager/8.[0-2]"; then
    msg_error "This version of Proxmox Virtual Environment is not supported"
    echo -e "Requires Proxmox Virtual Environment Version 8.0 or later."
    echo -e "Exiting..."
    sleep 2
    exit
fi

start_routines

# Notification to the user
echo -e "\n\nScript execution complete."

# Notify the user about the need to reboot and verify IOMMU
echo -e "To apply the changes, please reboot your system."

# Provide instructions to verify IOMMU is enabled
echo -e "After rebooting, run the following command to ensure IOMMU is enabled:"
echo -e "    dmesg | grep -e DMAR -e IOMMU -e AMD-Vi"

# Inform about the backup files
echo -e "\nBackup files have been created for your safety:"
echo -e "    $GRUB_FILE_BACKUP"
echo -e "    $SYSTEMD_FILE_BACKUP"
echo -e "    $MODULES_FILE_BACKUP"

# Provide link for further information
echo -e "\nFor more information or if you encounter issues, please visit:"
echo -e "    https://pve.proxmox.com/wiki/PCI(e)_Passthrough"
