#!/usr/bin/env bash

function add_new_workspace() {
	WS_NAME=$1
	TMP_DIR=$(mktemp -d)
	cd ${TMP_DIR}
	touch docker-compose.yml
	tt workspace add "${WS_NAME}" "${TMP_DIR}"
	echo "${TMP_DIR}"
}

function add_dir_with_ws() {
	TEST_DIR="$1"
	TMP_DIR=$(mktemp -d)
	cp -r "$TEST_DIR"/* "$TMP_DIR"

	YAML="$TMP_DIR"/"$2"
	WS_DIR=$(dirname "$YAML")
	WS_NAME=$(basename $YAML .yml)
	mv "$YAML" "$WS_DIR"/docker-compose.yml
	tt workspace add "$WS_NAME" "$WS_DIR"
}

function add_ws_from_yaml() {
	YAML=$1
	WS_NAME=$(basename $YAML .yml)
	TMP_DIR=$(mktemp -d)
	cp -r "$(dirname $YAML)"/* "$TMP_DIR"
	ln -s "${YAML}" "${TMP_DIR}/docker-compose.yml"
	tt workspace add "${WS_NAME}" "${TMP_DIR}"
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
