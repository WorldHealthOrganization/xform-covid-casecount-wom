#!/bin/bash
###############################################################################
# Install base container dependencies.
###############################################################################
source "${GITHUB_WORKSPACE}/.github/scripts/shutils.sh"
python --version
pip --version
csv-schema --version
exit $?
