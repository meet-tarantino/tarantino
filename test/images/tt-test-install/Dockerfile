FROM ubuntu:16.04

RUN apt-get update && apt-get install -y git make sudo

RUN adduser --disabled-password --gecos '' testuser
RUN usermod -aG sudo testuser
RUN echo 'testuser ALL=(ALL) NOPASSWD: ALL' > '/etc/sudoers.d/testuser'

RUN git clone https://github.com/sstephenson/bats.git /tmp/bats \
  && cd /tmp/bats \
  && ./install.sh /usr/local

USER testuser
WORKDIR /home/testuser

