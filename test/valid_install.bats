#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

@test "Has curl installed" {
	hash curl
}

@test "Has docker installed" {
	hash docker
}

@test "Has docker-compose installed" {
	hash docker-compose
}

@test "Current user is in the docker group" {
	USER=$(whoami)
	GROUP_MEMBERS=$(cat /etc/group | awk -F':' '/docker/{print $4}')
	run grep -w "${USER}" <<< $GROUP_MEMBERS
	assert_equal "$output" "${USER}"
}

@test "tt is available" {
	hash tt
}

@test "tt version is available" {
	tt version
	assert_success
}
