#!/usr/bin/env bash

dc_file() {
	if [ $IS_GLOBAL = true ]; then
		echo /usr/local/share/tarantino/docker-compose.yml
	else
		echo $(dirname $0)/docker-compose.yml
	fi
}

dc() {
	PROJECTS=$PROJECTS docker-compose -f $(dc_file) $*
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
	if [ $IS_GLOBAL = true -a -f $ALL_SERVICES_FILE ]; then
		cat "$ALL_SERVICES_FILE"
	else
		dc config --services
	fi
}

dc_get_services() {
	get_all_services | grep -Ev $NOT_SERVICES_PATTERN
}

dc_sample_data_scripts() {
	local sample_data_dir="$PROJECTS/$SAMPLE_DATA"
	if [ -d $sample_data_dir ]; then
		cat "$sample_data_dir"/package.json | jq -r '.scripts | keys[]' | grep -vx test
	fi
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
				links=$(get_links $service | grep -Ev $NOT_SERVICES_PATTERN)
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
	#hard-coded repos that for now will always be a dependency
	echo gogo-templates
	echo grafana
	echo butch
}