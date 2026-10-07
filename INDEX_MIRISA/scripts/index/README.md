# MCA e projeção

| Arquivo | Função |
| --- | --- |
| AA01.00-MCA_TwoDatasets_20230225.R | Ajuste da MCA e exportação de padrões/tabela |
| AA03.00-MIRISA_PROJECAO_20230223.R | Projeção de OLR/U850/U200 no modelo histórico |

A versão MCA 20230220 está preservada em experiments/legacy/R. A escolha da versão 20230225 como candidata organizacional não resolve a convenção de sinais ou a definição do índice.

Entradas: campos padronizados em data/<variavel>/<tratamento>/AC02-BTW_APAD_R, máscara em data/<variavel>/climatologia ou data/static e modelo em outputs/models. Saídas: outputs/models, outputs/tables e outputs/netcdf. Dependências: ncdf4, fields, beepr e funções de scripts/functions/R.

Cinco auxiliares chamados por source continuam ausentes. O caminho de cov4gappy foi corrigido para a implementação existente. A projeção ainda procura o modelo de data 20230226, enquanto a MCA disponível salva 20230225; a reorganização não escolhe um modelo diferente silenciosamente.

Também seguem pendentes: exportação apenas de B, normalização/sinais, alinhamento de datas, cortes espaciais fixos, contagem de observações válidas e fase 9 na borda angular. Ver [avaliação](../../AVALIACAO_TECNICA.md).
