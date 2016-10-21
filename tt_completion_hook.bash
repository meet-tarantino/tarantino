#!/usr/bin/env bash

_tt_complete() {
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local args=${#COMP_WORDS[@]}
	local cmd=
	if [ $args -gt 2 ]; then
		cmd=${COMP_WORDS[1]}
	fi
#	local completions="$(/usr/local/share/tarantino/tt_completion --word "\"$cur\"" --cmd "\"$cmd\"" --args "$args")"
	local completions="$(/home/darrenmce/meet-tarantino/tarantino/tt_completion --word "\"$cur\"" --cmd "\"$cmd\"" --args "$args")"
	COMPREPLY=( $(compgen -W "$completions" -- "$cur") )
}

complete -F _tt_complete tt
