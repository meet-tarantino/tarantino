#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/docker'

@test "It should display usage" {
	run tt usage
	assert_success
}

@test "It should create mongo" {
	run tt create mongo
	assert_success
	d_is_running mongo testworkspace_mongo_1
}

@test "It should recreate mongo" {
	run tt recreate mongo
	assert_success
	d_is_running mongo testworkspace_mongo_1
}

@test "It should destroy mongo" {
	run tt destroy mongo
	assert_success
	d_is_destroyed mongo testworkspace_mongo_1
}