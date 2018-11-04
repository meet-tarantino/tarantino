#!/usr/bin/env bats

load 'test_helper/debug'
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/workspace'

BUILD_SERVICE_YML="${PWD}/test/test_yamls/build/build_service.yml"

function setup() {
	add_ws_from_yaml ${BUILD_SERVICE_YML}
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
