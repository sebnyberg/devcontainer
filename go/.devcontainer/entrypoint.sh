#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# docker-init binds the host's mounted Docker Socket to the internal Docker socket
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
if [ -e "/var/run/docker-host.sock" ] && [ $(command -v docker) ] ; then
    docker-init
fi

# kube-init copies mounted host configs to the home directory
kube-init() {
    mkdir -p $HOME/.kube
    sudo cp -r /usr/local/share/kube-localhost/* $HOME/.kube
    sudo chown -R $(id -u) $HOME/.kube
    sed -i -e "s/localhost/host.docker.internal/g" $HOME/.kube/config
    sed -i -e "s/127.0.0.1/host.docker.internal/g" $HOME/.kube/config
}
if [ -d "/usr/local/share/kube-localhost" ]; then
    kube-init
fi

/tini -s -- "$@"