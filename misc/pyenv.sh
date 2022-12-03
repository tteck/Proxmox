#!/usr/bin/env bash
set -e
echo "Installing pyenv"
apt-get install -y \
make \
build-essential \
libjpeg-dev \
libpcap-dev \
libssl-dev \
zlib1g-dev \
libbz2-dev \
libreadline-dev \
libsqlite3-dev \
autoconf \
git \
llvm \
libncursesw5-dev \
xz-utils \
tk-dev \
libxml2-dev \
libxmlsec1-dev \
libffi-dev \
libopenjp2-7 \
libtiff5 \
libturbojpeg0-dev \
liblzma-dev &>/dev/null

git clone https://github.com/pyenv/pyenv.git ~/.pyenv &>/dev/null

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init --path)"\nfi' >> ~/.bashrc  
echo "Installed pyenv"
echo "Restarting Shell"
echo "Run pyenv2.sh to finish"
exec $SHELL
