
echo base: ${OPENEDGE_BASE_VERSION}
echo version: ${OPENEDGE_VERSION}

docker run -v ${PWD}/src:/target devbfvio/oeinstaller:${OPENEDGE_VERSION}

if [[ "${OPENEDGE_VERSION}" > "12.8.3" ]]; then
  echo ">=12.8.4 we need the base version as well"
  mv ${PWD}/src/PROGRESS_OE.tar.gz ${PWD}/src/PROGRESS_PATCH_OE.tar.gz
  echo "download base version ${OPENEDGE_BASE_VERSION}"
  docker run -v ${PWD}/src:/target devbfvio/oeinstaller:${OPENEDGE_BASE_VERSION}
  ls -l ${PWD}/src
fi