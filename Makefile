INSTALL_DIR = /usr/local/share/tarantino
BIN_DIR = /usr/local/bin
COMPLETION_DIR = /etc/bash_completion.d

all:

install: uninstall
	mkdir -p ${INSTALL_DIR}/templates && \
		cp *.sh ${INSTALL_DIR} && \
		cp -f tt ${INSTALL_DIR} && \
		ln -sf ${INSTALL_DIR}/tt ${BIN_DIR}/tt &&\
		cp -f tt_completion ${INSTALL_DIR} && \
		cp -R templates ${INSTALL_DIR} && \
		cp -f tt_completion_hook.bash ${COMPLETION_DIR}/ && \
		git describe --always --tags > ${INSTALL_DIR}/version.txt &&\
		./tt install && \
		echo Installation complete.

uninstall:
		rm -f ${BIN_DIR}/tt && \
		rm -rf ${INSTALL_DIR} && \
		rm -f ${COMPLETION_DIR}/tt_completion_hook.bash
