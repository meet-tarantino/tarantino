#!/usr/bin/env bash
info() {
	echo INFO: $*
}

bullet() {
	echo "INFO:   -" "$@"
}

has_curl() {
	hash curl 2>/dev/null
}

has_docker() {
	if hash docker 2>/dev/null; then
		local version=$(docker -v | sed 's/^Docker version \([^,]*\),.*/\1/')
		local versionMax=$(printf "$version\n1.9.1" | sort -V | tail -1)
		if [ "$versionMax" = "1.9.1" ]; then
			bullet "docker v1.10+ (missing - $version is too old)"
			return 1
		else
			bullet "docker v1.10+ (found)"
			return 0
		fi
	else
		bullet "docker v1.10+ (missing)"
		return 1
	fi
}

has_docker_compose() {
	if hash docker-compose 2>/dev/null; then
		# this comparison should keep working for a while
		local version=$(docker-compose -v | sed 's/^docker-compose version \([^,]*\),.*/\1/')
		local versionMax=$(printf "$version\n1.5.2" | sort -V | tail -1)
		if [ "$versionMax" = "1.5.2" ]; then
			bullet "docker-compose v1.6+ (missing - $version is too old)"
			return 1
		else
			bullet "docker-compose v1.6+ (found)"
			return 0
		fi
	else
		bullet "docker-compose v1.6+ (missing)"
		return 1
	fi
}

has_docker_group() {
	groups $user | grep &>/dev/null '\bdocker\b'
}

install_curl() {
	info Installing curl...
	sudo apt-get install -y curl
}

install_docker() {
	info "It's coffee time 'cause this will take a while"
	curl -sSL https://get.docker.com | sudo sh
}

install_docker_compose() {
	bullet "installing docker-compose"
	local release=$(curl -fL https://api.github.com/repos/docker/compose/releases/latest -H 'accept: application/json' 2> /dev/null)
	if [ $? -ne 0 ]; then
		bullet "docker-compose install failed: unable to query for latest available version"
		return 1
	fi
	local latest=$(echo "$release" | grep tag_name | sed -e 's/.*"tag_name":[^"]*"\([^"]*\)".*/\1/')
	if [ "$latest" == "" ]; then
		bullet "docker-compose install failed: unable to determine latest available version"
		return 1
	fi
	curl -L https://github.com/docker/compose/releases/download/$latest/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose 2> /dev/null
	sudo mv /tmp/docker-compose /usr/local/bin/
	sudo chmod +x /usr/local/bin/docker-compose
}

install_docker_group() {
	info "Granting $user access to run docker commands without sudo. You'll need to re-login for changes to take affect."
	sudo usermod -a -G docker $user
}

tt_install() {
	local user=${SUDO_USER:-$USER}
	local queue=""
	local install_confirm=""

	info "checking dependencies:"

	if has_curl; then
		bullet "curl (found)"
	else
		bullet "curl (missing)"
		queue="curl"
		install_confirm="curl"
	fi

	if ! has_docker; then
		queue="$queue docker"
		install_confirm="${install_confirm} docker"
	fi

	if ! has_docker_compose; then
		queue="$queue docker_compose"
		install_confirm="${install_confirm} docker-compose"
	fi

	if has_docker_group; then
		bullet "user is part of 'docker' group (found)"
	else
		bullet "user is part of 'docker' group (missing)"
		queue="$queue docker_group"
	fi

	if [ ! -z "$queue" ]; then
		echo
		echo "The following will be installed: ${install_confirm}"
		read -n 1 -p "Install missing dependencies? (Y/n)" CONFIRM
		if [ "$CONFIRM" == "n" -o "$CONFIRM" == "N" ]; then
			echo
			info "You chose not to install required dependencies, there be dragons."
		else
			echo
			for dep in $queue; do
				echo
				"install_$dep"
			done
		fi
	fi
}
