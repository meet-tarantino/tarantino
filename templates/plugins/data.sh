#!/usr/bin/env bash

tt_data() {
	local script=$1
	shift

	if [ -z "$script" ]; then
		ttd_usage
		return 1;
	fi

	run_sample_data $script $@
}

ttd_usage() {
	local sample_scripts=$(tt_sample_data_scripts)

	if ! hash jq; then
		echo 'Warning: you do not appear to have `jq` installed, `tt data` usage commands will not be complete'
		echo 'run `sudo apt-get install -y jq` to resolve this'
	fi

	if [ ! -d "$TT_PROJECTS/$SAMPLE_DATA" ]; then
		echo 'Warning: you do not have the sample-data repository, `tt data` usage will not list sample scripts'
		echo 'run `tt clone sample-data` to resolve this'
	fi

	tt_header
	echo 'usage: tt data <command> [args]'
	echo
	echo commands:
	echo
	echo '  <command> - runs the sample-data project npm script of the same name'
	if [ ! -z "$sample_scripts" ]; then
		echo '    available commands:'
		for script in $sample_scripts; do
			echo "      $script"
		done
	fi
}

tt_sample_data_scripts() {
	local sample_data_dir="$TT_PROJECTS/$SAMPLE_DATA"
	if [ -d "$sample_data_dir" ]; then
		cat "$sample_data_dir"/package.json | jq -r '.scripts | keys[]' | grep -vx test
	fi
}

run_sample_data() {
	local sample_data_project="$TT_PROJECTS/$SAMPLE_DATA"

	local script=$1
	shift

	if [ ! -d $sample_data_project ]; then
		echo "requires the $SAMPLE_DATA repository, cloning..."
		tt_clone $SAMPLE_DATA
	fi

	echo "running sample data script: $script"

	if [ $# -gt 0 ]; then
		script="$script -- $@" # add any extra args
	fi

	pushd $sample_data_project;

	npm run $script
	result=$?

	popd &> /dev/null
	return $result
}

