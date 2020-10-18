#!/local/bin/env bash

set -o errexit
set -o pipefail

# Complain to STDERR and exit with an error.
die() { echo "$*" >&2; exit 2; }  

BINPATH=${BINPATH-"/usr/local/bin"}
ARGO_VERSION=${ARGO_VERSION-"v2.11.4"}
SOPS_VERSION=${SOPS_VERSION-"v3.6.1"}
KUSTOMIZE_VERSION=${KUSTOMIZE_VERSION-"v3.8.5"}

set -o nounset

# Kubectl
curl -sSL -o ${BINPATH}/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ${BINPATH}/kubectl

echo "source <(kubectl completion bash)" >> /etc/bahs.bashrc
curl https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases > /etc/profile.d/02-kubectl_aliases

# Argo
cd $(mktemp -d) 
curl -sSLO https://github.com/argoproj/argo/releases/download/${ARGO_VERSION}/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
mv ./argo-linux-amd64 ${BINPATH}/argo
cd - >/dev/null

# Helm
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -

# SOPS
cd $(mktemp -d) 
curl -sSL -o ${BINPATH}/sops https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux
chmod +x ${BINPATH}/sops
cd - >/dev/null

# Kustomize
cd $(mktemp -d) 
curl -sSL -o kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz
tar -xzf kustomize.tar.gz
chmod +x kustomize
mv ./kustomize ${BINPATH}/kustomize
cd - >/dev/null