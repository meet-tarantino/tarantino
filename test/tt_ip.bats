#!/usr/bin/env bats

load 'test_helper/debug'
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/workspace'

DEFAULT_NETWORK_YML="${PWD}/test/test_yamls/networks/default.yml"
HOST_NETWORK_YML="${PWD}/test/test_yamls/networks/host.yml"
NAMED_NETWORK_YML="${PWD}/test/test_yamls/networks/named.yml"
MULTIPLE_NETWORK_YML="${PWD}/test/test_yamls/networks/multiple.yml"

# will match 999.999.999.999 but meh
IP_ADDRESS_REGEXP='[0-9]{1,3}\.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'

function setup() {
	add_ws_from_yaml ${DEFAULT_NETWORK_YML}
	add_ws_from_yaml ${HOST_NETWORK_YML}
	add_ws_from_yaml ${NAMED_NETWORK_YML}
	add_ws_from_yaml ${MULTIPLE_NETWORK_YML}
}

function teardown() {
	tt destroy
	rm_all_workspaces
}

@test "default network - it should retrieve the IP from the running container" {
	debug_header
	run tt workspace use default
	run tt create
	run tt ip hello
	assert_output --regexp "^${IP_ADDRESS_REGEXP}$"
}

@test "named network - it should retrieve the IP from the running container" {
	debug_header
	run tt workspace use named
	run tt create
	run tt ip hello
	assert_output --regexp "^${IP_ADDRESS_REGEXP}$"
}

@test "host network - it should retrieve 0.0.0.0" {
	debug_header
	run tt workspace use host
	run tt create
	run tt ip hello
	assert_output "0.0.0.0"
}

@test "multiple networks - it should retrieve a list of network IPs from a running container" {
	debug_header
	run tt workspace use multiple
	run tt create
	run tt ip hello
	assert_line --regexp "^multiple_testnetwork:${IP_ADDRESS_REGEXP}$"
	assert_line --regexp "^multiple_secondnetwork:${IP_ADDRESS_REGEXP}$"
}

@test "multiple networks - quiet mode" {
	debug_header
	run tt workspace use multiple
	run tt create
	run tt ip hello -q
	assert_output --regexp "^${IP_ADDRESS_REGEXP}$"
}

@test "multiple networks - specific network" {
	debug_header
	run tt workspace use multiple
	run tt create
	run tt ip hello secondnetwork
	assert_output --regexp "^${IP_ADDRESS_REGEXP}$"
}

@test "multiple networks - should error when specific network not found" {
	debug_header
	run tt workspace use multiple
	run tt create
	run tt ip hello unknownnetwork
	assert_failure
}
