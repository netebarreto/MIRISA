"""Configuração de caminhos compartilhada por scripts e notebooks."""
import os
from pathlib import Path

def setup_project(root=None):
    root = Path(root or os.environ.get("MIRISA_ROOT") or Path(__file__).resolve().parents[3]).resolve()
    if not (root / "config/paths.R").is_file():
        raise FileNotFoundError(f"Raiz INDEX_MIRISA inválida: {root}")
    os.chdir(root)
    for name in ("models", "tables", "netcdf", "figures"):
        (root / "outputs" / name).mkdir(parents=True, exist_ok=True)
    return root
