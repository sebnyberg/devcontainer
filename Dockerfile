FROM python:3.8.6-buster
# Use this if python is not needed
# FROM ubuntu:18.04

ENV USERNAME=vscode
ENV USER_UID=1000
ENV USER_GID=1000

RUN apt-get update

COPY ./build/sys.sh /tmp/build/sys.sh
RUN /bin/bash /tmp/build/sys.sh
COPY ./build/docker.sh /tmp/build/docker.sh
RUN /bin/bash /tmp/build/docker.sh
COPY ./build/azure.sh /tmp/build/azure.sh
RUN /bin/bash /tmp/build/azure.sh
COPY ./build/kubernetes.sh /tmp/build/kubernetes.sh
RUN /bin/bash /tmp/build/kubernetes.sh
COPY ./build/python.sh /tmp/build/python.sh
RUN /bin/bash /tmp/build/python.sh
COPY ./build/go.sh /tmp/build/go.sh
RUN /bin/bash /tmp/build/go.sh
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

COPY ./bin /usr/local/bin/
COPY ./share /usr/local/share/
COPY ./home /home/${USERNAME}/

USER $USERNAME

ENTRYPOINT ["/usr/local/share/entrypoint.sh"]
CMD ["sleep", "infinity"]