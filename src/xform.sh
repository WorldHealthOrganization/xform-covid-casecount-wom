#!/bin/bash
###############################################################################
# Install xform specific dependencies and execute the xform.
###############################################################################

INSTALL_FILE="${GITHUB_WORKSPACE}/src/install.sh"

if [ -f "${INSTALL_FILE}" ]; then
  echo "Installing xform dependencies..."
  ${INSTALL_FILE}
  INSTALL_STATUS=$?

  if [ ${INSTALL_STATUS} -ne 0 ]; then
    echo "Dependency install failed."
    exit 1
  else
    echo "Dependency install succeeded."
  fi
fi

# The command to execute the xform.
echo "Running xform..."
Rscript "${GITHUB_WORKSPACE}/src/xform.R"
exit $?
