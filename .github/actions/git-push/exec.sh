#!/bin/bash
###############################################################################
# Execution Script.
###############################################################################
source "${GITHUB_WORKSPACE}/.github/scripts/shutils.sh"
ABS_PUSH_DIR="${GITHUB_WORKSPACE}/${PUSH_DIR}"

if [ ! -d "${ABS_PUSH_DIR}" ]; then
  echo "${ABS_PUSH_DIR} does not exist, aborting."
  exit 1
else
  echo "Pushing directory: ${ABS_PUSH_DIR}"
fi

execOrExit cd "${ABS_PUSH_DIR}"

# Open the permissions on all files before committing otherwise these files
# will be owned by the root user that runs this action in docker. This will prevent
# permissions issues when pulled locally for development.
execOrExit chmod -R a+rw "${ABS_PUSH_DIR}"

execOrExit git config --global user.email "${GIT_EMAIL}"
execOrExit git config --global user.name "${GIT_NAME}"

if $(git status . | grep -qE "(Changes not staged|Untracked files)"); then
  echo "Staging changes."
  execOrExit git add .
fi

if $(git status . | grep -q "Changes to be committed"); then

  if [ -z "${SKIP_COMMIT}" ]; then
    echo "Committing changes."
    execOrExit git commit -m "Auto commit: $(date)"
  else
    echo "Skipping git commit..."
  fi

fi

if [ -z "${SKIP_PUSH}" ]; then
  echo "Pushing changes."
  git push --force
else
  echo "Skipping git push..."
fi
PUSH_STATUS=$?

exit ${PUSH_STATUS}
