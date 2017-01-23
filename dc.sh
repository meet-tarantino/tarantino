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
	# `docker-compose config` output wreaks havoc with list indentation,
	# until we find a non-hack way to deal with this, parse file directly
	parse_yaml $(dc_file) | sed -ne "s|$key+=(\"\(.*\)\")|\1|p"
}

dc_get_services_with_source() {
	dc_get_sources | sed -e 's/^\[\(.*\)\]=.*$/\1/'
}

dc_get_service_and_dependencies_with_source() {
	# intersect service & dependencies with source backed services
	sort <(dc_get_service_and_dependencies $@) <(dc_get_services_with_source) | uniq -d
}

dc_get_service_and_dependencies() {
	if [[ $# -gt 0 ]]; then
		services=
		result=$@ # start with the ones passed in
		while [ "$services" != "$result" ]; do
			services=$result
			result=

			# for each service...
			for service in $services; do
				# add service and linked services to result
				result="$result $service $(dc_get_links $service)"
			done

			# remove duplicates and normalize whitespace
			result=$(echo $result | awk -v RS="[\n ]" '!a[$0]++')
		done
		if [ ! -z "$result" ]; then
			echo "$result"
		fi
	else
		echo "$(dc_get_services)"
	fi
}

get_workspace_cache_dir() {
	local cachedir=$(get_workspace_dir)/.cache
	mkdir -p $cachedir
	echo $cachedir
}

dc_get_services() {
	if [ "$TT_IS_GLOBAL" = true ]; then
		generate_compose_file_caches
		cat "$(get_workspace_cache_dir)/services"
	else
		dc config --services
	fi
}

dc_get_sources() {
	if [ "$TT_IS_GLOBAL" = true ]; then
		generate_compose_file_caches
		cat "$(get_workspace_cache_dir)/sources"
	else
		parse_sources
	fi
}

generate_compose_file_caches() {
	local md5check=$(get_workspace_cache_dir)/dc_file.md5

	if [ -f "$md5check" ]; then
		if $(md5sum -c "$md5check" --status); then
			return 0
		fi
	fi

	local yaml_cache_file=$(get_workspace_cache_dir)/yaml
	dc config > "$yaml_cache_file"

	local services_cache_file=$(get_workspace_cache_dir)/services
	dc config --services > "$services_cache_file"

	local sources_cache_file=$(get_workspace_cache_dir)/sources
	parse_sources > $sources_cache_file

	md5sum "$(dc_file)" > "$md5check"
}

get_compose_yaml() {
	if [ "$TT_IS_GLOBAL" = true ]; then
		generate_compose_file_caches
		cat "$(get_workspace_cache_dir)/yaml"
	else
		dc config
	fi
}

parse_sources() {
	get_compose_yaml | parse_yaml |
		grep '^services_.*_labels_com.tarantino.source=' |
		sed -e 's/^services_\(.*\)_labels_com.tarantino.source=(\(.*\))$/[\1]=\2/'
}
