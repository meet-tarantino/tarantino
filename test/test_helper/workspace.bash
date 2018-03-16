#!/usr/bin/env bash

function add_new_workspace() {
	WS_NAME=$1
	TMP_DIR=$(mktemp -d)
	cd ${TMP_DIR}
	touch docker-compose.yml
	tt workspace add $1 "${TMP_DIR}"
	echo "${TMP_DIR}"
}

function rm_workspace() {
	WS=$1
	WS_DIR=$2
	rm ~/.tt/workspaces/${WS}
	rm -rf ${WS_DIR}
}

function rm_all_workspaces() {
	rm -f ~/.tt/workspaces/*
	rm -f ~/.tt/current
	return 0
}