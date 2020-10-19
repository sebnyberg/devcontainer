FROM python:3.8.6-buster

COPY ./scripts /tmp/scripts

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

ENV USERNAME=vscode
ENV USER_UID=1000
ENV USER_GID=1000
ENV PATH=${PATH}:/usr/local/py-utils/bin:/go/bin

# Add basic .bashrc with colourful prompt
RUN /bin/bash /tmp/scripts/create-user.sh \
  && curl -sSL -o /home/${USERNAME}/.bashrc \
  https://gist.githubusercontent.com/sebnyberg/3d3f55588f70c897a2c8c7306e5fd3ea/raw/4f2582751f0bee60d4a8789a6a04aaadbed238e7/.bashrc \
  # When using Python, use FROM python:$ver rather than ubuntu
  && /bin/bash /tmp/scripts/python.sh  \
  && chown -R $USERNAME /go

USER $USERNAME

COPY ./entrypoint.sh /usr/local/share/entrypoint.sh
ENTRYPOINT ["/usr/local/share/entrypoint.sh"]
CMD ["sleep", "infinity"]