FROM ubuntu:18.04

ENV USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY ./build /tmp/build
COPY ./bin/ /usr/local/bin/
COPY ./share /usr/local/share/
COPY ./home ./

RUN /bin/bash /tmp/build/sys-init.sh
RUN /bin/bash /tmp/build/user-init.sh

USER $USERNAME

ENTRYPOINT ["/usr/local/share/entrypoint.sh"]
CMD ["sleep", "infinity"]