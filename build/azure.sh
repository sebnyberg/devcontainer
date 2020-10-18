#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Sebastian Nyberg. All rights reserved.
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Syntax: ./azure.sh
#
# Based on: https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/azcli-debian.sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install curl, apt-transport-https, lsb-release, or gpg if missing
if ! dpkg -s apt-transport-https curl ca-certificates lsb-release > /dev/null 2>&1 || ! type gpg > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends apt-transport-https curl ca-certificates lsb-release gnupg2 
fi

# Install the Azure CLI
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list
curl -sL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT)
apt-get update
apt-get install -y azure-cli
echo "Done!"

# echo "$(cat << EOM
# # Azure
# if type az &>/dev/null && ! az account show &>/dev/null; then
#     az login
#     az acr login -n sisrp &>/dev/null
#     az acr login -n sisrisk &>/dev/null
#     az acr login -n insights &>/dev/null
# fi
# EOM
# )" >> /etc/bash.bashrc