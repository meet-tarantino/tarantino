FROM darrenmce/tt-test-install

USER root

## install tarantino dependencies
RUN apt-get install -y apt-transport-https curl ca-certificates software-properties-common \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce \
  && usermod -aG docker testuser \
  && curl -L https://github.com/docker/compose/releases/download/v2.14.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

RUN chmod +x /usr/local/bin/docker-compose

USER testuser
