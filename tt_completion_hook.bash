#!/usr/bin/env bash

_tt_complete() {
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local completions=
	if [ ! -z $cur ]; then
		completions="$(/usr/local/share/tarantino/tt_completion "${COMP_WORDS[@]:1}")"
	else
		completions="$(/usr/local/share/tarantino/tt_completion -n "${COMP_WORDS[@]:1}")"
	fi
	COMPREPLY=( $(compgen -W "$completions" -- "$cur") )
}

complete -F _tt_complete tt
