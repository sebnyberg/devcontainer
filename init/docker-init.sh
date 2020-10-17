#!/local/bin/env bash

set -o errexit
set -o pipefail

SOCAT_PATH_BASE=/tmp/vscr-dind-socat
SOCAT_LOG=${SOCAT_PATH_BASE}.log
SOCAT_PID=${SOCAT_PATH_BASE}.pid
HOST_DOCKER_SOCKET=/var/run/docker-host.sock
INTERNAL_DOCKER_SOCKET=/var/run/docker.sock

sudo socat \
    UNIX-LISTEN:${INTERNAL_DOCKER_SOCKET},fork,mode=660,user=${USERNAME} \
    UNIX-CONNECT:${HOST_DOCKER_SOCKET} 2>&1 \
    | tee -a ${SOCAT_LOG} > /dev/null & echo "$!"\
    | tee ${SOCAT_PID} > /dev/null
