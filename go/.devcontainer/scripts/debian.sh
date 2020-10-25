#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Sebastian Nyberg. All rights reserved.
# Licensed under the MIT License. See LICENSE.
#-------------------------------------------------------------------------------------------------------------

set -o errexit
set -o pipefail

INIT_RC=${INIT_RC-"true"}

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

if [ "$(id -u)" -ne 0 ]; then
  die "Script must be run as root"
fi

# Function to call apt-get if needed
apt-get-update-if-needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

if [[ -z "$USERNAME" ]]; then
    echo >2 "USERNAME is required"
    exit 1
fi

# Create user
groupadd --gid $USER_GID $USERNAME
useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME

# Avoid prompts from apt
export DEBIAN_FRONTEND=noninteractive

# Install base packages
apt-get-update-if-needed
apt-get -y install --no-install-recommends \
    apt-transport-https \
    apt-utils \
    bash-completion \
    ca-certificates \
    curl \
    dialog \
    git \
    gnupg2 \
    htop \
    iproute2 \
    jq \
    less \
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu[0-9][0-9] \
    liblttng-ust0 \
    libssl1.1 \
    libstdc++6 \
    locales \
    lsb-release \
    lsof \
    man-db \
    nano \
    ncdu \
    net-tools \
    openssh-client \
    procps \
    psmisc \
    rsync \
    sudo \
    unzip \
    vim \
    vim-tiny \
    wget \
    zip \
    zlib1g 

# Add Tini
TINI_VERSION=${TINI_VERSION-"v0.19.0"}
curl -sSL -o /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini
chmod +x /tini

# Bash setup
echo "$(cat << EOF
export USER=\$(whoami)

export PATH=\$PATH:\$HOME/.local/bin
EOF
)" >> /etc/bash.bashrc

# Set Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen 
locale-gen
