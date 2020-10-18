FROM ubuntu:18.04

ENV USERNAME=vscode
ENV USER_UID=1000
ENV USER_GID=1000

COPY ./build /tmp/build

RUN apt-get update
RUN /bin/bash /tmp/build/sys.sh
RUN /bin/bash /tmp/build/docker.sh
RUN /bin/bash /tmp/build/azure.sh
RUN /bin/bash /tmp/build/kubernetes.sh
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

COPY ./bin /usr/local/bin/
COPY ./share /usr/local/share/
COPY ./home /home/${USERNAME}/

USER $USERNAME

ENTRYPOINT ["/usr/local/share/entrypoint.sh"]
CMD ["sleep", "infinity"]