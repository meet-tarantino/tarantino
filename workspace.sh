#!/usr/bin/env bash

tt_workspace() {
	main ws $*
}

ws_usage() {
	tt_header
	echo 'usage: tt workspace <command> [args]'
	echo
	echo commands:
	echo
	echo '  init - initialize a new workspace in the current directory'
	echo '  add <workspace_dir> - register an existing workspace with your user account'
	echo '  rm <workspace> - unregister a workspace from your user account'
	echo '  ls - list registered workspaces '
	echo '  use <workspace> - switch to a different workspace'
	echo '  upgrade [workspace] - fetch latest workspace definition, update docker images'
}

ws_init() {
	if is_workspace $(pwd); then
		local warning='Directory is already a workspace, are you sure you wish to reinitialize? (y/N)? '
		read -n 1 -p "$warning" CONFIRM
		if [ "$CONFIRM" = 'y' ]; then
			echo
			init
		fi
	else
		init
	fi
}

init() {
	git init

	cp $TT_SHARE/templates/docker-compose.yml .
	echo sample docker-compose.yml file created

	cp -R $TT_SHARE/templates/grafana .
}

is_workspace() {
	if [ ! -f $1/docker-compose.yml ]; then
		return 1
	fi
}
