#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Sebastian Nyberg. All rights reserved.
# Licensed under the MIT License. See LICENSE.
#-------------------------------------------------------------------------------------------------------------
#
# Based on https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/go-debian.sh
# 

GO_VERSION=${GO_VERSION:-"1.15.3"}
TARGET_GOROOT=${GOROOT:-"/usr/local/go"}
TARGET_GOPATH=${GOPATH:-"/go"}

set -o errexit

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install curl, tar, git, other dependencies if missing
if ! dpkg -s curl ca-certificates tar git g++ gcc libc6-dev make pkg-config > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates tar git g++ gcc libc6-dev make pkg-config
fi

# Install Go
cd $(mktemp -d)
curl -sSL -o go.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf go.tar.gz
cd - &>/dev/null

# Install Go tools
GO_TOOLS_WITH_MODULES="\
    golang.org/x/tools/gopls \
    honnef.co/go/tools/... \
    golang.org/x/tools/cmd/gorename \
    golang.org/x/tools/cmd/goimports \
    golang.org/x/tools/cmd/guru \
    golang.org/x/lint/golint \
    github.com/mdempsky/gocode \
    github.com/cweill/gotests/... \
    github.com/haya14busa/goplay/cmd/goplay \
    github.com/sqs/goreturns \
    github.com/josharian/impl \
    github.com/davidrjenni/reftools/cmd/fillstruct \
    github.com/uudashr/gopkgs/v2/cmd/gopkgs \
    github.com/ramya-rao-a/go-outline \
    github.com/acroca/go-symbols \
    github.com/godoctor/godoctor \
    github.com/rogpeppe/godef \
    github.com/zmb3/gogetdoc \
    github.com/fatih/gomodifytags \
    github.com/mgechev/revive \
    github.com/go-delve/delve/cmd/dlv"

echo "Installing common Go tools..."
export PATH=${TARGET_GOROOT}/bin:${PATH}
mkdir -p /tmp/gotools
cd /tmp/gotools
export GOPATH=/tmp/gotools
export GOCACHE=/tmp/gotools/cache

# Go tools w/module support
export GO111MODULE=on
(echo "${GO_TOOLS_WITH_MODULES}" | xargs -n 1 go get -v )2>&1

# gocode-gomod
export GO111MODULE=auto
go get -v -d github.com/stamblerre/gocode 2>&1
go build -o gocode-gomod github.com/stamblerre/gocode

# golangci-lint
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b ${TARGET_GOPATH}/bin 2>&1

# Move Go tools into path and clean up
mv /tmp/gotools/bin/* ${TARGET_GOPATH}/bin/
mv gocode-gomod ${TARGET_GOPATH}/bin/
rm -rf /tmp/gotools
chown -R ${USERNAME} "${TARGET_GOPATH}"

# Set paths for binaries
echo "$(cat << EOM
# Go
export GOPATH="${TARGET_GOPATH}"
export GOROOT="${TARGET_GOROOT}"
export PATH="\${GOROOT}/bin:\${GOPATH}/bin:\${PATH}"
EOM
)" >> /etc/bash.bashrc
echo "Done!"