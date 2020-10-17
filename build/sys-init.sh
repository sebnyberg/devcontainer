#!/local/bin/env bash

set -o errexit
set -o pipefail

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

# Validation
if [ "$(id -u)" -ne 0 ]; then
  die "Script must be run as root"
fi

# Avoid prompts from apt
export DEBIAN_FRONTEND=noninteractive

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

# Install base packages
apt-get-update-if-needed

PACKAGE_LIST="apt-utils \
    git \
    openssh-client \
    gnupg2 \
    iproute2 \
    procps \
    lsof \
    htop \
    net-tools \
    psmisc \
    curl \
    wget \
    rsync \
    ca-certificates \
    unzip \
    zip \
    nano \
    vim-tiny \
    less \
    jq \
    lsb-release \
    apt-transport-https \
    dialog \
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu[0-9][0-9] \
    liblttng-ust0 \
    libstdc++6 \
    zlib1g \
    locales \
    sudo \
    ncdu \
    man-db \
    libssl1.1"

apt-get -y install --no-install-recommends ${PACKAGE_LIST} 

# Set Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen 
locale-gen