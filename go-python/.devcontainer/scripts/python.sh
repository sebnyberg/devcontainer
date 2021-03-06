#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Sebastian Nyberg. All rights reserved.
# Licensed under the MIT License. See LICENSE.
#-------------------------------------------------------------------------------------------------------------
#
# Simplified and opinionated version of:
# https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/python-debian.sh
#

set -o errexit
set -o pipefail

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

export PIPX_HOME=${PIPX_HOME-"/usr/local/py-utils"}
export PIPX_BIN_DIR=${PIPX_HOME}/bin
export PATH=${PIPX_BIN_DIR}:${PATH}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

set -o nounset

# Check that Python is installed
if ! type python > /dev/null 2>&1 ; then
    die "Could not find Python installation, please use FROM python:\$version"
fi

# Update pip
echo "Updating pip..."
python3 -m pip install --no-cache-dir --upgrade pip

# Add environment variables to bashrc
echo "$(cat << EOM

# pipx settings
export PIPX_HOME=${PIPX_HOME}
export PIPX_BIN_DIR=${PIPX_BIN_DIR}
export PATH=\$PATH:\${PIPX_BIN_DIR}

EOM
)" >> /etc/bash.bashrc

DEFAULT_UTILS="\
    argcomplete \
    bandit \
    black \
    flake8 \
    mypy \
    pipenv \
    poetry \
    pycodestyle \
    pydocstyle \
    pylint \
    pytest \
    virtualenv \
    wheel \
    "

PYTHON_UTILS=${PYTHON_UTILS-$DEFAULT_UTILS}

# Install pipx and tools (as $USERNAME)
mkdir -p ${PIPX_BIN_DIR}
echo "Installing Python tools..."
export PYTHONUSERBASE=/tmp/pip-tmp
export PIP_CACHE_DIR=/tmp/pip-tmp/cache
pip3 install --disable-pip-version-check --no-warn-script-location  --no-cache-dir --user pipx
/tmp/pip-tmp/bin/pipx install --pip-args=--no-cache-dir pipx
echo "${PYTHON_UTILS}" | xargs -n 1 /tmp/pip-tmp/bin/pipx install --system-site-packages --pip-args '--no-cache-dir --force-reinstall'
/tmp/pip-tmp/bin/pipx install --system-site-packages --pip-args '--no-cache-dir --force-reinstall' jupyter --include-deps
rm -rf /tmp/pip-tmp

# Set up jupyter stub
mkdir -p /root/.jupyter
echo "$(cat << EOM
# localhost does not work inside a container - use 0.0.0.0 instead
c.NotebookApp.ip = '0.0.0.0'

# allow root when starting jupyter notebook
c.NotebookApp.allow_root = True

# don't open a new browser window automatically
c.NotebookApp.open_browser = False
EOM
)" > /root/.jupyter/jupyter_notebook_config.py

echo "$(cat << EOM

# Pipx paths
export PIPX_HOME=${PIPX_HOME}
export PIPX_BIN_DIR=${PIPX_BIN_DIR}
export PATH=\${PATH}:\${PIPX_BIN_DIR}
# Suppress annoying pip upgrade message
export PIP_DISABLE_PIP_VERSION_CHECK=1

# Python autocompletion
eval "\$(register-python-argcomplete pipx)"
eval "\$(register-python-argcomplete pytest)"

EOM
)" >> /etc/bash.bashrc

poetry completions bash > /etc/bash_completion.d/poetry.bash-completion
# Store virtualenv at ${workspaceDir}/.venv
# Allows for mounting .venv as a volume, reducing re-installs substantially
poetry config virtualenvs.in-project true