# INDEX_MIRISA

Rotinas de cálculo e projeção do índice multivariado intrassazonal de precipitação para a América do Sul (MIRISA, denominado MIRI.SA no artigo de 2019), composição por fases e análises exploratórias de sua relação com a monção.

**Estado atual:** coleção de scripts de pesquisa, com versões históricas e protótipos. O fluxo completo ainda não é reproduzível apenas com os arquivos deste repositório. Há entradas e funções ausentes, caminhos locais e inconsistências metodológicas. Consulte a [avaliação técnica](AVALIACAO_TECNICA.md) antes de executar.

## Organização

| Diretório | Conteúdo |
| --- | --- |
| [AA02-SCRIPTS](AA02-SCRIPTS/README.md) | Mapa das etapas e dependências |
| [R](AA02-SCRIPTS/R/README.md) | Filtragem, MCA, projeção, composições e análise de monção |
| [R/AA00-Functions](AA02-SCRIPTS/R/AA00-Functions/README.md) | Funções auxiliares disponíveis |
| [PYTHON](AA02-SCRIPTS/PYTHON/README.md) | Diagramas de fases, mapas e notebooks |
| [SH](AA02-SCRIPTS/SH/README.md) | Pré-processamento com CDO |
| [GRADS](AA02-SCRIPTS/GRADS/README.md) | Mapas de composições e barra de cores |

Os diretórios de dados e resultados citados nos scripts não estão incluídos. Os caminhos aparecem como `INPUT_NC`, `AA00-NC_INPUT`, `AA01-NC_INPUT`, `AA03-RData_TxT`, `AA03-RData_txt`, `AA03-NC_OUTPUT`, `AA04-FIG` e `AA00-SHP`. Precisam ser harmonizados; diferenças de maiúsculas são relevantes em Linux.

## Fluxo científico pretendido

1. Preparar precipitação, OLR e vento zonal em 850 e 200 hPa; validar datas, calendário, unidades e grades.
2. Remover o ciclo climatológico diário; verificar a remoção de tendência requerida para reproduzir a configuração publicada.
3. Filtrar a banda de 20–100 dias e documentar lacunas e bordas.
4. Padronizar com estatísticas de referência fixas e obter médias equatoriais de OLR/U850/U200.
5. Ajustar a MCA entre precipitação e o conjunto atmosférico `cbind(OLR, U85, U20)`.
6. Salvar padrões, coeficientes, normalização e convenção de sinais/fases.
7. Projetar novos campos nos mesmos padrões e produzir a tabela diária.
8. Gerar diagnósticos, composições e análises de associação com regimes da monção.

Esta é a ordem conceitual, não um comando automático: os scripts precisam dos ajustes descritos na avaliação.

## Definição publicada e implementação atual

Barreto et al. (2019), seção 2, define cada componente do MIRI.SA pela média dos coeficientes de expansão dos lados precipitação e atmosfera: `(a_i + b_i)/2`.

Nas rotinas MCA presentes, a tabela exportada usa `B[,i]/sqrt(Lambda[i])`. A projeção usa apenas OLR e ventos. Portanto, o produto exportado deve ser documentado como **implementação baseada no lado atmosférico da MCA**, até verificar sua equivalência e a normalização em relação ao índice publicado. Esta documentação não altera o cálculo.

O limiar de amplitude 1,5 é utilizado no artigo de 2019 para selecionar composições em DJF. Outros limites presentes nos scripts (0,8; 1; 1,2; 1,6; 2) são escolhas exploratórias e não constituem uma escala validada universal do MIRISA.

## Entradas e produtos

| Entrada | Uso |
| --- | --- |
| Precipitação CPC em NetCDF e máscara da América do Sul | Ajuste da MCA histórica |
| OLR e U850/U200 NCEP em NetCDF | Ajuste e projeção |
| Climatologias diárias e desvios de referência | Anomalias e padronização |
| Modelo MCA salvo em RData | Projeção de novos períodos |
| Precipitação CHIRPS e série regional chamada MPI | Estudos exploratórios de monção |
| Shapefile com arquivos auxiliares | Mapas Python |

A tabela do índice é texto separado por ponto e vírgula, com `Year`, `Month`, `day` ou `Day`, `MIRISA1c1`, `MIRISA1c2`, `Phase` e `Amplitude`. A diferença `day/Day` precisa ser corrigida nos consumidores. Resultados adicionais: RData, padrões/composições em NetCDF e figuras.

## Reprodução e limites

- Definir um diretório de trabalho comum e fornecer as entradas descritas nos READMEs por linguagem.
- Recuperar as funções ausentes antes de executar a MCA.
- Congelar período de referência, grades, filtro, normalização e sinais.
- Não apresentar métricas ajustadas na própria amostra como desempenho de previsão.
- A filtragem bilateral usa informação posterior ao dia analisado; o rótulo REALT no arquivo não demonstra processamento causal em tempo real.

A revisão de 06/10/2026 incluiu leitura de código, comparação de versões, análise sintática dos seis scripts Python e das 21 células de código dos notebooks, além de `bash -n` dos três scripts Shell. Não houve execução científica completa: dados/modelos/funções faltam e R/CDO não estão disponíveis no ambiente da revisão.

## Referências

- Barreto et al. (2019). *Multivariate intraseasonal rainfall index applied to South America*. Meteorological Applications. [DOI: 10.1002/met.1780](https://doi.org/10.1002/met.1780).
- Barreto et al. (2017). Estudo de MCA e variabilidade intrassazonal em Climate Dynamics, antecedente metodológico.
- Grimm et al. (2021). *Active and break phases of the South American summer monsoon: MJO influence and subseasonal prediction*.
- Sapucci et al. (2025). *South American Intraseasonal Oscillation: EOF and Neural Network Approaches*; e estudo de previsão intrassazonal em International Journal of Climatology.

As publicações fundamentam o contexto científico; sua citação não valida automaticamente cada versão de código. A árvore revisada não apresenta arquivo LICENSE na raiz: definir a licença antes de estabelecer condições de redistribuição.
