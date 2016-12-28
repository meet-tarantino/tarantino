#!/usr/bin/env bash

tt_dc() {
	dc $@
}

dc_file() {
	echo $(get_workspace_dir)/docker-compose.yml
}

dc() {
	TT_PROJECTS=$TT_PROJECTS docker-compose -f $(dc_file) $*
}

dc_get_links() {
	local key=services_"$1"_links
	local links=$key[@]
	eval $(parse_yaml $(dc_file) | grep $key)
	for link in ${!links}; do
		echo $link
	done
}

dc_get_all_services() {
	if [ "$TT_IS_GLOBAL" = true ]; then
		generate_service_lists
		cat "$(get_workspace_cache_dir)/services"
	else
		dc config --services
	fi
}

dc_get_services() {
	dc_get_all_services | grep -Ev $NOT_SERVICES_PATTERN
}

dc_get_repos() {
	if [[ $# -gt 0 ]]; then
		services=
		repos=$@
		while [ "$services" != "$repos" ]; do
			services=$repos
			repos=
			for service in $services; do
				self=$(echo $service | grep -Ev $NOT_SERVICES_PATTERN)
				if [ ! -z "$self" ]; then
					repos="$repos $self"
				fi
				links=$(dc_get_links $service | grep -Ev $NOT_SERVICES_PATTERN)
				if [ ! -z "$links" ]; then
					repos="$repos $links"
				fi
			done
			repos=$(echo $repos | awk -v RS="[\n ]" '!a[$0]++')
		done
		if [ ! -z "$repos" ]; then
			echo "$repos"
		fi
	else
		echo "$(tt_get_services)"
	fi
}

get_workspace_cache_dir() {
	local cachedir=$(get_workspace_dir)/.cache
	mkdir -p $cachedir
	echo $cachedir
}

generate_service_lists() {
	local md5check=$(get_workspace_cache_dir)/dc_file.md5

	if [ -f "$md5check" ]; then
		if $(md5sum -c "$md5check" --status); then
			return 0
		fi
	fi

	local services_cache_file=$(get_workspace_cache_dir)/services
	dc config --services > "$services_cache_file"

	md5sum "$(dc_file)" > "$md5check"
}
