# Mapa de migração

Branch organiza-index-mirisa, baseada no commit beb2c381d69fb3c46195c8d35cb074b5ab95266b. Escopo: INDEX_MIRISA. E01_FILTRAGEM, gitlink MIRISA e README da raiz do repositório foram preservados.

## Código e arquivos existentes

Os 39 arquivos científicos/auxiliares existentes foram destinados a novos caminhos; nenhum foi descartado. Sete READMEs antigos foram substituídos por documentação da estrutura atual. A avaliação técnica foi preservada com uma nota de migração.

| Caminho anterior | Novo caminho | Tratamento |
| --- | --- | --- |
| `AA02-SCRIPTS/GRADS/cbarn.gs` | `scripts/functions/GRADS/cbarn.gs` | Conteúdo original preservado |
| `AA02-SCRIPTS/GRADS/mapas_comp.gs` | `scripts/plots/mapas_comp.gs` | Somente caminhos/configuração |
| `AA02-SCRIPTS/PYTHON/AA03-Aspectos_Climatologicos_MIRISA.ipynb` | `scripts/analysis/AA03-Aspectos_Climatologicos_MIRISA.ipynb` | Somente caminhos/configuração |
| `AA02-SCRIPTS/PYTHON/Artigo1_MIRISA_Fig3a9.ipynb` | `experiments/prototypes/PYTHON/Artigo1_MIRISA_Fig3a9.ipynb` | Conteúdo original preservado |
| `AA02-SCRIPTS/PYTHON/DIAGRAM_PSPACE_MIRISA_20230501.py` | `scripts/plots/DIAGRAM_PSPACE_MIRISA_20230501.py` | Somente caminhos/configuração |
| `AA02-SCRIPTS/PYTHON/MCA_PLOT.py` | `scripts/plots/MCA_PLOT.py` | Somente caminhos/configuração |
| `AA02-SCRIPTS/PYTHON/btw_py.csv` | `experiments/fixtures/btw_py.csv` | Conteúdo original preservado |
| `AA02-SCRIPTS/PYTHON/diagram_space_phase.py` | `experiments/legacy/PYTHON/diagram_space_phase.py` | Conteúdo original preservado |
| `AA02-SCRIPTS/PYTHON/diagram_space_phase_20230429.py` | `experiments/legacy/PYTHON/diagram_space_phase_20230429.py` | Conteúdo original preservado |
| `AA02-SCRIPTS/PYTHON/filtro_butterworph.py` | `experiments/prototypes/PYTHON/filtro_butterworph.py` | Conteúdo original preservado |
| `AA02-SCRIPTS/PYTHON/teste.csv` | `experiments/fixtures/teste.csv` | Conteúdo original preservado |
| `AA02-SCRIPTS/PYTHON/teste_DP.py` | `experiments/legacy/PYTHON/teste_DP.py` | Conteúdo original preservado |
| `AA02-SCRIPTS/R/AA00-Functions/Documento Sem Título 1` | `experiments/prototypes/R/rascunho_logistica_sem_titulo.R` | Conteúdo original preservado |
| `AA02-SCRIPTS/R/AA00-Functions/anomaly.R` | `scripts/functions/R/anomaly.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/AA00-Functions/semanas.i.R` | `scripts/functions/R/semanas.i.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/AA01.00-Filtro_BTW_NC.R` | `scripts/preprocess/AA01.00-Filtro_BTW_NC.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/AA01.00-MCA_TwoDatasets_20230220.R` | `experiments/legacy/R/AA01.00-MCA_TwoDatasets_20230220.R` | Conteúdo original preservado |
| `AA02-SCRIPTS/R/AA01.00-MCA_TwoDatasets_20230225.R` | `scripts/index/AA01.00-MCA_TwoDatasets_20230225.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/AA02.00-COMPOSICAO_FASES_MIRI_20211203.R` | `experiments/legacy/R/AA02.00-COMPOSICAO_FASES_MIRI_20211203.R` | Conteúdo original preservado |
| `AA02-SCRIPTS/R/AA02.00-COMPOSICAO_FASES_MIRI_20260321.R` | `scripts/analysis/AA02.00-COMPOSICAO_FASES_MIRI_20260321.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/AA03.00-Filtro_BTW_NC.R` | `scripts/preprocess/AA03.00-Filtro_BTW_NC.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/AA03.00-MIRISA_PROJECAO_20230223.R` | `scripts/index/AA03.00-MIRISA_PROJECAO_20230223.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/AA04_Comparacao_MIRISA.R` | `scripts/analysis/AA04_Comparacao_MIRISA.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/AB01.01- MIRISA_FORECAST_MVAR` | `experiments/prototypes/R/AB01.01- MIRISA_FORECAST_MVAR` | Conteúdo original preservado |
| `AA02-SCRIPTS/R/AB01.01- MIRISA_FORECAST_MVAR.R` | `experiments/prototypes/R/AB01.01- MIRISA_FORECAST_MVAR.R` | Conteúdo original preservado |
| `AA02-SCRIPTS/R/Avaliação_Break_Active_Monsoon_20260321.r` | `scripts/analysis/Avaliação_Break_Active_Monsoon_20260321.r` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/Avaliação_FasesxChuva_20260321.r` | `scripts/analysis/Avaliação_FasesxChuva_20260321.r` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/Function_Data_nc_convert_20260320.R` | `scripts/functions/R/Function_Data_nc_convert_20260320.R` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/Function_monsoon_atividade_20260322.r` | `scripts/functions/R/Function_monsoon_atividade_20260322.r` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/cov4gappy.r` | `scripts/functions/R/cov4gappy.r` | Somente caminhos/configuração |
| `AA02-SCRIPTS/R/filtro.R` | `experiments/prototypes/R/filtro.R` | Conteúdo original preservado |
| `AA02-SCRIPTS/R/model_active_break_spell.r` | `experiments/prototypes/R/model_active_break_spell.r` | Conteúdo original preservado |
| `AA02-SCRIPTS/SH/AA01-PROC_R_APAD.sh` | `scripts/preprocess/AA01-PROC_R_APAD.sh` | Somente caminhos/configuração |
| `AA02-SCRIPTS/SH/AA01-PROC_anom.sh` | `scripts/preprocess/AA01-PROC_anom.sh` | Somente caminhos/configuração |
| `AA02-SCRIPTS/SH/processamento_chuva_20260312.sh` | `scripts/preprocess/processamento_chuva_20260312.sh` | Somente caminhos/configuração |
| `AA02-SCRIPTS/Untitled-1.r` | `experiments/prototypes/R/rascunho_onset_demise.R` | Conteúdo original preservado |

| `AA02-SCRIPTS/PYTHON/MIRISA_amplitude_climatology_19910401_20210331.png` | `outputs/examples/MIRISA_amplitude_climatology_19910401_20210331.png` | Conteúdo original preservado |
| `AA02-SCRIPTS/PYTHON/MIRISA_phase_amplitude_seasonal_polar.png` | `outputs/examples/MIRISA_phase_amplitude_seasonal_polar.png` | Conteúdo original preservado |
| `AA02-SCRIPTS/PYTHON/MIRISA_seasonal_phase_amplitude.png` | `outputs/examples/MIRISA_seasonal_phase_amplitude.png` | Conteúdo original preservado |

## Dados da máquina local

Todos os caminhos seguintes são relativos à raiz INDEX_MIRISA. As pastas de dados não existiam no Git; esta tabela orienta cópia local, não comprova que os dados foram migrados.

| Caminho antigo | Destino |
| --- | --- |
| INPUT_NC/AA00-REF_NC, AA00-NC_INPUT/AA00-REF_NC ou AA01-NC_INPUT/AA00-REF_NC | data/reference, mantendo subpastas CLIM e STD_R |
| AA01-NC_INPUT/AA00-NC_BRUTOS e equivalentes | data/raw |
| AB00-ANOM_YEAR, AB01-NOF_ANOM, AC01-BTW_ANOM, AC01-BTW_ANOM_R, AC02-BTW_APAD_R ou AB02-BTW_ANOM dentro das raízes antigas | data/intermediate/<nome da etapa> |
| Arquivos diretamente em INPUT_NC | data/<nome original> |
| AA03-RData_TxT / AA03-RData_txt: arquivos texto | outputs/tables |
| AA03-RData_TxT / AA03-RData_txt: arquivos RData | outputs/models |
| AA03-NC_OUTPUT, incluindo PHASES | outputs/netcdf |
| AA04-FIG | outputs/figures |
| AA00-SHP | data/shapes |
| GLOBAL_P25 | data/raw/chirps/GLOBAL_P25 |
| chirps-v2.0.SA.*.nc recortados | data/intermediate/chirps |
| rain.mpiarea.*.nc, teste2.nc e teste2a.nc | outputs/netcdf |

Não juntar automaticamente as antigas raízes de dados se contiverem arquivos de mesmo nome com conteúdo diferente. Verificar origem, método, período, calendário, grade e checksum antes de copiar. Os sufixos que distinguem filtros foram preservados.

## Mudanças e pendências

- Funções R chamadas por source apontam para scripts/functions/R; cov4gappy usa o nome minúsculo existente.
- Caminhos Windows fixos foram retirados das rotinas candidatas e os caminhos de produto/dados foram harmonizados.
- O notebook climatológico recebeu uma célula de configuração e saídas foram limpas; suas figuras antigas permanecem em outputs/examples.
- Fórmulas, parâmetros de filtro, sinais, seleção de fases, regras de eventos e modelos estatísticos foram preservados.
- Arquivos de experiments mantêm caminhos históricos e conteúdo original; não são comandos executáveis da nova organização.
- Cinco funções ausentes, divergência de datas dos modelos, erro de sintaxe R e demais pendências da avaliação continuam existentes.

## Clonar e revisar

```bash
git clone --branch organiza-index-mirisa --single-branch https://github.com/netebarreto/MIRISA.git MIRISA_organizado
cd MIRISA_organizado/INDEX_MIRISA
```

Clonar numa pasta nova, copiar os dados conforme o mapa e validar etapas individualmente. A organização não foi incorporada automaticamente à main.


## Atualização: dados por variável e tratamento

Os caminhos abaixo substituem os caminhos da organização anterior. Os arquivos locais não estão no Git; copie-os para os destinos indicados. `historico` identifica produtos antigos cuja referência é mista ou ainda precisa ser confirmada. Não renomeie esses arquivos como um dos novos períodos sem recalculá-los.

| Caminho anterior | Destino atual |
| --- | --- |
| `data/intermediate/AB00-ANOM_YEAR/olr/olr.anom.${i}.nc` | `data/olr/anomalias/v01r02/historico/anuais/olr.anom.${i}.nc` |
| `data/intermediate/AB00-ANOM_YEAR/olr/olr.anom.20*.nc` | `data/olr/anomalias/v01r02/historico/anuais/olr.anom.20*.nc` |
| `data/intermediate/AB00-ANOM_YEAR/u20/u20.anom.${i}.nc` | `data/uwnd/anomalias/ncep/200hpa/historico/anuais/u20.anom.${i}.nc` |
| `data/intermediate/AB00-ANOM_YEAR/u20/u20.anom.20*.nc` | `data/uwnd/anomalias/ncep/200hpa/historico/anuais/u20.anom.20*.nc` |
| `data/intermediate/AB00-ANOM_YEAR/u85/u85.anom.${i}.nc` | `data/uwnd/anomalias/ncep/850hpa/historico/anuais/u85.anom.${i}.nc` |
| `data/intermediate/AB00-ANOM_YEAR/u85/u85.anom.20*.nc` | `data/uwnd/anomalias/ncep/850hpa/historico/anuais/u85.anom.20*.nc` |
| `data/intermediate/AB01-NOF_ANOM/olr.anom.daily.v01r02.20180101.20260307.nc` | `data/olr/anomalias/v01r02/historico/olr.anom.daily.v01r02.20180101.20260307.nc` |
| `data/intermediate/AB01-NOF_ANOM/u20.anom.daily.ncep.20180101.20260307.nc` | `data/uwnd/anomalias/ncep/200hpa/historico/u20.anom.daily.ncep.20180101.20260307.nc` |
| `data/intermediate/AB01-NOF_ANOM/u85.anom.daily.ncep.20180101.20260307.nc` | `data/uwnd/anomalias/ncep/850hpa/historico/u85.anom.daily.ncep.20180101.20260307.nc` |
| `data/intermediate/AB02-BTW_ANOM/v85.abtw.daily.ncep.19810101.20201231.nc` | `data/vwnd/filtrados/ncep/850hpa/historico/butterworth_legado/v85.abtw.daily.ncep.19810101.20201231.nc` |
| `data/intermediate/AC01-BTW_ANOM/olr.abtw.daily.v01r02.19910301.20211231.nc` | `data/olr/filtrados/v01r02/historico/butterworth_signal/olr.abtw.daily.v01r02.19910301.20211231.nc` |
| `data/intermediate/AC01-BTW_ANOM/olr.abtw.daily.v01r02.20180101.20250907.nc` | `data/olr/filtrados/v01r02/historico/butterworth_signal/olr.abtw.daily.v01r02.20180101.20250907.nc` |
| `data/intermediate/AC01-BTW_ANOM/olr.abtw.daily.v01r02.20180101.20260307.nc` | `data/olr/filtrados/v01r02/historico/butterworth_signal/olr.abtw.daily.v01r02.20180101.20260307.nc` |
| `data/intermediate/AC01-BTW_ANOM/prec/apreci.AMS.day.btw.19820101.20161231.nc` | `data/prec/filtrados/cpc/historico/butterworth_signal/apreci.AMS.day.btw.19820101.20161231.nc` |
| `data/intermediate/AC01-BTW_ANOM/u20.abtw.daily.ncep.20180101.20250907.nc` | `data/uwnd/filtrados/ncep/200hpa/historico/butterworth_signal/u20.abtw.daily.ncep.20180101.20250907.nc` |
| `data/intermediate/AC01-BTW_ANOM/u20.abtw.daily.ncep.20180101.20260307.nc` | `data/uwnd/filtrados/ncep/200hpa/historico/butterworth_signal/u20.abtw.daily.ncep.20180101.20260307.nc` |
| `data/intermediate/AC01-BTW_ANOM/u85.abtw.daily.ncep.20180101.20250907.nc` | `data/uwnd/filtrados/ncep/850hpa/historico/butterworth_signal/u85.abtw.daily.ncep.20180101.20250907.nc` |
| `data/intermediate/AC01-BTW_ANOM/u85.abtw.daily.ncep.20180101.20260307.nc` | `data/uwnd/filtrados/ncep/850hpa/historico/butterworth_signal/u85.abtw.daily.ncep.20180101.20260307.nc` |
| `data/intermediate/AC01-BTW_ANOM_R/olr.abtw.daily.v01r02.19910301.20201231.nc` | `data/olr/filtrados/v01r02/historico/butterworth_seewave/olr.abtw.daily.v01r02.19910301.20201231.nc` |
| `data/intermediate/AC01-BTW_ANOM_R/prec.AMS.abtw.daily.cpc.19910301.20210628.nc` | `data/prec/filtrados/cpc/historico/butterworth_seewave/prec.AMS.abtw.daily.cpc.19910301.20210628.nc` |
| `data/intermediate/AC01-BTW_ANOM_R/u20.abtw.daily.ncep.19910301.20210628.nc` | `data/uwnd/filtrados/ncep/200hpa/historico/butterworth_seewave/u20.abtw.daily.ncep.19910301.20210628.nc` |
| `data/intermediate/AC01-BTW_ANOM_R/u85.abtw.daily.ncep.19910301.20210628.nc` | `data/uwnd/filtrados/ncep/850hpa/historico/butterworth_seewave/u85.abtw.daily.ncep.19910301.20210628.nc` |
| `data/intermediate/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.19910301.20200228.nc` | `data/olr/padronizados/v01r02/historico/olr.apad.mca.daily.v01r02.19910301.20200228.nc` |
| `data/intermediate/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.20180101.20250907.nc` | `data/olr/padronizados/v01r02/historico/olr.apad.mca.daily.v01r02.20180101.20250907.nc` |
| `data/intermediate/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.20180101.20260307.nc` | `data/olr/padronizados/v01r02/historico/olr.apad.mca.daily.v01r02.20180101.20260307.nc` |
| `data/intermediate/AC02-BTW_APAD_R/prec.AMS.apad.mca.daily.cpc.19910301.20200228.nc` | `data/prec/padronizados/cpc/historico/prec.AMS.apad.mca.daily.cpc.19910301.20200228.nc` |
| `data/intermediate/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.19910301.20200228.nc` | `data/uwnd/padronizados/ncep/200hpa/historico/u20.apad.mca.daily.ncep.19910301.20200228.nc` |
| `data/intermediate/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.20180101.20250907.nc` | `data/uwnd/padronizados/ncep/200hpa/historico/u20.apad.mca.daily.ncep.20180101.20250907.nc` |
| `data/intermediate/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.20180101.20260307.nc` | `data/uwnd/padronizados/ncep/200hpa/historico/u20.apad.mca.daily.ncep.20180101.20260307.nc` |
| `data/intermediate/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.19910301.20200228.nc` | `data/uwnd/padronizados/ncep/850hpa/historico/u85.apad.mca.daily.ncep.19910301.20200228.nc` |
| `data/intermediate/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.20180101.20250907.nc` | `data/uwnd/padronizados/ncep/850hpa/historico/u85.apad.mca.daily.ncep.20180101.20250907.nc` |
| `data/intermediate/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.20180101.20260307.nc` | `data/uwnd/padronizados/ncep/850hpa/historico/u85.apad.mca.daily.ncep.20180101.20260307.nc` |
| `data/intermediate/chirps/chirps-v2.0.SA.19810101.20221231.days_p25.nc` | `data/prec/recortados/chirps/v2/chirps-v2.0.SA.19810101.20221231.days_p25.nc` |
| `data/intermediate/chirps/chirps-v2.0.SA.20240101.20241231.days_p25.nc` | `data/prec/recortados/chirps/v2/chirps-v2.0.SA.20240101.20241231.days_p25.nc` |
| `data/intermediate/chirps/chirps-v2.0.SA.20250101.20251231.days_p25.nc` | `data/prec/recortados/chirps/v2/chirps-v2.0.SA.20250101.20251231.days_p25.nc` |
| `data/intermediate/chirps/chirps-v2.0.SA.20260101.20260305.days_p25.nc` | `data/prec/recortados/chirps/v2/chirps-v2.0.SA.20260101.20260305.days_p25.nc` |
| `data/olr.anom.daily.v01r02.19910301.20211231.nc` | `data/olr/anomalias/v01r02/historico/olr.anom.daily.v01r02.19910301.20211231.nc` |
| `data/prec.AMS.anom.daily.cpc.199110301.20210628.nc` | `data/prec/anomalias/cpc/historico/prec.AMS.anom.daily.cpc.199110301.20210628.nc` |
| `data/raw/chirps/GLOBAL_P25/Pre_2026/chirps-v2.0.2026.02.days_p25.nc` | `data/prec/brutos/chirps/v2/GLOBAL_P25/Pre_2026/chirps-v2.0.2026.02.days_p25.nc` |
| `data/raw/chirps/GLOBAL_P25/Pre_2026/chirps-v2.0.2026.03.days_p25.nc` | `data/prec/brutos/chirps/v2/GLOBAL_P25/Pre_2026/chirps-v2.0.2026.03.days_p25.nc` |
| `data/raw/chirps/GLOBAL_P25/chirps-v2.0.2024.days_p25.nc` | `data/prec/brutos/chirps/v2/GLOBAL_P25/chirps-v2.0.2024.days_p25.nc` |
| `data/raw/chirps/GLOBAL_P25/chirps-v2.0.2025.days_p25.nc` | `data/prec/brutos/chirps/v2/GLOBAL_P25/chirps-v2.0.2025.days_p25.nc` |
| `data/raw/chirps/GLOBAL_P25/chirps-v2.0.2026.days_p25.nc` | `data/prec/brutos/chirps/v2/GLOBAL_P25/chirps-v2.0.2026.days_p25.nc` |
| `data/raw/chirps/GLOBAL_P25/chirps-v2.0.prelim.2026.days_p25.nc` | `data/prec/brutos/chirps/v2/GLOBAL_P25/chirps-v2.0.prelim.2026.days_p25.nc` |
| `data/raw/olr/olr.${i}.nc` | `data/olr/brutos/v01r02/olr.${i}.nc` |
| `data/raw/uwind/uwnd.${i}.nc` | `data/uwnd/brutos/ncep/uwnd.${i}.nc` |
| `data/reference/AS.mask.20161231.nc` | `data/static/masks/AS.mask.20161231.nc` |
| `data/reference/CLIM/olr.dayclim.v01r02.19810101.20101231.nc` | `data/olr/climatologia/v01r02/1981_2010/olr.dayclim.v01r02.19810101.20101231.nc` |
| `data/reference/CLIM/u20.dayclim.19810101.20101231.nc` | `data/uwnd/climatologia/ncep/200hpa/1981_2010/u20.dayclim.19810101.20101231.nc` |
| `data/reference/CLIM/u85.dayclim.19810101.20101231.nc` | `data/uwnd/climatologia/ncep/850hpa/1981_2010/u85.dayclim.19810101.20101231.nc` |
| `data/reference/STD_R/olr.std.daily.v01r02.cpc.1991.2020.nc` | `data/olr/desvio_padrao/v01r02/historico/butterworth_seewave/olr.std.daily.v01r02.cpc.1991.2020.nc` |
| `data/reference/STD_R/prec.AMS.std.abtw.daily.cpc.1991.2020.nc` | `data/prec/desvio_padrao/cpc/historico/butterworth_seewave/prec.AMS.std.abtw.daily.cpc.1991.2020.nc` |
| `data/reference/STD_R/u20.std.abtw.daily.ncep.1991.2020.nc` | `data/uwnd/desvio_padrao/ncep/200hpa/historico/butterworth_seewave/u20.std.abtw.daily.ncep.1991.2020.nc` |
| `data/reference/STD_R/u85.std.abtw.daily.ncep.1991.2020.nc` | `data/uwnd/desvio_padrao/ncep/850hpa/historico/butterworth_seewave/u85.std.abtw.daily.ncep.1991.2020.nc` |
| `data/shapes/gadm36_BRA_1.shp` | `data/static/shapes/gadm36_BRA_1.shp` |
| `data/u20.anom.daily.ncep.19910301.20210228.nc` | `data/uwnd/anomalias/ncep/200hpa/historico/u20.anom.daily.ncep.19910301.20210228.nc` |
| `data/u85.anom.daily.ncep.19910301.20210228.nc` | `data/uwnd/anomalias/ncep/850hpa/historico/u85.anom.daily.ncep.19910301.20210228.nc` |
