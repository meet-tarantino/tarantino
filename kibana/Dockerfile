# This is a 360 version of https://github.com/balsamiq/docker-kibana
FROM docker-registry.test.360incentives.io/service-base
MAINTAINER 360incentives

RUN apt-get update && \
	apt-get -y install wget nginx-full apache2-utils && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN wget --no-check-certificate -O- https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz | tar xvfz -
RUN mv /opt/kibana-3.1.2 /opt/kibana
RUN mkdir /etc/kibana # This is where the htpasswd file is placed by the run script

ADD run /opt/run
ADD config/etc /etc

RUN rm /etc/nginx/sites-enabled/*
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Add our Kibana configuration and our dashboards
ADD config/kibana /opt/kibana

ENV KIBANA_SECURE true
ENV KIBANA_USER kibana
ENV KIBANA_PASSWORD kibana

EXPOSE 80

CMD /opt/run
