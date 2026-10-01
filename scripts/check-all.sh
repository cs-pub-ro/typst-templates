#!/usr/bin/env bash
#
# check-all.sh
# ------------
# Run the local verification suite:
#   1. Build the default thesis PDF.
#   2. Build the presentation PDF (requires network on first run for packages).
#
# By default a failure in the presentation step (commonly an offline machine
# that cannot download Typst packages) does NOT fail the whole script; set
# STRICT_PRESENTATION=1 to make it fatal.
#
# Exit code:
#   0  -> all required checks passed
#   1  -> a required check failed
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

STRICT_PRESENTATION="${STRICT_PRESENTATION:-0}"
rc=0

echo "============================================================"
echo " 1/2  Build default thesis"
echo "============================================================"
if ! "${SCRIPT_DIR}/build-thesis.sh"; then
  echo "FAILED: thesis build" >&2
  rc=1
fi

echo
echo "============================================================"
echo " 2/2  Build presentation"
echo "============================================================"
if ! "${SCRIPT_DIR}/build-presentation.sh"; then
  if [ "${STRICT_PRESENTATION}" = "1" ]; then
    echo "FAILED: presentation build (STRICT_PRESENTATION=1)" >&2
    rc=1
  else
    echo "WARNING: presentation build failed (likely missing network for Typst" >&2
    echo "         packages). Set STRICT_PRESENTATION=1 to treat this as fatal." >&2
  fi
fi

echo
if [ ${rc} -eq 0 ]; then
  echo "check-all: PASS"
else
  echo "check-all: FAIL" >&2
fi
exit ${rc}
