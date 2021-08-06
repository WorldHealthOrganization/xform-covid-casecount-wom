#!/bin/bash
source "${GITHUB_WORKSPACE}/.github/scripts/shutils.sh"
###############################################################################
# Install xform specific dependencies.
###############################################################################

# TODO: Uncomment and ddd additional packages needed for your transformer.

#installAptPackages pkg1 pkg2 pkg3

R -e "remotes::install_github('WorldHealthOrganization/geoutils', upgrade = FALSE)"
R -e "install.packages('snakecase')"

exit 0
