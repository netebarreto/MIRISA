# Auxiliares Python

project_paths.py fornece setup_project(root=None). Valida a raiz INDEX_MIRISA, muda o diretório de trabalho para ela e cria outputs/models, outputs/tables, outputs/netcdf e outputs/figures. Usa somente a biblioteca padrão Python.

Scripts e o notebook reorganizado carregam este auxiliar. MIRISA_ROOT pode substituir a raiz detectada. A função não carrega dados nem decide referências, filtros ou limiares científicos.
