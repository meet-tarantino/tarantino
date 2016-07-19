#!/usr/bin/env bash

# settings
PROJECTS=${PROJECTS:-~/projects}
REGISTRY=${REGISTRY:-docker-registry.test.360incentives.io}
NAMESPACE=${NAMESPACE:-tarantino_}
PUBLISH_PORTS=${PUBLISH_PORTS:-true}
IS_GLOBAL=$([ "$0" = "/usr/local/bin/tt" ] && echo true || echo false)
ALL_SERVICES_FILE='/usr/local/share/tarantino/all_services.txt'
NOT_SERVICES_PATTERN='mongo|redis|rabbit|graphite|elasticsearch|kibana|grafana|dynamo'
SAMPLE_DATA='sample-data'