#!/local/bin/env bash

set -o errexit
set -o pipefail

BINPATH="${BINPATH-"/usr/local/bin"}"

set -o nounset

# Kubectl
curl -sSL -o ${BINPATH}/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ${BINPATH}/kubectl

# Argo
cd $(mktemp -d) 
curl -sSLO https://github.com/argoproj/argo/releases/download/v2.11.4/argo-linux-amd64.gz
echo "3bc56f74f62e6019ad5f93036f8eecc0a79e971a86ae9d6cedc755df4c2438cf  argo-linux-amd64.gz" \
    | sha256sum -c --status
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
mv ./argo-linux-amd64 ${BINPATH}/argo
cd - >/dev/null

# Helm
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -

# SOPS
cd $(mktemp -d) 
curl -sSLO https://github.com/mozilla/sops/releases/download/v3.6.1/sops-v3.6.1.linux
echo "b2252aa00836c72534471e1099fa22fab2133329b62d7826b5ac49511fcc8997  sops-v3.6.1.linux" \
    | sha256sum -c --status 
chmod +x sops-v3.6.1.linux
mv sops-v3.6.1.linux ${BINPATH}/sops
cd - >/dev/null

# Kustomize
cd $(mktemp -d) 
curl -sSLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.8.5/kustomize_v3.8.5_linux_amd64.tar.gz
echo "7ff6218fdbf7ad5d90805ff9091f256ba6868e3116c2c05d3e50fe0a0595f50f  kustomize_v3.8.5_linux_amd64.tar.gz" \
    | sha256sum -c --status 
tar -xzf kustomize_v3.8.5_linux_amd64.tar.gz
chmod +x kustomize
mv ./kustomize ${BINPATH}/
cd - >/dev/null