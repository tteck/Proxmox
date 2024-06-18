#!/usr/bin/env bash

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

APP_VERSION=4.0.9

# https://glitchtip.com/documentation/install#installing-without-docker
apt-get install -y git

apt-get install -y \
  python3 \
  python3-dev \
  python3-pip \
  python3-poetry \
  unzip \
  celery \
  redis \
  postgresql \
  libpq-dev \
  sudo
pip install uwsgi

wget -O backend.tar.gz https://gitlab.com/glitchtip/glitchtip-backend/-/archive/v${APP_VERSION}/glitchtip-backend-v${APP_VERSION}.tar.gz
mkdir -p /opt/glitchtip
tar zxvf backend.tar.gz --strip-components=1 -C /opt/glitchtip
wget -O assets.zip https://gitlab.com/api/v4/projects/15449363/jobs/artifacts/v${APP_VERSION}/download?job=build-assets
unzip assets.zip
mv dist/glitchtip-frontend /opt/glitchtip/dist
cd /opt/glitchtip
poetry install --no-root
sudo -u postgres createdb glitchtip
sudo -u postgres psql glitchtip -c "create user glitchtip password 'glitchtip'"
sudo -u postgres psql glitchtip -c "grant all privileges on database glitchtip to glitchtip"
sudo -u postgres psql glitchtip -c "grant all on database glitchtip TO glitchtip"
sudo -u postgres psql glitchtip -c "grant usage, create on schema public to glitchtip"
export DATABASE_URL=postgresql://glitchtip:glitchtip@localhost/glitchtip
poetry run ./manage.py migrate
poetry run ./manage.py collectstatic

SECRET_KEY=$(openssl rand -hex 32)

# TODO Default EMAIL_URL value?

# EMAIL_URL=consolemail://
cat <<EOF >/etc/glitchtip.env
EMAIL_URL=smtp://:@ntfy:2500
DATABASE_URL=$DATABASE_URL
REDIS_HOST=127.0.0.1
SECRET_KEY=$SECRET_KEY
DEFAULT_FROM_EMAIL=glitchtip@glitchtip.local
GLITCHTIP_DOMAIN=http://glitchtip
PORT=8000
CELERY_WORKER_AUTOSCALE=1,3
CELERY_WORKER_MAX_TASKS_PER_CHILD=10000
EOF

cat <<EOF >/etc/systemd/system/glitchtip-worker.service
[Unit]
Description=GlitchTip Celery Service
After=network.target
[Service]
WorkingDirectory=/opt/glitchtip
ExecStart=poetry run /opt/glitchtip/bin/run-celery-with-beat.sh
EnvironmentFile=/etc/glitchtip.env
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/glitchtip.service
[Unit]
Description=GlitchTip
After=network.target
[Service]
WorkingDirectory=/opt/glitchtip
ExecStart=poetry run /opt/glitchtip/bin/start.sh
EnvironmentFile=/etc/glitchtip.env
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now glitchtip.service
systemctl enable --now glitchtip-worker.service

motd_ssh
customize

apt-get autoremove
apt-get autoclean
