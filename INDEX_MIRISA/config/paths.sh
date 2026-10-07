# Carregar com source; MIRISA_ROOT opcional substitui a raiz detectada.
MIRISA_ROOT="${MIRISA_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
if [[ ! -f "${MIRISA_ROOT}/config/paths.sh" ]]; then
  echo "Raiz INDEX_MIRISA inválida: ${MIRISA_ROOT}" >&2
  return 1
fi
cd -- "${MIRISA_ROOT}" || return 1
export MIRISA_ROOT
mkdir -p outputs/models outputs/tables outputs/netcdf outputs/figures
