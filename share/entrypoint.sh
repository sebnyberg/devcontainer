#!/usr/bin/env bash

set -o xtrace
set -o nounset
set -o errexit
set -o pipefail

bash /usr/local/share/docker-init.sh
bash /usr/local/share/kube-init.sh

/tini -- "$@"