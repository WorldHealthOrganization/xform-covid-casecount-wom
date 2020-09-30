#!/bin/bash
###############################################################################
# Execution Script.
###############################################################################
source "${GITHUB_WORKSPACE}/.github/scripts/shutils.sh"
YML_FILE="${GITHUB_WORKSPACE}/xform.yml"

validate_csv_file() {
  CSV_FILE_PATH="$1"
  SCHEMA_URL="$2"

  if [ -z "${SCHEMA_DIR}" ]; then
    SCHEMA_DIR=$(mktemp -d)
    echo "Schema dir created: ${SCHEMA_DIR}"
  fi

  echo "================================================================================"
  echo "File: ${CSV_FILE_PATH}"
  echo "Schema: ${SCHEMA_URL}"

  if [ ! -f "${CSV_FILE_PATH}" ]; then
    echo "File does not exist."
    return 1
  fi

  SCHEMA_FILENAME=$(basename "${SCHEMA_URL}")
  SCHEMA_PATH="${SCHEMA_DIR}/${SCHEMA_FILENAME}"

  if [ ! -f "${SCHEMA_PATH}" ]; then
    echo "Downloading schema file..."
    if ! wget "${SCHEMA_URL}" -O "${SCHEMA_PATH}"; then
      echo "Failed to download schema file."
      return 1
    fi
  fi

  if ! csv-schema validate-csv "${CSV_FILE_PATH}" "$SCHEMA_PATH"; then
    echo "CSV validation failed."
    return 1
  else
    echo "CSV validation succeeded."
    return 0
  fi
}

EXIT_CODE=0

# Parse the YML File and validate each CSV file against the schema definition.
while IFS='|' read -r file schema; do
  if ! validate_csv_file "${file}" "${schema}"; then
    EXIT_CODE=1
  fi
done < <(execOrExit yq -c -r '.outputs[] | .file + "|" + .schema' "${YML_FILE}")

exit ${EXIT_CODE}
