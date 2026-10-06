# INDEX_MIRISA

Rotinas de cálculo, projeção e análise do índice multivariado intrassazonal de precipitação da América do Sul (MIRISA / MIRI.SA).

**Estado:** estrutura reorganizada, com rotinas científicas ainda em validação. A mudança de pastas não corrige os problemas científicos e de execução descritos na [avaliação técnica](AVALIACAO_TECNICA.md).

## Organização

| Diretório | Conteúdo |
| --- | --- |
| [config](config/README.md) | Raiz de execução e contratos de caminhos |
| [scripts/preprocess](scripts/preprocess/README.md) | Anomalias, filtragem e padronização |
| [scripts/index](scripts/index/README.md) | MCA e projeção |
| [scripts/analysis](scripts/analysis/README.md) | Composições, monção e diagnósticos |
| [scripts/plots](scripts/plots/README.md) | Diagramas e mapas Python/GrADS |
| [scripts/functions](scripts/functions/README.md) | Auxiliares R, Python e GrADS |
| [experiments](experiments/README.md) | Versões históricas e protótipos preservados |
| [data](data/README.md) | Dados brutos, referências, intermediários e shapefiles locais |
| [outputs](outputs/README.md) | Modelos, tabelas, NetCDF, figuras e exemplos |

Funções ficam dentro de scripts, separadas por linguagem. Nomes datados das rotinas foram preservados para rastreabilidade. Consulta o [mapa completo de migração](MIGRACAO.md).

## Obter esta organização

```bash
git clone --branch organiza-index-mirisa --single-branch https://github.com/netebarreto/MIRISA.git MIRISA_organizado
cd MIRISA_organizado/INDEX_MIRISA
```

Usa uma pasta nova. O clone não inclui NetCDF, modelos RData, tabelas do índice ou referências que existam apenas na máquina local. Copia esses dados seguindo o mapa em MIGRACAO.md, preservando os originais até conferir os produtos.

## Diretório de execução

Os caminhos das rotinas reorganizadas são relativos a INDEX_MIRISA. R recebe configuração em config/paths.R; Shell em config/paths.sh; Python em scripts/functions/PYTHON/project_paths.py. MIRISA_ROOT pode indicar outra cópia por caminho absoluto. GrADS deve ser iniciado na raiz INDEX_MIRISA.

Exemplos de invocação, após fornecer entradas/dependências e resolver os bloqueios:

```bash
Rscript scripts/index/AA03.00-MIRISA_PROJECAO_20230223.R
python scripts/plots/DIAGRAM_PSPACE_MIRISA_20230501.py
bash scripts/preprocess/AA01-PROC_anom.sh
```

Esses comandos descrevem como localizar as rotinas; não são uma promessa de execução completa. A configuração cria os quatro diretórios principais de saída. Subdiretórios específicos de entrada/intermediários precisam ser fornecidos antes da execução.

## Fluxo científico

Preparação e anomalias → filtragem 20–100 dias → padronização com referências fixas → ajuste MCA → projeção → diagnósticos, composições e análise de monção. O mapa das etapas está em [scripts/README.md](scripts/README.md).

O artigo de Barreto et al. (2019), seção 2, define as componentes do MIRI.SA pela média dos coeficientes dos dois lados da MCA. A implementação disponível exporta somente o lado atmosférico normalizado. Essa variante precisa de identificação e comparação com a definição publicada.

A filtragem bilateral usa informação posterior ao dia estimado; REALT no nome não garante processamento causal. Os modelos de monção ainda calculam métricas na própria amostra de ajuste. Limiares exploratórios de amplitude não são uma classificação universal validada.

## Dependências e verificação

R: ncdf4, fields, beepr, seewave, signal e pacotes estatísticos indicados no README de análise. Python: NumPy, pandas, Matplotlib; mapas também precisam de netCDF4/Basemap/GeoPandas/contextily. Shell: Bash e CDO. Mapas legados: GrADS. Não há lockfile com versões fixadas.

A reorganização foi verificada quanto a cobertura dos arquivos, preservação dos arquivos arquivados, sintaxe Python/Shell, configuração de caminhos e links locais. A validação científica completa exige dados, funções ausentes e ambiente R/CDO/GrADS.

## Referências

- Barreto et al. (2019). Multivariate intraseasonal rainfall index applied to South America. [DOI: 10.1002/met.1780](https://doi.org/10.1002/met.1780).
- Barreto et al. (2017), antecedente metodológico de MCA em Climate Dynamics.
- Grimm et al. (2021). Active and break phases of the South American summer monsoon: MJO influence and subseasonal prediction.
- Sapucci et al. (2025), estudos sobre oscilação intrassazonal, EOF/redes neurais e previsão.

As referências não validam automaticamente cada versão de código. A licença de redistribuição ainda precisa ser definida.
