FROM python:3.8.6-buster

COPY ./.devcontainer/scripts /tmp/scripts

RUN apt-get update \
  # Install base system-level packages (apt)
  && /bin/bash /tmp/scripts/sys.sh \
  # Install Docker, Docker Compose, and prep for mounting the host socket 
  && /bin/bash /tmp/scripts/docker.sh \
  # Install Azure CLI, should pair with a mount of ~/.azure to avoid double login
  && /bin/bash /tmp/scripts/azure.sh \
  # Install Kubernetes tools
  && /bin/bash /tmp/scripts/kubernetes.sh \
  # Install Go and various dev tools
  && /bin/bash /tmp/scripts/go.sh \
  # Cleanup
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* 