#!/bin/bash
###############################################################################
# Execution Script.
###############################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_GIT_URL="git@github.com:covid-open-data/xform-template.git"
TMP_DIR=$(mktemp -d)

if git clone "${SOURCE_GIT_URL}" "${TMP_DIR}"; then
  cp -R "${TMP_DIR}/.github" "${SCRIPT_DIR}/../../"
  echo ".github source updated. Check git diff before committing changes."
  echo "Update succeeded."
else
  echo "Update failed."
fi

