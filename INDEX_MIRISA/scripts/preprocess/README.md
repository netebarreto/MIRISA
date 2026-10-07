# Pré-processamento

| Arquivo | Finalidade |
| --- | --- |
| AA01-PROC_anom.sh | Anomalias de OLR/U850/U200, concatenação e padronização |
| AA01-PROC_R_APAD.sh | Desvio de referência, divisão e médias equatoriais |
| processamento_chuva_20260312.sh | Recortes CHIRPS e anomalia padronizada regional |
| AA01.00-Filtro_BTW_NC.R | Filtro histórico seewave::bwfilter, incluindo chuva |
| AA03.00-Filtro_BTW_NC.R | Filtro signal::butter/filtfilt para OLR/ventos |

Entradas organizadas por variável/tratamento em data. Produtos antigos usam historico; climatologias diárias antigas explicitamente datadas permanecem em 1981_2010. Consulta [MIGRACAO.md](../../MIGRACAO.md).

Dependências: Bash/CDO; R com ncdf4, seewave e signal. Os Shell carregam config/paths.sh; R carrega config/paths.R. Diretórios intermediários não são criados implicitamente.

**Pendências preservadas:** cadeia seldate/timstd deve ser revista; referências temporais variam; filtro bilateral e preenchimento OLR por índices fixos exigem validação. Nas rotinas datadas, apenas os caminhos foram alterados. A nova rotina abaixo recorta antes de calcular a referência CDO. Os dois filtros foram mantidos porque não são métodos comprovadamente equivalentes.

A adaptação CHIRPS não reproduz integralmente a configuração ANA/climatologia suavizada descrita por Grimm (2021). A ligação entre teste2.nc e mpi.1981.2022.nc segue pendente.

## Preparar as três referências

Forneça um NetCDF diário contínuo com uma única variável, na grade e unidade desejadas. O script não baixa dados, não muda grades e não converte unidades. Para a chuva, registre versão/variante da base:

```bash
bash scripts/preprocess/gerar_climatologias.sh --variable prec --source chirps --version v3_final_rnl --input data/prec/brutos/chirps/v3_final_rnl/chuva_diaria.nc
bash scripts/preprocess/gerar_climatologias.sh --variable uwnd --source ncep --level 200 --input data/uwnd/brutos/ncep/uwnd_diario.nc --period 1991_2020
```

Sem `--period`, gera as três referências (salvo MIRISA_CLIM_PERIOD definido). `--dry-run` mostra comandos sem executar CDO nem verificar a cobertura. Fora desse modo, todas as referências selecionadas são verificadas antes da escrita: um registro por dia, ordenado, sem lacunas ou duplicatas. A verificação usa calendário gregoriano; não atende calendários 360_day/no_leap. Não verifica cobertura espacial de valores válidos. A média é diária CDO, sem a suavização climatológica do artigo. Conferir tratamento de 29/02 e comparar com a rotina científica validada antes de substituir resultados publicados.

Depois de filtrar as anomalias **de cada referência**, calcule o desvio temporal e a série padronizada, identificando o método:

```bash
bash scripts/preprocess/gerar_climatologias.sh --mode standardize --variable prec --source chirps --version v3_final_rnl --period 1991_2020 --filter-method butterworth_signal --input data/prec/filtrados/chirps/v3_final_rnl/1991_2020/butterworth_signal/anomalias.nc
```

`standardize` aceita apenas um período por execução para evitar reutilizar anomalias de outra referência. CDO aplica `timstd` após `seldate`; a divisão cobre toda a série fornecida. Não inclui médias equatoriais, ajuste MCA ou projeção. Conferir desvios nulos e valores ausentes antes de usar os resultados. Cada referência guarda manifest.json com origem e parâmetros; arquivos existentes bloqueiam execução para evitar sobrescrita. O arquivo de entrada pode abranger mais anos que a referência.
