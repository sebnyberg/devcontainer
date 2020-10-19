#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Sebastian Nyberg. All rights reserved.
# Licensed under the MIT License. See LICENSE.
#-------------------------------------------------------------------------------------------------------------

set -o errexit
set -o pipefail

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

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
useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME

# Add add sudo support for non-root user
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME