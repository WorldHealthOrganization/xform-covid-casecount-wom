###############################################################################
# Docker container init script.
# ACTION_DIR variable must be set before sourcing this file.
###############################################################################
CONTAINER_INSTALL_PATH=${ACTION_DIR}/install.sh

if [ -z "${GITHUB_WORKSPACE}" ]; then
  echo "GITHUB_WORKSPACE not set, aborting."
  exit 1
fi

if [ -f "${CONTAINER_INSTALL_PATH}" ]; then
  echo "Running container install script: ${CONTAINER_INSTALL_PATH}"

  if ! ${CONTAINER_INSTALL_PATH}; then
    echo "Container Install failed."
    exit 1
  else
    echo "Container Install succeeded."
  fi

fi

cd "${GITHUB_WORKSPACE}"
