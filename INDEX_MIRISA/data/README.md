# Dados por variável e tratamento

O primeiro nível identifica a variável: `prec` (chuva), `uwnd` (vento zonal), `vwnd` (vento meridional) e `olr`. Máscaras e shapefiles ficam em `static`.

| Tratamento | Conteúdo |
| --- | --- |
| brutos | Arquivos originais, sem dependência de período climatológico |
| recortados | Recortes espaciais; preservam a série original |
| climatologia | Média diária do período de referência |
| anomalias | Série menos a climatologia diária |
| filtrados | Anomalias filtradas; método identificado em subpasta |
| desvio_padrao | Referência de dispersão; identificar série/método usado |
| padronizados | Anomalias filtradas divididas pelo desvio de referência |

Convenção: `data/<variável>/<tratamento>/<fonte>/<versão-variante se aplicável>/<nível se aplicável>/<período>/<método se aplicável>/<arquivo>`.

Exemplos:

```
data/prec/brutos/chirps/v3_final_rnl/chuva_diaria.nc
data/prec/anomalias/chirps/v3_final_rnl/1991_2020/anomalias.nc
data/uwnd/climatologia/ncep/200hpa/1981_2010/media_diaria.nc
data/olr/filtrados/v01r02/1981_2020/butterworth_signal/anomalias.nc
data/static/masks/AS.mask.20161231.nc
```

Os períodos são anos civis completos: `1981_2010`, `1991_2020`, `1981_2020`. A cobertura temporal da série continua no nome/manifesto do arquivo e não é o período climatológico. `VERSAO_VARIANTE` é um marcador: substitua pela versão real (por exemplo `v3_final_rnl`). Não misture CHIRPS v2/v3, preliminar/final, variantes diárias, versões MSWEP ou IMERG Early/Late/Final. A existência da pasta IMERG não significa disponibilidade desde 1981: o processamento recusa referência sem cobertura diária completa.

`historico` guarda os produtos das rotinas anteriores. Essas rotinas ainda usam datas próprias e referências distintas; seus resultados não são automaticamente recalculados pela escolha dos três períodos. Os métodos de filtro antigos continuam separados. Consulte [a migração](../MIGRACAO.md) para transferir os dados locais.

Use [gerar_climatologias.sh](../scripts/preprocess/gerar_climatologias.sh) para produzir médias diárias e anomalias nos três períodos. Dados volumosos ficam fora do Git. O clone fornece a estrutura e os contratos, não os NetCDF.
