#!/bin/bash
###############################################################################
# Docker container entrypoint script.
###############################################################################
export ACTION_DIR="${GITHUB_WORKSPACE}/.github/actions/validate-csv"
source "${GITHUB_WORKSPACE}/.github/scripts/shutils.sh"
source "${GITHUB_WORKSPACE}/.github/scripts/container.sh"

${ACTION_DIR}/exec.sh
ACTION_STATUS=$?

if [ ${ACTION_STATUS} -eq 0 ]; then
  echo "Success."
else
  echo "Fail."
fi

exit ${ACTION_STATUS}
