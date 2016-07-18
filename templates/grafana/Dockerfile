FROM grafana/grafana
MAINTAINER meet-tarantino

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

ADD ./run /usr/local/bin/run

ENTRYPOINT run
