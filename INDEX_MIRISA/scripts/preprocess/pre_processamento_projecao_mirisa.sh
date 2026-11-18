#!/usr/bin/env bash
# Configuração apenas de caminhos; comandos científicos preservados.
_mirisa_script_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${_mirisa_script_root}/config/paths.sh" || exit 1


# OLR 

# Anomalias 

 cdo -s -f nc -ydaysub -seldate,"2020-01-01","2025-12-31" data/olr/brutos/olr.day.mean.v2.fillmiss.nc  data/olr/climatologia/olr.noaa.v2.clima.19910101.20201231.nc  data/olr/anomalias/olr.noaa.v2.anomalia.20200101.20251231.nc

##### UWND cdo 


mkdir -p anom
# uma ano a mais no inicio e no final para evitar problemas na filtragem 

for i in $(seq 2020 2025)
do 

 cdo -s -ydaysub -sellevel,850 -ydaymean data/uwnd/brutos/ncep_r1/uwnd.${i}.nc data/uwnd/brutos/ncep/850hpa/u85.ncep.clima.19910101.20201231.nc anom/u85.anom.${i}.nc


 cdo -s -ydaysub -sellevel,200 -ydaymean data/uwnd/brutos/ncep_r1/uwnd.${i}.nc data/uwnd/brutos/ncep/200hpa/u20.ncep.clima.19910101.20201231.nc anom/u20.anom.${i}.nc

  echo $i
done

cdo mergetime anom/u20*.nc uwnd/anomalias/ncep/200hpa/u20.ncep.anom.20200101.20251231.nc
cdo mergetime anom/u85*.nc uwnd/anomalias/ncep/850hpa/u85.ncep.anom.20200101.20251231.nc

##### PREC 
##### 


# mkdir -p anom clim2 clim3
# uma ano a mais no inicio e no final para evitar problemas na filtragem 


for i in $(seq 2020 2025)
do 

 cdo -s -ydaysub -sellonlatbox,-82,-34,-50,15 data/prec/brutos/cpc_noaa/precip.${i}.nc data/prec/climatologia/cpc/precip.sa.cpc-noaa.clima.19910101.20201231.nc anom/precip.anom.${i}.nc

  echo $i
done


cdo mergetime anom/precip*.nc data/prec/anomalias/cpc/precip.sa.cpc-noaa.anom.202000101.20251231.nc

########## 


# # ############

cdo -s -f nc -seldate,1981-01-01,2010-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/850hpa/u85.ncep.filtrado.19800101.20111231.nc  data/uwnd/desvio_padrao/ncep/850hpa/u85.ncep.std-filtrado.19810101.20101231.nc data/uwnd/padronizados/ncep/850hpa/u85.ncep.anom_padronizada.19810101.20101231.nc

cdo -s -f nc -seldate,1981-01-01,2020-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/850hpa/u85.ncep.filtrado.19800101.20211231.nc  data/uwnd/desvio_padrao/ncep/850hpa/u85.ncep.std-filtrado.19810101.20201231.nc data/uwnd/padronizados/ncep/850hpa/u85.ncep.anom_padronizada.19810101.20201231.nc

cdo -s -f nc -seldate,1991-01-01,2020-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/850hpa/u85.ncep.filtrado.19900101.20211231.nc  data/uwnd/desvio_padrao/ncep/850hpa/u85.ncep.std-filtrado.19910101.20201231.nc data/uwnd/padronizados/ncep/850hpa/u85.ncep.anom_padronizada.19910101.20201231.nc



cdo -s -f nc -seldate,1981-01-01,2010-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/200hpa/u20.ncep.filtrado.19800101.20111231.nc  data/uwnd/desvio_padrao/ncep/200hpa/u20.ncep.std-filtrado.19810101.20101231.nc data/uwnd/padronizados/ncep/200hpa/u20.ncep.anom_padronizada.19810101.20101231.nc

cdo -s -f nc -seldate,1981-01-01,2020-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/200hpa/u20.ncep.filtrado.19800101.20211231.nc  data/uwnd/desvio_padrao/ncep/200hpa/u20.ncep.std-filtrado.19810101.20201231.nc data/uwnd/padronizados/ncep/200hpa/u20.ncep.anom_padronizada.19810101.20201231.nc

cdo -s -f nc -seldate,1991-01-01,2020-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/200hpa/u20.ncep.filtrado.19900101.20211231.nc  data/uwnd/desvio_padrao/ncep/200hpa/u20.ncep.std-filtrado.19910101.20201231.nc data/uwnd/padronizados/ncep/200hpa/u20.ncep.anom_padronizada.19910101.20201231.nc

########### 




cdo -s -f nc -seldate,1981-01-01,2010-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/olr/filtrados/olr.noaa.v2.filtrado.19800101.20111231.nc  data/olr/desvio_padra/olr.noaa.v2.std-filtrado.19810101.20101231.nc data/olr/padronizados/olr.noaa.v2.anom_padronizada.19810101.20101231.nc

cdo -s -b F32 -seldate,1981-01-01,2020-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/olr/filtrados/olr.noaa.v2.filtrado.19800101.20211231.nc  data/olr/desvio_padrao/olr.noaa.v2.std-filtrado.19810101.20201231.nc data/olr/padronizados/olr.noaa.v2.anom_padronizada.19810101.20201231.nc

cdo -s -b F32 -seldate,1991-01-01,2020-12-31 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/olr/filtrados/olr.noaa.v2.filtrado.19900101.20211231.nc  data/olr/desvio_padrao/olr.noaa.v2.std-filtrado.19910101.20201231.nc data/olr/padronizados/olr.noaa.v2.anom_padronizada.19910101.20201231.nc



cdo -s -f nc -seldate,1981-01-01,2010-12-31 -div  filtrados/precip.sa.cpc-noaa.filtrado.19800101.20111231.nc  filtrados/precip.sa.cpc-noaa.std-filtrado.19810101.20101231.nc anom_padronizada/precip.sa.cpc-noaa.anom_padronizada.19810101.20101231.nc

cdo -s -f nc -seldate,1981-01-01,2020-12-31 -div  filtrados/precip.sa.cpc-noaa.filtrado.19800101.20211231.nc  filtrados/precip.sa.cpc-noaa.std-filtrado.19810101.20201231.nc anom_padronizada/precip.sa.cpc-noaa.anom_padronizada.19810101.20201231.nc

cdo -s -f nc -seldate,1991-01-01,2020-12-31 -div  filtrados/precip.sa.cpc-noaa.filtrado.19900101.20211231.nc  filtrados/precip.sa.cpc-noaa.std-filtrado.19910101.20201231.nc anom_padronizada/precip.sa.cpc-noaa.anom_padronizada.19910101.20201231.nc



########## --------------------------------------

##### VWND 

# CLIMA 
cdo -ydaymean -sellevel,200 -mergetime data/vwnd/brutos/ncep/vwnd.{1981..2010}.nc  data/vwnd/climatologia/ncep/200hpa/v20.ncep.clima.19810101.20101231.nc 

cdo -ydaymean -sellevel,850 -mergetime data/vwnd/brutos/ncep/vwnd.{1981..2010}.nc  data/vwnd/climatologia/ncep/850hpa/v85.ncep.clima.19810101.20101231.nc 

cdo -ydaymean -sellevel,200 -mergetime data/vwnd/brutos/ncep/vwnd.{1981..2020}.nc  data/vwnd/climatologia/ncep/200hpa/v20.ncep.clima.19810101.20201231.nc 

cdo -ydaymean -sellevel,850 -mergetime data/vwnd/brutos/ncep/vwnd.{1981..2020}.nc  data/vwnd/climatologia/ncep/850hpa/v85.ncep.clima.19810101.20201231.nc 


cdo -ydaymean -sellevel,200 -mergetime data/vwnd/brutos/ncep/vwnd.{1981..2020}.nc  data/vwnd/climatologia/ncep/200hpa/v20.ncep.clima.19910101.20201231.nc 

cdo -ydaymean -sellevel,850 -mergetime data/vwnd/brutos/ncep/vwnd.{1981..2020}.nc  data/vwnd/climatologia/ncep/850hpa/v85.ncep.clima.19910101.20201231.nc 


mkdir -p clim1 clim2 clim3
# uma ano a mais no inicio e no final para evitar problemas na filtragem 

for i in $(seq 1980 2011)
do 

 cdo -s -ydaysub -sellevel,850 -ydaymean data/vwnd/brutos/ncep/vwnd.${i}.nc data/vwnd/climatologia/ncep/850hpa/v85.ncep.clima.19810101.20101231.nc clim1/v85.anom.${i}.nc


 cdo -s -ydaysub -sellevel,200 -ydaymean data/vwnd/brutos/ncep/vwnd.${i}.nc data/vwnd/climatologia/ncep/200hpa/v20.ncep.clima.19810101.20101231.nc clim1/v20.anom.${i}.nc

  echo $i
done



for i in $(seq 1990 2021)
do 


 cdo -s -ydaysub -sellevel,850 -ydaymean data/vwnd/brutos/ncep/vwnd.${i}.nc data/vwnd/climatologia/ncep/850hpa/v85.ncep.clima.19810101.20201231.nc clim2/v85.anom.${i}.nc


 cdo -s -ydaysub -sellevel,200 -ydaymean data/vwnd/brutos/ncep/vwnd.${i}.nc data/vwnd/climatologia/ncep/200hpa/v20.ncep.clima.19810101.20201231.nc clim2/v20.anom.${i}.nc

  echo $i
done



for i in $(seq 1980 2021)
do 

 cdo -s -ydaysub -sellevel,850 -ydaymean data/vwnd/brutos/ncep/vwnd.${i}.nc data/vwnd/climatologia/ncep/850hpa/v85.ncep.clima.19810101.20201231.nc clim3/v85.anom.${i}.nc


 cdo -s -ydaysub -sellevel,200 -ydaymean data/vwnd/brutos/ncep/vwnd.${i}.nc data/vwnd/climatologia/ncep/200hpa/v20.ncep.clima.19810101.20201231.nc clim3/v20.anom.${i}.nc

  echo $i
done


cdo mergetime clim1/v20*.nc v20.ncep.anom.19800101.20111231.nc
cdo mergetime clim1/v85*.nc v85.ncep.anom.19800101.20111231.nc


cdo mergetime clim2/v20*.nc v20.ncep.anom.19900101.20211231.nc
cdo mergetime clim2/v85*.nc v85.ncep.anom.19900101.20211231.nc

cdo mergetime clim3/v20*.nc v20.ncep.anom.19800101.20211231.nc
cdo mergetime clim3/v85*.nc v85.ncep.anom.19800101.20211231.nc




##### BESM 

cdo -s -f nc -mermean -sellonlatbox,0,357.5,-15,15 -div  data/besm/filtrados/u20.besm.filtrados.19930101.20231231.nc  data/besm/desvio_padrao/u20.besm.desvio_padrao.1993.2023.nc data/besm/padronizados/u20.besm.anom_padronizada.19930101.20231231.nc

cdo -s -f nc -mermean -sellonlatbox,0,357.5,-15,15 -div  data/besm/filtrados/u85.besm.filtrados.19930101.20231231.nc  data/besm/desvio_padrao/u85.besm.desvio_padrao.1993.2023.nc data/besm/padronizados/u85.besm.anom_padronizada.19930101.20231231.nc

cdo -s -f nc -mermean -sellonlatbox,0,357.5,-15,15 -div  data/besm/filtrados/olr.besm.filtrados.19930101.20231231.nc  data/besm/desvio_padrao/olr.besm.desvio_padrao.1993.2023.nc data/besm/padronizados/olr.besm.anom_padronizada.19930101.20231231.nc

cdo -s -f nc -remapbil,data/prec/desvio_padrao/cpc/precip.sa.cpc-noaa.std-filtrado.19810101.20101231.nc -div  data/besm/filtrados/prec.besm.filtrados.19930101.20231231.nc  data/besm/desvio_padrao/prec.besm.desvio_padrao.1993.2023.nc data/besm/padronizados/prec.besm.anom_padronizada.19930101.20231231.nc

