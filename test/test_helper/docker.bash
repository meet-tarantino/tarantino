#!/usr/bin/env bash

function d_is_running() {
	local IMAGE=$1
	local CONTAINER_NAME=$2
	local DOCKER_PS=$(docker ps --format "{{.Image}} {{.Names}}")
	if ! grep -qx "${IMAGE} ${CONTAINER_NAME}" <<< $DOCKER_PS; then
	  echo "Container not found in:"
	  docker ps
	  return 1
	fi
}

function d_is_destroyed() {
	local IMAGE=$1
	local CONTAINER_NAME=$2
	local DOCKER_PS_ALL=$(docker ps -a --format "{{.Image}} {{.Names}}")
	if grep -qx "${IMAGE} ${CONTAINER_NAME}" <<< $DOCKER_PS_ALL; then
		echo "Container still found in:"
		docker ps -a
		return 1
	fi
}