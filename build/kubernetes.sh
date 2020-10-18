#!/local/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Sebastian Nyberg. All rights reserved.
# Licensed under the MIT License. See LICENSE.
#-------------------------------------------------------------------------------------------------------------

set -o errexit
set -o pipefail

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

BINPATH=${BINPATH-"/usr/local/bin"}
ARGO_VERSION=${ARGO_VERSION-"v2.11.4"}
SOPS_VERSION=${SOPS_VERSION-"v3.6.1"}
KUSTOMIZE_VERSION=${KUSTOMIZE_VERSION-"v3.8.5"}
ISTIO_VERSION=${ISTIO_VERSION-"1.6.8"}
FLUXCTL_VERSION=${FLUXCTL_VERSION-"1.20.2"}
KUBESEAL_VERSION=${KUBESEAL_VERSION-"v0.12.6"}

set -o nounset

# Kubectl
if type kubectl > /dev/null 2>&1; then
    echo "Kubectl already installed."
else
    curl -sSL -o ${BINPATH}/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x ${BINPATH}/kubectl

    echo "source <(kubectl completion bash)" >> /etc/bash.bashrc
    curl https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases > /usr/local/share/kubectl-aliases.sh
    echo "$(cat << EOM
source /usr/local/share/kubectl-aliases.sh
alias kns='kubectl config set-context --current --namespace '
alias kc='kubectl config use-context '
EOM
)" >> /etc/bash.bashrc
fi


# Argo
if type argo > /dev/null 2>&1; then
    echo "Argo already installed."
else
    cd $(mktemp -d) 
    curl -sSLO https://github.com/argoproj/argo/releases/download/${ARGO_VERSION}/argo-linux-amd64.gz
    gunzip argo-linux-amd64.gz
    chmod +x argo-linux-amd64
    mv ./argo-linux-amd64 ${BINPATH}/argo
    cd - >/dev/null
    echo "source <(argo completion bash)" >> /etc/bash.bashrc
fi

# Helm
if type helm > /dev/null 2>&1; then
    echo "Helm already installed."
else
    curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -
    echo "source <(helm completion bash)" >> /etc/bash.bashrc
fi

# SOPS
if type sops > /dev/null 2>&1; then
    echo "Helm already installed."
else
    cd $(mktemp -d) 
    curl -sSL -o ${BINPATH}/sops https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux
    chmod +x ${BINPATH}/sops
    cd - >/dev/null
fi

# Kustomize
if type kustomize > /dev/null 2>&1; then
    echo "Kustomize already installed."
else
    cd $(mktemp -d) 
    curl -sSL -o kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz
    tar -xzf kustomize.tar.gz
    chmod +x kustomize
    mv ./kustomize ${BINPATH}/kustomize
    cd - >/dev/null
    echo "y" | kustomize install-completion
    echo "complete -C $(which kustomize) kustomize" >> /etc/bash.bashrc
fi

# Istio
if type istioctl > /dev/null 2>&1; then
    echo "Istioctl already installed."
else
    curdir=$(pwd)
    cd $(mktemp -d)

    # ISTIO_VERSION dictates the version in this command as per 
    # https://istio.io/latest/docs/setup/getting-started/#download
    export ISTIO_VERSION=$ISTIO_VERSION
    curl -L https://istio.io/downloadIstio | sh -
    cd istio-${ISTIO_VERSION}

    chmod +x ./bin/istioctl
    mv ./bin/istioctl ${BINPATH}/istioctl
    mv ./tools/istioctl.bash /usr/local/share/istioctl.bash
    echo "source /usr/local/share/istioctl.bash" >> /etc/bash.bashrc

    cd $curdir
fi

# Fluxctl
if type fluxctl > /dev/null 2>&1; then
    echo "Fluxctl already installed."
else
    curl -sSL -o ${BINPATH}/fluxctl \
        https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_amd64
    chmod +x ${BINPATH}/fluxctl
    echo "$(cat << EOM
source <(fluxctl completion bash)
export FLUX_FORWARD_NAMESPACE=flux
alias fc="fluxctl"
EOM
)" >> /etc/bash.bashrc
fi

# Kubeseal
if type kubeseal > /dev/null 2>&1; then
    echo "Kubeseal (sealed-secrets) already installed."
else
    curl -sSL -o ${BINPATH}/kubeseal \
        https://github.com/bitnami-labs/sealed-secrets/releases/download/${KUBESEAL_VERSION}/kubeseal-linux-amd64
    chmod +x ${BINPATH}/kubeseal
    echo "$(cat << EOM
export SEALED_SECRETS_CONTROLLER_NAMESPACE=adm
alias seal="kubeseal"
EOM
)" >> /etc/bash.bashrc
fi