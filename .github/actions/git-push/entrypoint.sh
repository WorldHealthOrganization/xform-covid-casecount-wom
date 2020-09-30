#!/bin/bash
###############################################################################
# Docker container entrypoint script.
###############################################################################
export ACTION_DIR="${GITHUB_WORKSPACE}/.github/actions/git-push"
source "${GITHUB_WORKSPACE}/.github/scripts/shutils.sh"
export PUSH_DIR=$@

if [ -z "${PUSH_DIR}" ]; then
  echo "push-dir not provided, aborting."
  exit 1
fi

if [ -z "${GIT_EMAIL}" ]; then
  echo "GIT_EMAIL not set, using SYSTEM@users.noreply.github.com."
  export GIT_EMAIL="SYSTEM@users.noreply.github.com"
fi

if [ -z "${GIT_NAME}" ]; then
  echo "GIT_NAME not set, using SYSTEM."
  export GIT_NAME="SYSTEM"
fi

source "${GITHUB_WORKSPACE}/.github/scripts/container.sh"

${ACTION_DIR}/exec.sh
ACTION_STATUS=$?

if [ ${ACTION_STATUS} -eq 0 ]; then
  echo "Success."
else
  echo "Fail."
fi

exit ${ACTION_STATUS}
