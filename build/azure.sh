#!/local/bin/env bash

set -o errexit
set -o pipefail

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

BINPATH="${BINPATH-"/usr/local/bin"}"

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
