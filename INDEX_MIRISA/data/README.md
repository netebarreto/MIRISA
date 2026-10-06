# Dados locais

| Pasta | Conteúdo |
| --- | --- |
| raw | NetCDF brutos, incluindo chuva CHIRPS |
| reference | Climatologias, desvios e máscaras |
| intermediate | Anomalias/filtragem/padronização; conservam sufixos de etapas antigas |
| shapes | Shapefiles completos para os mapas |

Dados não são fornecidos pelo clone e estão ignorados no Git. As pastas vazias são mantidas por .gitkeep. Copiar dados da máquina local conforme [MIGRACAO.md](../MIGRACAO.md), sem sobrescrever os originais antes de conferir datas/grades/unidades.

Os sufixos AC01-BTW_ANOM e AC01-BTW_ANOM_R foram mantidos separados para não misturar métodos de filtro. Entradas antigas diretamente em INPUT_NC passam para data, conservando o nome; verificar cada rotina antes de distribuir esses arquivos entre etapas mais específicas.
