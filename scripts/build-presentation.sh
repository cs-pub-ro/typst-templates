#!/usr/bin/env bash
#
# build-presentation.sh
# ---------------------
# Compile the presentation PDF (thesis/presentation.typ -> build/presentation.pdf).
#
# The presentation depends on external Typst packages (touying, cetz, fletcher,
# numbly, theorion). The first run downloads them from the Typst package
# registry (network required); subsequent runs use the local cache.
#
# Any extra arguments are forwarded to `typst compile`, e.g.:
#
#   ./scripts/build-presentation.sh --input language=ro
#
# Exit code is non-zero if the compilation fails.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

TYPST="${TYPST:-typst}"
OUT="build/presentation.pdf"

mkdir -p build

"${TYPST}" compile --root . "$@" thesis/presentation.typ "${OUT}"
echo "OK: ${OUT}"
