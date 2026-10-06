# Análises e diagnósticos

| Arquivo | Conteúdo e estado |
| --- | --- |
| AA02.00-COMPOSICAO_FASES_MIRI_20260321.R | Composições DJF por fase, amplitude ≥1,5; exige reparos temporais/NetCDF |
| AA04_Comparacao_MIRISA.R | Comparação exploratória de versões; objeto miri não definido |
| Avaliação_Break_Active_Monsoon_20260321.r | Eventos, frequências, lags e glm; contém erro de sintaxe preexistente |
| Avaliação_FasesxChuva_20260321.r | Diagnósticos amplitude/MPI e mapas; nomes de variável/imports precisam de revisão |
| AA03-Aspectos_Climatologicos_MIRISA.ipynb | Distribuição de amplitude, classes e sazonalidade |

Entradas: tabelas em outputs/tables, MPI em outputs/netcdf e campos em data/intermediate. Modelos/figuras de análises R permanecem em memória se não houver exportação explícita. O notebook grava figuras em outputs/figures; suas saídas antigas foram limpas para evitar apresentar gráficos sem nova execução.

O notebook detecta a raiz a partir do diretório atual ou MIRISA_ROOT. Os scripts R exigem execução a partir de INDEX_MIRISA, ou MIRISA_ROOT com caminho absoluto. Funções source foram atualizadas para scripts/functions/R.

Pacotes presentes: ncdf4, fields, beepr, dplyr, lme4, pROC, rlang, tidyr, brglm2 e PRROC; ggplot2 ainda precisa de importação explícita no código correspondente. Notebook: NumPy, pandas e Matplotlib.

Os eventos são identificados por sequências na série inteira e depois recortados para DJF. Frequências contam dias de eventos. Métricas na amostra de ajuste não comprovam previsão fora da amostra. Não foram mudados limiares, regras de evento, regressões ou testes estatísticos.

A composição antiga e o notebook Artigo1, que inclui fases aleatórias de exemplo, estão em experiments. Consulta a [avaliação](../../AVALIACAO_TECNICA.md).
