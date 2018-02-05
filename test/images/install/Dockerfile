FROM ubuntu:16.04

RUN apt-get update && apt-get install -y git make sudo

RUN adduser --disabled-password --gecos '' testuser
RUN usermod -aG sudo testuser
RUN echo 'testuser ALL=(ALL) NOPASSWD: ALL' > '/etc/sudoers.d/testuser'

USER testuser
WORKDIR /home/testuser

