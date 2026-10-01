#!/usr/bin/env bash
#
# build-thesis.sh
# ---------------
# Compile the thesis PDF (thesis/main.typ -> build/thesis.pdf).
#
# Any extra arguments are forwarded to `typst compile`, so you can override the
# configuration without editing config.typ, e.g.:
#
#   ./scripts/build-thesis.sh --input language=ro --input thesis_type=master
#
# Exit code is non-zero if the compilation fails.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

TYPST="${TYPST:-typst}"
OUT="build/thesis.pdf"

mkdir -p build

echo "Building thesis -> ${OUT}"
"${TYPST}" compile --root . "$@" thesis/main.typ "${OUT}"
echo "OK: ${OUT}"
