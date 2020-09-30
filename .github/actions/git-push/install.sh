#!/bin/bash
###############################################################################
# Install base container dependencies.
###############################################################################
source "${GITHUB_WORKSPACE}/.github/scripts/shutils.sh"
git --version
exit $?
