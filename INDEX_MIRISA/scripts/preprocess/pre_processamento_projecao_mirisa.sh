#!/usr/bin/env bash
# Configuração apenas de caminhos; comandos científicos preservados.
_mirisa_script_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${_mirisa_script_root}/config/paths.sh" || exit 1

ystart=2020
yend=2025


# OLR 

# Anomalias 

 cdo -s -f nc -ydaysub -seldate,${ystart}"-01-01",${yend}"-12-31" data/olr/brutos/olr.day.mean.v2.fillmiss.nc  data/olr/climatologia/olr.noaa.v2.clima.19910101.20201231.nc  data/olr/anomalias/olr.noaa.v2.anomalia.${ystart}0101.${yend}1231.nc

##### UWND cdo 


mkdir -p anom
# uma ano a mais no inicio e no final para evitar problemas na filtragem 

for i in $(seq ${ystart} ${yend})
do 

 cdo -s -ydaysub -sellevel,850 -ydaymean data/uwnd/brutos/ncep_r1/uwnd.${i}.nc data/uwnd/climatologia/ncep_r1/850hpa/u85.ncep.clima.19910101.20201231.nc anom/u85.anom.${i}.nc


 cdo -s -ydaysub -sellevel,200 -ydaymean data/uwnd/brutos/ncep_r1/uwnd.${i}.nc data/uwnd/climatologia/ncep_r1/200hpa/u20.ncep.clima.19910101.20201231.nc anom/u20.anom.${i}.nc

  echo $i
done

cdo mergetime anom/u20*.nc data/uwnd/anomalias/ncep_r1/200hpa/u20.ncep.anom.${ystart}0101.${yend}1231.nc
cdo mergetime anom/u85*.nc data/uwnd/anomalias/ncep_r1/850hpa/u85.ncep.anom.${ystart}0101.${yend}1231.nc

##### PREC 
##### 


for i in $(seq ${ystart} ${yend})
do 

 cdo -s -ydaysub -sellonlatbox,-82,-34,-50,15 -timfillmiss,method=linear data/prec/brutos/cpc_noaa/precip.${i}.nc data/prec/climatologia/cpc-noaa/precip.sa.cpc-noaa.clima.19910101.20201231.nc anom/precip.anom.${i}.nc

  echo $i
done

cdo mergetime anom/precip*.nc data/prec/anomalias/cpc-noaa/precip.sa.cpc-noaa.anom.${ystart}0101.${yend}1231.nc

rm -r anom

# # # # # # # # # # 

# PROCESSO DE FILTRAGEM NO R


# # ############ Padronizando pelo Desvio PadrãoMI

cdo -s -f nc -mermean -sellonlatbox,0,357.5,-15,15 -div data/uwnd/filtrados/ncep_r1/850hpa/u85.ncep.filtrado.${ystart}0101.${yend}1231.nc data/uwnd/desvio_padrao/ncep_r1/850hpa/u85.ncep.std-filtrado.19910101.20201231.nc data/uwnd/padronizados/ncep_r1/850hpa/u85.ncep.anom_padronizada.${ystart}0101.${yend}1231.nc

# # # # # # # # # # # 
cdo -s -f nc -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep_r1/200hpa/u20.ncep.filtrado.${ystart}0101.${yend}1231.nc  data/uwnd/desvio_padrao/ncep_r1/200hpa/u20.ncep.std-filtrado.19910101.20201231.nc data/uwnd/padronizados/ncep_r1/200hpa/u20.ncep.anom_padronizada.${ystart}0101.${yend}1231.nc
# # # # # # # # # # # 
cdo -s -f nc -mermean -sellonlatbox,0,357.5,-15,15 -div  data/olr/filtrados/olr.noaa.v2.filtrado.${ystart}0101.${yend}1231.nc  data/olr/desvio_padrao/olr.noaa.v2.std-filtrado.19910101.20201231.nc data/olr/padronizados/olr.noaa.v2.anom_padronizada.${ystart}0101.${yend}1231.nc
# # # # # # # # # # # 
cdo -s -f nc -div  data/prec/filtrados/cpc-noaa/precip.sa.cpc-noaa.filtrado.${ystart}0101.${yend}1231.nc  data/prec/desvio_padrao/cpc-noaa/precip.sa.cpc-noaa.std-filtrado.19910101.20201231.nc data/prec/padronizados/cpc-noaa/precip.sa.cpc-noaa.anom_padronizada.${ystart}0101.${yend}1231.nc



####### TESTE de BASE ###### 

cdo -s -f nc -seldate,"2015-01-01","${yend}-12-31" data/prec/padronizados/cpc-noaa/precip.sa.cpc-noaa.anom_padronizada.19910101.${yend}1231.nc data/prec/padronizados/cpc-noaa/precip.sa.cpc-noaa.anom_padronizada.20150101.${yend}1231.nc

cdo -s -f nc -seldate,"2015-01-01","${yend}-12-31" data/olr/padronizados/olr.noaa.v2.anom_padronizada.19910101.${yend}1231.nc data/olr/padronizados/olr.noaa.v2.anom_padronizada.20150101.${yend}1231.nc

cdo -s -f nc -seldate,"2015-01-01","${yend}-12-31" data/uwnd/padronizados/ncep_r1/200hpa/u20.ncep.anom_padronizada.19910101.${yend}1231.nc data/uwnd/padronizados/ncep_r1/200hpa/u20.ncep.anom_padronizada.20150101.${yend}1231.nc

cdo -s -f nc -seldate,"2015-01-01","${yend}-12-31" data/uwnd/padronizados/ncep_r1/850hpa/u85.ncep.anom_padronizada.19910101.${yend}1231.nc data/uwnd/padronizados/ncep_r1/850hpa/u85.ncep.anom_padronizada.20150101.${yend}1231.nc
