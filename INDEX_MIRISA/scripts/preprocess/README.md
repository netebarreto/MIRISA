# Pré-processamento

| Arquivo | Finalidade |
| --- | --- |
| AA01-PROC_anom.sh | Anomalias de OLR/U850/U200, concatenação e padronização |
| AA01-PROC_R_APAD.sh | Desvio de referência, divisão e médias equatoriais |
| processamento_chuva_20260312.sh | Recortes CHIRPS e anomalia padronizada regional |
| AA01.00-Filtro_BTW_NC.R | Filtro histórico seewave::bwfilter, incluindo chuva |
| AA03.00-Filtro_BTW_NC.R | Filtro signal::butter/filtfilt para OLR/ventos |

Entradas: data/raw, data/reference e data/intermediate. Algumas entradas antigas diretamente em INPUT_NC foram mapeadas para data, conservando seu nome. Consulta [MIGRACAO.md](../../MIGRACAO.md).

Dependências: Bash/CDO; R com ncdf4, seewave e signal. Os Shell carregam config/paths.sh; R carrega config/paths.R. Diretórios intermediários não são criados implicitamente.

**Pendências preservadas:** cadeia seldate/timstd deve ser revista; referências temporais variam; filtro bilateral e preenchimento OLR por índices fixos exigem validação. Os comandos e os parâmetros científicos não foram alterados nesta organização. Os dois filtros foram mantidos porque não são métodos comprovadamente equivalentes.

A adaptação CHIRPS não reproduz integralmente a configuração ANA/climatologia suavizada descrita por Grimm (2021). A ligação entre teste2.nc e mpi.1981.2022.nc segue pendente.
