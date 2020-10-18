#!/local/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -o errexit
set -o pipefail

docker-init() {
    SOCAT_PATH_BASE=/tmp/vscr-dind-socat
    SOCAT_LOG=${SOCAT_PATH_BASE}.log
    SOCAT_PID=${SOCAT_PATH_BASE}.pid
    HOST_DOCKER_SOCKET=${HOST_DOCKER_SOCKET-"/var/run/docker-host.sock"}
    INTERNAL_DOCKER_SOCKET=${INTERNAL_DOCKER_SOCKET-"/var/run/docker.sock"}

    sudo socat \
        UNIX-LISTEN:${INTERNAL_DOCKER_SOCKET},fork,mode=660,user=${USERNAME} \
        UNIX-CONNECT:${HOST_DOCKER_SOCKET} 2>&1 \
        | tee -a ${SOCAT_LOG} > /dev/null & echo "$!"\
        | tee ${SOCAT_PID} > /dev/null
}

docker-init