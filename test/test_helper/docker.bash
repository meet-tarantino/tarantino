#!/usr/bin/env bash

function is_dc_v2() {
	[[ $(docker-compose -v) == *' v2.'* ]]
}

function container_name() {
	local WORKSPACE_NAME=$1
	local SERVICE_NAME=$2
	if is_dc_v2; then
		echo "${WORKSPACE_NAME}-${SERVICE_NAME}-1"
	else
		echo "${WORKSPACE_NAME}_${SERVICE_NAME}_1"
	fi
}

function d_is_running() {
	local IMAGE=$1
	local WORKSPACE_NAME=$2
	local SERVICE_NAME=$3
	local CONTAINER_NAME=$(container_name "$2" "$3")
	local DOCKER_PS=$(docker ps --format "{{.Image}} {{.Names}}")
	if ! grep -qx "${IMAGE} ${CONTAINER_NAME}" <<< $DOCKER_PS; then
	  echo "Container not found in:"
	  docker ps
	  return 1
	fi
}

function d_is_destroyed() {
	local IMAGE=$1
	local WORKSPACE_NAME=$2
	local SERVICE_NAME=$3
	local CONTAINER_NAME=$(container_name "$2" "$3")
	local DOCKER_PS_ALL=$(docker ps -a --format "{{.Image}} {{.Names}}")
	if grep -qx "${IMAGE} ${CONTAINER_NAME}" <<< $DOCKER_PS_ALL; then
		echo "Container still found in:"
		docker ps -a
		return 1
	fi
}
