FROM ubuntu:16.04

RUN apt-get update && apt-get install -y git make sudo

RUN adduser --disabled-password --gecos '' testuser
RUN usermod -aG sudo testuser
RUN echo 'testuser ALL=(ALL) NOPASSWD: ALL' > '/etc/sudoers.d/testuser'

## install tarantino dependencies
RUN apt-get install -y apt-transport-https curl ca-certificates software-properties-common \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce \
  && usermod -aG docker testuser \
  && curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

RUN chmod +x /usr/local/bin/docker-compose

RUN git clone https://github.com/sstephenson/bats.git /tmp/bats \
  && cd /tmp/bats \
  && ./install.sh /usr/local

USER testuser
WORKDIR /home/testuser
