#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# Co-Author: remz1337
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Installed Dependencies"

msg_info "Installing Peanut"
# WORKDIR /app

# COPY --link package.json pnpm-lock.yaml* ./

# SHELL ["/bin/ash", "-xeo", "pipefail", "-c"]
# RUN npm install -g pnpm

# RUN --mount=type=cache,id=pnpm-store,target=/root/.local/share/pnpm/store pnpm fetch | grep -v "cross-device link not permitted\|Falling back to copying packages from store"

# RUN --mount=type=cache,id=pnpm-store,target=/root/.local/share/pnpm/store pnpm install -r --offline

# FROM node:20-alpine as build

# WORKDIR /app

# COPY --link --from=deps /app/node_modules ./node_modules/
# COPY . .

# RUN npm run telemetry && npm run build

# FROM node:20-alpine as runner

# LABEL org.opencontainers.image.title "PeaNUT"
# LABEL org.opencontainers.image.description "A tiny dashboard for Network UPS Tools"
# LABEL org.opencontainers.image.url="https://github.com/Brandawg93/PeaNUT"
# LABEL org.opencontainers.image.source='https://github.com/Brandawg93/PeaNUT'
# LABEL org.opencontainers.image.licenses='Apache-2.0'

# COPY --link package.json next.config.js ./

# COPY --from=build --link /app/.next/standalone ./
# COPY --from=build --link /app/.next/static ./.next/static

# ENV NODE_ENV production
# ENV NUT_HOST localhost
# ENV NUT_PORT 3493
# ENV WEB_HOST 0.0.0.0
# ENV WEB_PORT 8080

# EXPOSE $WEB_PORT

# HEALTHCHECK --interval=10s --timeout=3s --start-period=20s \
  # CMD wget --no-verbose --tries=1 --spider --no-check-certificate http://$WEB_HOST:$WEB_PORT/api/ping || exit 1

# CMD ["npm", "start"]


msg_ok "Installed Peanut"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/peanut.service
[Unit]
Description=Peanut
After=network.target
[Service]
SyslogIdentifier=peanut
Restart=always
RestartSec=5
Type=simple
Environment="NODE_ENV=production"
Environment="NUT_HOST=localhost"
Environment="NUT_PORT=3493"
Environment="WEB_HOST=0.0.0.0"
Environment="WEB_PORT=8080"
WorkingDirectory=/opt/peanut
ExecStart=/opt/peanut/peanut
TimeoutStopSec=30
[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now peanut.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"