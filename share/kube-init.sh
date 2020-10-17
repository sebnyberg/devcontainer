#!/local/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -o errexit
set -o pipefail

if [ -d "/usr/local/share/kube-localhost" ]; then
    mkdir -p $HOME/.kube
    sudo cp -r /usr/local/share/kube-localhost/* $HOME/.kube
    sudo chown -R $(id -u) $HOME/.kube
    sed -i -e "s/localhost/host.docker.internal/g" $HOME/.kube/config
    sed -i -e "s/127.0.0.1/host.docker.internal/g" $HOME/.kube/config
fi
