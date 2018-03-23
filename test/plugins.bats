#!/usr/bin/env bats

load 'test_helper/debug'
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/workspace'

TEST_WORKSPACE_DIR="/tmp/testws"
TEST_WORKSPACE="testws"

function setup() {
	mkdir -p ${TEST_WORKSPACE_DIR}
	cd ${TEST_WORKSPACE_DIR}
	tt workspace init 1>/dev/null
}

function teardown() {
	rm -rf ${TEST_WORKSPACE_DIR}
	rm_all_workspaces
}

@test "plugin should be loaded" {
	debug_header

	echo 'tt_testplugin() { echo "test plugin"; }' > "${TEST_WORKSPACE_DIR}/plugins/test.sh"

	run tt testplugin
	assert_output "test plugin"
}

@test "plugin variables that start with TT_ will be slurped in" {
	echo 'TT_TEST_VAR=foo' > "${TEST_WORKSPACE_DIR}/plugins/vars.sh"
	echo 'tt_testplugin() { echo "test: ${TT_TEST_VAR}"; }' > "${TEST_WORKSPACE_DIR}/plugins/test.sh"

	run tt testplugin
	assert_output "test: foo"
}

@test "plugin variables _exported_ should be available to tt commands (without TT_ prefix)" {
	echo 'export TEST_VAR=foo' > "${TEST_WORKSPACE_DIR}/plugins/vars.sh"
	echo 'tt_testplugin() { echo "test: ${TEST_VAR}"; }' > "${TEST_WORKSPACE_DIR}/plugins/test.sh"

	run tt testplugin
	assert_output "test: foo"
}


@test "plugin variables should work with docker-compose" {
	echo 'TT_TEST_VAR=foo' > "${TEST_WORKSPACE_DIR}/plugins/vars.sh"
	(cat << EOF
version: '2'
services:
  test:
    image: darrenmce/tt-test-base
    labels:
      com.tarantino.source: \${TT_TEST_VAR}
EOF
) > "${TEST_WORKSPACE_DIR}/docker-compose.yml"

	run tt get_sources
	assert_output '[test]="foo"'
}

@test "plugin usage functions should append to the usage instructions" {
	echo 'test_plugin_usage() { echo "this is how you use the command"; }' > "${TEST_WORKSPACE_DIR}/plugins/usage.sh"
	run tt usage
	assert_line --partial "Workspace plugin commands:"
	assert_line --partial "this is how you use the command"
}

@test "plugin usage should not exist if there is no usage commands" {
	run tt usage
	refute_line --partial "Workspace plugin commands:"
}

@test "plugin usage functions should append to the usage instructions (multiple)" {
	echo 'test_plugin_usage() { echo "this is how you use the command"; }' > "${TEST_WORKSPACE_DIR}/plugins/usage.sh"
	echo 'test2_plugin_usage() { echo "this command is cool"; }' > "${TEST_WORKSPACE_DIR}/plugins/usage2.sh"
	echo 'not_valid_usage() { echo "this should not show up"; }' > "${TEST_WORKSPACE_DIR}/plugins/usage3.sh"
	run tt usage
	assert_line --partial "Workspace plugin commands:"
	assert_line --partial "this is how you use the command"
	assert_line --partial "this command is cool"
	refute_line --partial "this should not show up"
}