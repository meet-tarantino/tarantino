all:

install: uninstall
	cp tt /usr/local/bin/ && \
		mkdir -p /usr/local/share/tarantino/templates && \
		cp *.sh /usr/local/share/tarantino && \
		cp -R templates /usr/local/share/tarantino && \
		cp -f tt_completion /usr/local/share/tarantino && \
		cp -f tt_completion_hook.bash /etc/bash_completion.d/ && \
		./tt install && \
		echo Installation complete. && \
		echo Press enter to continue.

uninstall:
		rm -f /usr/local/bin/tt && \
		rm -rf /usr/local/share/tarantino && \
		rm -f /etc/bash_completion.d/tt_completion_hook.bash

