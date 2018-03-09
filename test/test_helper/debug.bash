#!/usr/bin/env bash

DEBUG_LOG=${DEBUG_LOG:-./debug.log}

function debug() {
	if [ ! -z ${DEBUG} ]; then
	    echo "$@" >> ${DEBUG_LOG}
	fi
}

function debug_header() {
	debug "------ Running: $(basename ${BATS_TEST_FILENAME}) / ${BATS_TEST_DESCRIPTION} ------" $(date)
}