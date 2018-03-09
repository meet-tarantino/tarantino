#!/usr/bin/env bats

load 'test_helper/debug'
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/workspace'

TEST_WORKSPACE_DIR="/tmp/tttestws"
TEST_WORKSPACE="tttestws"


function setup() {
	mkdir -p ${TEST_WORKSPACE_DIR}
	cd ${TEST_WORKSPACE_DIR}
	tt workspace init 1>/dev/null
}

function teardown() {
	rm_workspace "${TEST_WORKSPACE}" "${TEST_WORKSPACE_DIR}"
}

@test "init: should initialize a workspace folder" {
	debug_header
	assert [ -e ${TEST_WORKSPACE_DIR}/docker-compose.yml ]
	assert [ -e ${TEST_WORKSPACE_DIR}/plugins/vars.sh ]
	assert [ -e ${TEST_WORKSPACE_DIR}/plugins/feature.sh ]
}

@test "current: should display the workspace and directory" {
	debug_header
	run tt workspace current
	assert_output "${TEST_WORKSPACE} -> ${TEST_WORKSPACE_DIR}"
}

@test "add: should be able to add a folder as a workspace" {
	debug_header

	run add_new_workspace mytestworkspace
	WS_DIR=$output
	assert_output --partial '/tmp/tmp.'

	run tt workspace ls
	assert_line 'mytestworkspace'

	rm_workspace mytestworkspace "${WS_DIR}"
}

@test "add: should NOT be selected as part of the add" {
	debug_header

	WS_DIR=$(add_new_workspace mytestworkspace)

	run tt workspace current
	refute_output --partial "mytestworkspace"

	rm_workspace mytestworkspace "${WS_DIR}"
}

@test "use: should be able to switch current workspace" {
	debug_header

	WS_DIR=$(add_new_workspace mytestworkspace)

	run tt workspace use mytestworkspace
	assert_success

	run tt workspace current
	assert_output --partial "mytestworkspace"

	rm_workspace mytestworkspace "${WS_DIR}"
}