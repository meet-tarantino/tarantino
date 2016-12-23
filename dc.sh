#!/usr/bin/env bash

tt_dc() {
	dc $@
}

dc_projects_file() {
	echo $(get_workspace_dir)/docker-compose-projects.yml
}

dc_static_file() {
	echo $(get_workspace_dir)/docker-compose-static.yml
}

dc_static() {
	TT_PROJECTS=$TT_PROJECTS docker-compose -f $(dc_static_file) $@
}

dc_projects() {
	TT_PROJECTS=$TT_PROJECTS docker-compose -f $(dc_projects_file) $@
}

dc() {
	TT_PROJECTS=$TT_PROJECTS docker-compose -f $(dc_static_file) -f $(dc_projects_file) $@
}

dc_get_links() {
	local key=services_"$1"_links
	local links=$key[@]
	eval $(parse_yaml $(dc_projects_file) | grep $key)
	for link in ${!links}; do
		echo $link
	done
}

get_workspace_cache_dir() {
	local cachedir=$(get_workspace_dir)/.cache
	mkdir -p $cachedir
	echo $cachedir
}

generate_service_lists() {
	local md5check=$(get_workspace_cache_dir)/dc_files.md5

	if [ -f "$md5check" ]; then
		if $(md5sum -c "$md5check" --quiet); then
			return 0
		fi
	fi

	local projects_file=$(get_workspace_cache_dir)/projects
	local static_file=$(get_workspace_cache_dir)/static
	local all_services_file=$(get_workspace_cache_dir)/all

	dc_projects config --services > "$projects_file"
	dc_static config --services > "$static_file"
	dc config --services > "$all_services_file"

	md5sum "$(dc_projects_file)" "$(dc_static_file)" > "$md5check"
}

dc_get_all_services() {
	generate_service_lists
	cat "$(get_workspace_cache_dir)/all"
}

dc_get_projects() {
	generate_service_lists
	cat "$(get_workspace_cache_dir)/projects"
}

dc_get_static() {
	generate_service_lists
	cat "$(get_workspace_cache_dir)/static"
}

dc_get_repos() {
	if [[ $# -gt 0 ]]; then
		services=
		ALL_INFRASTRUCTURE=$(dc_get_static | paste -sd '|' -)
		repos=$@
		while [ "$services" != "$repos" ]; do
			services=$repos
			repos=
			for service in $services; do
				service=$(echo $service | grep -Ev $ALL_INFRASTRUCTURE)
				if [ ! -z "$service" ]; then
					repos="$repos $service"
				fi
				links=$(dc_get_links $service | grep -Ev $ALL_INFRASTRUCTURE)
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
		echo "$(dc_get_projects)"
	fi
}
