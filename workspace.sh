#!/usr/bin/env bash

tt_workspace() {
	run_sub_command ws $@
}

ws_usage() {
	tt_header
	echo 'usage: tt workspace <command> [args]'
	echo
	echo commands:
	echo
	echo '  init - initialize a new workspace in the current directory'
	echo '  add <alias> <workspace_dir> - register an existing workspace with your user account'
	echo '  edit - opens the current workspace docker-compose.yml for editing'
	echo '  rm <workspace> - unregister a workspace from your user account'
	echo '  ls - list registered workspaces '
	echo '  use <workspace> - switch to a different workspace'
	echo '  current - display the current workspace and directory'
	echo '  upgrade [workspace] - NOT YET IMPLEMENTED: fetch latest workspace definition, update docker images'
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

	if [[ "$alias" =~ ^[0-9] ]]; then
		echo "ERROR: workspaces with leading digits are not supported due to Docker limitations."
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

	# destroy containers in the workspace to be removed and remove workspace
	local previous=$(get_workspace)
	ws_use $alias
	tt_destroy
	rm $TT_HOME/workspaces/$alias

	# if the workspace was previously in context
	if [ "$previous" == "$alias" ]; then
		# clear current
		rm $TT_HOME/current
	else
		# otherwise, revert to whatever our previous workspace was
		ws_use "$previous"
	fi
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


ws_edit() {
	if [ ! -z $1 ]; then
		echo "unknown parameter: $1"
		ws_usage
		return 1
	fi
	"${EDITOR:-vi}" $(dc_file)
}

ws_current() {
	echo $(get_workspace) '->' $(readlink -f "$(get_workspace_dir)")
}

ws_init() {
	if is_workspace_dir $(pwd); then
		echo 'Directory already contains a workspace!'
		echo 'to reinitialize: '
		echo ' - remove this first using `tt workspace rm <workspace>`'
		echo ' - delete the contents of the folder'
		echo ' - run `tt init` again'
		return 1
	fi

	init $@
}

ws_upgrade() {
	echo "'upgrade' command not yet implemented :("
	return 1;
}

init() {
	alias=$(basename `pwd`)
	if [ ! -z $1 ]; then
		alias=$1
	fi

	if $(is_workspace $alias); then
		echo "Error: a workspace with the name '$alias' already exists"
		return 1
	fi

	git init
	cp $TT_SHARE/templates/.gitignore .

	cp $TT_SHARE/templates/docker-compose.yml .
	echo sample docker-compose.yml file created

	cp -r $TT_SHARE/templates/plugins .
	echo sample plugin created

	ws_add $alias `pwd`
	ws_use $alias
	echo "Setting current workspace to: ${alias}"
	ws_current
}

is_workspace() {
	test $# -eq 1 -a -e "$TT_HOME/workspaces/$1/"
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
	basename "$(get_workspace_dir)" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]'
}
