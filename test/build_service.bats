#!/usr/bin/env bats

load 'test_helper/debug'
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/workspace'

BUILD_SERVICE_DIR="${PWD}/test/test_yamls/build"

function setup() {
	add_ws_dir ${BUILD_SERVICE_DIR} tarantino/build_service.yml
}

function teardown() {
	tt destroy
	rm_all_workspaces
}

@test "build service - it should build image and run container" {
	debug_header
	run tt workspace use build_service
	run tt dc run hello
	assert_output --regexp "Hello World!"
}
