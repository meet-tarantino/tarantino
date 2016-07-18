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
	echo '  add <alias> <workspace_dir> - register an existing workspace with your user account'
	echo '  rm <workspace> - unregister a workspace from your user account'
	echo '  ls - list registered workspaces '
	echo '  use <workspace> - switch to a different workspace'
	echo '  upgrade [workspace] - fetch latest workspace definition, update docker images'
}

ws_add() {
	if [ $# -ne 2 ]; then
		echo 'USAGE: tt workspace add <alias> <workspace_dir>'
		return 1
	fi

	local alias=$1
	local workspace_dir=$2
	if ! is_workspace_dir $workspace_dir; then
		echo "$workspace_dir is not a valid workspace directory, please run 'tt workspace init' within the folder"
		return 1
	fi
	local workspace_root=$TT_HOME/workspaces
	local symlink=$workspace_root/$alias
	if  [ -e $symlink ]; then
		echo "$alias is already registered as a workspace, please run 'tt workspace rm $alias' to remove it first"
		return 1
	fi
	mkdir -p $workspace_root
	ln -sr $workspace_dir $symlink
}

ws_rm() {
	local alias=$1
	if ! is_workspace $alias; then
		echo "$alias is not a registered workspace"
		return 1
	fi
	rm $TT_HOME/workspaces/$alias
}

ws_ls() {
	if [ -d $TT_HOME/workspaces ]; then
		ls $TT_HOME/workspaces
	fi
}

ws_use() {
	local alias=$1
	if ! is_workspace $alias; then
		echo "$alias is not a registered workspace"
		return 1
	fi
	ln -snf $TT_HOME/workspaces/$alias $TT_HOME/current
}

ws_init() {
	if is_workspace_dir $(pwd); then
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
	test -e $TT_HOME/workspaces/$1
}

is_workspace_dir() {
	if [ ! -f $1/docker-compose.yml ]; then
		return 1
	fi
}

get_workspace_dir() {
	readlink "$TT_HOME/current"
}

get_workspace() {
	basename "$(get_workspace_dir)"
}