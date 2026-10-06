# Rotinas R

## Inventário

| Arquivo | Finalidade e estado |
| --- | --- |
| `AA01.00-Filtro_BTW_NC.R` | Filtra precipitação, U200, U850 e OLR com seewave::bwfilter; entradas históricas |
| `AA03.00-Filtro_BTW_NC.R` | Filtra U200/U850/OLR com signal::butter e filtfilt; inclui preenchimento de OLR em posições fixas |
| `AA01.00-MCA_TwoDatasets_20230220.R` | MCA e exportação histórica; versão anterior |
| `AA01.00-MCA_TwoDatasets_20230225.R` | MCA com mudança de sinais e argumentos da função de fase |
| `AA03.00-MIRISA_PROJECAO_20230223.R` | Projeção atmosférica a partir de RData; lê dados até 2026 apesar do nome |
| `AA02.00-COMPOSICAO_FASES_MIRI_20211203.R` | Composições DJF por fase, amplitude ≥1,5, teste t pontual |
| `AA02.00-COMPOSICAO_FASES_MIRI_20260321.R` | Mesmo núcleo, com outra entrada de precipitação |
| `AA04_Comparacao_MIRISA.R` | Comparação exploratória de versões; objeto miri não definido no script |
| `Avaliação_Break_Active_Monsoon_20260321.r` | Eventos, frequências, lags e regressão logística; exige reparos |
| `Avaliação_FasesxChuva_20260321.r` | Diagnósticos de amplitude/MPI e mapas de chuva por fase |
| `Function_monsoon_atividade_20260322.r` | Identifica sequências e conta dias por fase dentro delas |
| `Function_Data_nc_convert_20260320.R` | Converte o eixo time de NetCDF em datas |
| `cov4gappy.r` | Produto cruzado com contagem de pares válidos; exige dados previamente centrados |
| `model_active_break_spell.r` | Prepara dados e agregações; não ajusta GLMM apesar do cabeçalho |
| `AB01.01- MIRISA_FORECAST_MVAR.R` | Esboço dynlm/VAR, com objetos não definidos e exemplo econômico residual |
| `AB01.01- MIRISA_FORECAST_MVAR` | Fragmento de write.table, sem cálculo de previsão |
| `filtro.R` | Experimentos incompletos de filtros, espectros e exemplo sísmico |
| [AA00-Functions](AA00-Functions/README.md) | Funções auxiliares existentes e lacunas |

## Dependências

Identificadas no código: `ncdf4`, `fields`, `beepr`, `seewave`, `signal`, `dplyr`, `lme4`, `pROC`, `rlang`, `tidyr`, `brglm2`, `PRROC`, `dynlm`. `zoo` aparece no rascunho fora desta pasta. Existem usos não acompanhados de importação explícita, como `ggplot()` e `image.plot()` em algumas rotinas. Não há lockfile; as versões compatíveis ainda precisam ser registradas.

## Entradas e saídas

- Filtragem: NetCDF de anomalias diárias → NetCDF filtrado.
- MCA: campos padronizados de chuva/OLR/U850/U200 e máscara → modelo RData, padrões NetCDF, tabela histórica e SCF.
- Projeção: RData e campos atmosféricos compatíveis → tabela diária de componentes, fase e amplitude.
- Composições: tabela do índice, campos e máscara → NetCDF de médias consideradas significativas.
- Monção: tabela MIRISA e `mpi.1981.2022.nc` com variável `precip` → objetos de eventos, frequências e métricas em memória.

A projeção procura `MCA_SA_20230226.RData`, enquanto a MCA 20230225 grava outra data. As análises de monção usam uma série climatológica 1991-04-01–2021-03-31 que não é gerada pelas versões MCA disponibilizadas.

## Bloqueios a resolver

1. Recuperar funções ausentes e corrigir os caminhos `source()`.
2. Remover a vírgula isolada e o fragmento malformado de `table()` na avaliação de monção; definir objetos usados depois, como `nvalores`.
3. Harmonizar o modelo salvo/carregado e evitar dependência de `save(list=ls())`: salvar modelo e metadados explícitos.
4. Validar calendário, dimensões, grades e ordem OLR/U850/U200 na projeção.
5. Centralizar sinais, fase e normalização; tratar ângulo de 360° para não gerar fase 9.
6. Corrigir unidades dos NetCDF e substituir eixos temporais fictícios por dimensões mode/phase.
7. Tratar ausência de eventos, NA e descontinuidades antes de aplicar rle/lag.
8. Separar estimação, seleção de limiar e validação temporal dos modelos.

`monsoon_active()` retorna sequências de qualquer duração; o filtro ≥3 dias é aplicado posteriormente na análise. As frequências são de **dias pertencentes a eventos**, não de número de eventos. Os modelos efetivamente ajustados usam `glm()`, sem efeitos aleatórios.

Não existe comando Rscript garantido para execução completa no estado atual. Consulte a [avaliação detalhada](../../AVALIACAO_TECNICA.md).
