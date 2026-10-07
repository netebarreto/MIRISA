#!/usr/bin/env bash
set -euo pipefail
_mirisa_script_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${_mirisa_script_root}/config/paths.sh"
exec python3 "${MIRISA_ROOT}/scripts/preprocess/gerar_climatologias.py" "$@"
