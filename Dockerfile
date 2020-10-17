FROM ubuntu:18.04

COPY ./build/ /tmp/scripts/

RUN /bin/bash /tmp/scripts/install.sh

COPY . .