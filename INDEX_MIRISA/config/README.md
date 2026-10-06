# Configuração de caminhos

| Arquivo | Uso |
| --- | --- |
| paths.R | Carregado pelos scripts R; raiz atual ou MIRISA_ROOT |
| paths.sh | Carregado pelos Shell; raiz detectada ou MIRISA_ROOT |
| paths.example.yaml | Contrato legível de diretórios; não carregado automaticamente |

Python usa scripts/functions/PYTHON/project_paths.py. A execução padrão é a partir de INDEX_MIRISA; Shell e scripts Python também detectam a raiz pela sua própria localização. MIRISA_ROOT deve ser um caminho absoluto para INDEX_MIRISA, não para a raiz MIRISA.

Para outra localização no Bash:

```bash
export MIRISA_ROOT=/caminho/absoluto/MIRISA_organizado/INDEX_MIRISA
```

Em R interativo, usar Sys.setenv(MIRISA_ROOT="/caminho/absoluto/INDEX_MIRISA") antes de source. GrADS deve ser iniciado na raiz do projeto.

Esta configuração centraliza a raiz e os diretórios. Datas, filtros, arquivos de referência e limiares continuam nos scripts e precisam de validação antes de uma futura configuração científica única. O YAML é somente um exemplo de contrato, sem parser integrado.
