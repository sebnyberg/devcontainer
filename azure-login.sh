#!/local/bin/env bash

set -o errexit
set -o pipefail

if type az &>/dev/null && ! az account show &>/dev/null ; then
    az login
fi