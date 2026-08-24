
echo base: ${OPENEDGE_BASE_VERSION}
echo version: ${OPENEDGE_VERSION}

docker run -v ${PWD}/src:/target devbfvio/oeinstaller:${OPENEDGE_VERSION}
