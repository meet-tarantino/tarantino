#!/usr/bin/env bash

tt_init() {
	if [ -f docker-compose.yml ]; then
		local warning='Directory already has files, are you sure (y/N)? '
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
