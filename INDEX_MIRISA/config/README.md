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

Esta configuração centraliza a raiz e os diretórios. As rotinas históricas conservam datas, filtros e limiares próprios. As três novas referências são lidas de climatology_periods.json pela nova rotina de preparação. O YAML é somente um exemplo de contrato, sem parser integrado.

## Períodos climatológicos

`climatology_periods.json` define referências inclusivas de 01/01 a 31/12: 1981–2010, 1991–2020 e 1981–2020. `default` indica a referência recomendada para novos consumidores; a rotina de geração usa `all` quando nenhuma seleção é fornecida, para preparar as três. Use `--period 1991_2020` ou `MIRISA_CLIM_PERIOD=1991_2020` para selecionar uma. A opção explícita prevalece sobre a variável de ambiente.

A referência controla média diária, anomalias e, no modo `standardize`, o recorte antes do desvio temporal. Não muda automaticamente o período de ajuste MCA ou os modelos já salvos. Os scripts datados continuam lendo produtos `historico`; para comparar novas referências, fornecer os novos produtos, reestimar o MCA e salvar modelos/resultados com identificação da base e referência.
