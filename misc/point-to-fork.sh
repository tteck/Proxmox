#!/bin/bash

# Copyright (c) 2021-2023 tteck
# Author: Jimi (JimiHFord)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

# Ensure script will function regardless of user's current working directory
# Get the directory of the script
script_dir="$(dirname "$(readlink -f "$0")")"
# Get project root directory
repo_dir="$(dirname "$(readlink -f "$script_dir")")"

# Check if the number of arguments is correct
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GitHub Username> <Fork (e.g. Proxmox)> <Branch (e.g. main)>"
    exit 1
fi
old_string="https://raw.githubusercontent.com/tteck/Proxmox/main"
gh_user=$1
gh_fork=$2
gh_branch=$3
new_string="https://raw.githubusercontent.com/$gh_user/$gh_fork/$gh_branch"

# Replace string recursively in files
find "$repo_dir" -type f \( -name "*.sh" -o -name "*.func" \) -exec sed -i.bak "s|$old_string|$new_string|g" {} +

echo "Replacement completed. Backup files with .bak extension created."
