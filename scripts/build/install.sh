#!/local/bin/env bash

set -o errexit
set -o pipefail

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

# Validation
if [ "$(id -u)" -ne 0 ]; then
  die "Script must be run as root"
fi

# Validate that USERNAME is set
[ -z "$USERNAME" ] && die "USERNAME is required (this is a non-root container setup)"
USER_UID=1000
USER_GID=$USER_UID
HOME_DIR="/home/${USERNAME}"

# Exit if USERNAME already exists
if id -u ${USERNAME} > /dev/null 2>&1; then
    die "User ${USERNAME} should not exist prior to install.sh execution."
fi

# Create user and group
groupadd --gid $USER_GID $USERNAME
useradd --uid $USER_UID --gid $USER_GID -m $USERNAME



    # # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    # && apt-get update \
    # && apt-get install -y sudo \
    # && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    # && chmod 0440 /etc/sudoers.d/$USERNAME


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


