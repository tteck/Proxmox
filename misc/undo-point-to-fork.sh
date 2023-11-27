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

find "$repo_dir" -type f -name "*.bak" -exec sh -c 'mv "$1" "${1%.bak}"' _ {} \;
echo "Undo operation completed. Backup files restored."