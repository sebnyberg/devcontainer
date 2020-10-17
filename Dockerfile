FROM ubuntu:18.04

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY ./build /tmp/build
COPY ./bin/ /usr/local/bin/
COPY ./home ./

RUN /bin/bash /tmp/build/sys-init.sh
RUN /bin/bash /tmp/build/user-init.sh

USER $USERNAME