#!/usr/bin/env bash

echo -e "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh &>/dev/null
echo -e "Installed Tailscale"
