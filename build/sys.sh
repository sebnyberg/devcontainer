#!/local/bin/env bash

set -o errexit
set -o pipefail

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

# Validation
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

# Avoid prompts from apt
export DEBIAN_FRONTEND=noninteractive

# Install base packages
apt-get-update-if-needed
apt-get -y install --no-install-recommends \
    apt-transport-https \
    apt-utils \
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
    socat \
    sudo \
    unzip \
    vim-tiny \
    wget \
    zip \
    zlib1g 

# Add Tini
TINI_VERSION=${TINI_VERSION-"v0.19.0"}
curl -sSL -o /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini
chmod +x /tini

# Install Docker
curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT)
echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-get -y install --no-install-recommends docker-ce-cli

# Install Docker Compose
LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")')
curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Set Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen 
locale-gen