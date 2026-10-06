# Visualização e diagnósticos Python

## Inventário

| Arquivo | Função e situação |
| --- | --- |
| `DIAGRAM_PSPACE_MIRISA_20230501.py` | Diagrama da trajetória nos últimos 40 dias; melhor candidato à consolidação, sujeito à validação de fases/cores |
| `teste_DP.py` | Versão muito semelhante, para 90 dias; não é teste automatizado |
| `diagram_space_phase.py` | Versão antiga; chamada plt.text recebe séries em lugar de posições escalares |
| `diagram_space_phase_20230429.py` | Experimento incompleto: ax é a tupla retornada por plt.subplots; depois chama ax.add_collection |
| `MCA_PLOT.py` | Mapas de padrões de precipitação MCA; títulos RR1/SDII não correspondem aos dados plotados |
| `filtro_butterworph.py` | Experimento de filtro com frequências/amostragem inadequadas para a banda diária 20–100 dias |
| `AA03-Aspectos_Climatologicos_MIRISA.ipynb` | Distribuição de amplitude, classes e sazonalidade; limites exploratórios |
| `Artigo1_MIRISA_Fig3a9.ipynb` | Notebook misto: diagnósticos e exemplos incompletos; inclui fases aleatórias |
| `teste.csv`, `btw_py.csv` | Entrada/resultado do experimento de filtro; não são a série oficial do índice |
| Três PNG MIRISA | Figuras já exportadas; separar de código em futura organização |

## Dependências e entradas

Scripts básicos: NumPy, pandas, Matplotlib. Filtro: SciPy. Mapas: netCDF4, Basemap, GeoPandas e contextily (parte dos imports pode ser dispensável). Notebook de figuras também importa xarray/SciPy.

Diagramas leem tabelas com separador `;` e colunas `Year`, `Month`, `Day`, `MIRISA1c1`, `MIRISA1c2`, `Phase`, `Amplitude`. A MCA histórica exporta `day` minúsculo: harmonizar antes de usar. Caminhos/datas são fixos. Mapas exigem NetCDF de padrões e shapefile completo, ausentes no repositório.

As saídas dos scripts são PNG em `AA04-FIG`; o notebook climatológico grava PNG também no diretório de execução. Os diretórios precisam existir.

## Ajustes antes do uso

- Unificar os quatro diagramas em uma função com entrada, período, janela e saída configuráveis.
- Validar quadrantes/fases contra a função R; algumas versões trocam rótulos 6/7 e outras invertem o eixo y.
- Construir a escala de cores com limites explícitos de mês, incluindo dezembro–janeiro e janelas de um único mês.
- Usar o número efetivo de linhas, não nt fixo, nos loops sobre a série.
- Corrigir nomes/títulos dos mapas e checar projeção do shapefile.
- Para filtro diário, usar fs=1 e frequências 1/100 e 1/20 ciclos/dia; comparar resposta, fase e bordas com a versão R antes de assumir equivalência.
- No notebook Artigo1, substituir a função calcula_fase, que retorna números aleatórios, pelas fases reais e fornecer os campos de precipitação/OLR.
- Corrigir variáveis não definidas, como mirisa_clim e mirisa_proj, antes de executar todas as células.
- Não rotular dados MIRISA como RMM; não comparar contagens absolutas entre séries com períodos diferentes.

Análise sintática: seis scripts e 21 células de código dos dois notebooks passaram. Isso não valida execução, gráficos nem resultados. Não foi executado o fluxo com dados reais.

Consulte a [avaliação técnica](../../AVALIACAO_TECNICA.md) para as diferenças entre versões.
