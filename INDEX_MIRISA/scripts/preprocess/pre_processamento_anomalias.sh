#!/usr/bin/env bash
# Configuração apenas de caminhos; comandos científicos preservados.
_mirisa_script_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${_mirisa_script_root}/config/paths.sh" || exit 1


# OLR 
# CLIMA  # dados alguns dias faltantes, foi utilizados o timfillmiss 

cdo -f nc -timfillmiss,method=linear olr/olr.day.mean.v2.nc olr/olr.day.mean.v2.fillmiss.nc

cdo -f nc -ydaymean -seldate,"1981-01-01","2010-12-31" olr/olr.day.mean.v2.fillmiss.nc  olr/olr.noaa.v2.clima.19810101.20101231.nc 

cdo -f nc -ydaymean -seldate,"1991-01-01","2020-12-31" olr/olr.day.mean.v2.fillmiss.nc  olr/olr.noaa.v2.clima.19910101.20201231.nc 

cdo -f nc -ydaymean -seldate,"1981-01-01","2020-12-31" olr/olr.day.mean.v2.fillmiss.nc  olr/olr.noaa.v2.clima.19810101.20201231.nc 


# Anomalias 

 cdo -s -f nc -ydaysub -seldate,"1980-01-01","2021-12-31" olr/olr.day.mean.v2.fillmiss.nc  olr/olr.noaa.v2.clima.19810101.20201231.nc  olr/olr.noaa.v2.anomalia.19800101.20211231.nc

 cdo -s -f nc -ydaysub -seldate,"1980-01-01","2011-12-31" olr/olr.day.mean.v2.fillmiss.nc  olr/olr.noaa.v2.clima.19810101.20101231.nc  olr/olr.noaa.v2.anomalia.19800101.20111231.nc

 cdo -s -f nc -ydaysub -seldate,"1990-01-01","2021-12-31" olr/olr.day.mean.v2.fillmiss.nc  olr/olr.noaa.v2.clima.19910101.20201231.nc  olr/olr.noaa.v2.anomalia.19900101.20211231.nc


##### UWND 

# CLIMA 
cdo -ydaymean -sellevel,200 -mergetime uwnd/uwnd.{1981..2010}.nc  uwnd/u20.ncep.clima.19810101.20101231.nc 
cdo -ydaymean -sellevel,850 -mergetime uwnd/uwnd.{1981..2010}.nc  uwnd/u85.ncep.clima.19810101.20101231.nc 

cdo -ydaymean -sellevel,200 -mergetime uwnd/uwnd.{1991..2020}.nc  uwnd/u20.ncep.clima.19910101.20201231.nc 
cdo -ydaymean -sellevel,850 -mergetime uwnd/uwnd.{1991..2020}.nc  uwnd/u85.ncep.clima.19910101.20201231.nc 

cdo -ydaymean -sellevel,200 -mergetime uwnd/uwnd.{1981..2020}.nc  uwnd/u20.ncep.clima.19810101.20201231.nc 
cdo -ydaymean -sellevel,850 -mergetime uwnd/uwnd.{1981..2020}.nc  uwnd/u85.ncep.clima.19810101.20201231.nc 



mkdir -p clim1 clim2 clim3
# uma ano a mais no inicio e no final para evitar problemas na filtragem 

for i in $(seq 1980 2011)
do 

 cdo -s -ydaysub -sellevel,850 -ydaymean uwnd/uwnd.${i}.nc uwnd/u85.ncep.clima.19810101.20101231.nc clim1/u85.anom.${i}.nc


 cdo -s -ydaysub -sellevel,200 -ydaymean uwnd/uwnd.${i}.nc uwnd/u20.ncep.clima.19810101.20101231.nc clim1/u20.anom.${i}.nc

  echo $i
done



for i in $(seq 1990 2021)
do 

 cdo -s -ydaysub -sellevel,850 -ydaymean uwnd/uwnd.${i}.nc uwnd/u85.ncep.clima.19910101.20201231.nc clim2/u85.anom.${i}.nc


 cdo -s -ydaysub -sellevel,200 -ydaymean uwnd/uwnd.${i}.nc uwnd/u20.ncep.clima.19910101.20201231.nc clim2/u20.anom.${i}.nc

  echo $i
done



for i in $(seq 1980 2021)
do 

 cdo -s -ydaysub -sellevel,850 -ydaymean uwnd/uwnd.${i}.nc uwnd/u85.ncep.clima.19810101.20201231.nc clim3/u85.anom.${i}.nc


 cdo -s -ydaysub -sellevel,200 -ydaymean uwnd/uwnd.${i}.nc uwnd/u20.ncep.clima.19810101.20201231.nc clim3/u20.anom.${i}.nc

  echo $i
done


cdo mergetime clim1/u20*.nc uwnd/u20.ncep.anom.19800101.20111231.nc
cdo mergetime clim1/u85*.nc uwnd/u85.ncep.anom.19800101.20111231.nc


cdo mergetime clim2/u20*.nc uwnd/u20.ncep.anom.19900101.20211231.nc
cdo mergetime clim2/u85*.nc uwnd/u85.ncep.anom.19900101.20211231.nc

cdo mergetime clim3/u20*.nc uwnd/u20.ncep.anom.19800101.20211231.nc
cdo mergetime clim3/u85*.nc uwnd/u85.ncep.anom.19800101.20211231.nc


##### PREC 
##### 

# CLIMA 
cdo -f nc -ydaymean -sellonlatbox,-82,-34,-50,15 -mergetime prec/precip.{1981..2010}.nc  prec/precip.sa.cpc-noaa.clima.19810101.20101231.nc 

cdo -f nc -ydaymean -sellonlatbox,-82,-34,-50,15 -mergetime prec/precip.{1991..2020}.nc  prec/precip.sa.cpc-noaa.clima.19910101.20201231.nc 

cdo -f nc -ydaymean -sellonlatbox,-82,-34,-50,15 -mergetime prec/precip.{1981..2020}.nc  prec/precip.sa.cpc-noaa.clima.19810101.20201231.nc 


# mkdir -p clim1 clim2 clim3
# uma ano a mais no inicio e no final para evitar problemas na filtragem 


for i in $(seq 1980 2021)
do 

 cdo -s -ydaysub -sellonlatbox,-82,-34,-50,15 prec/precip.${i}.nc prec/precip.sa.cpc-noaa.clima.19810101.20201231.nc clim3/precip.anom.${i}.nc

  echo $i
done



for i in $(seq 1980 2011)
do 

 cdo -s -ydaysub -sellonlatbox,-82,-34,-50,15 prec/precip.${i}.nc prec/precip.sa.cpc-noaa.clima.19810101.20101231.nc clim1/precip.anom.${i}.nc

  echo $i
done



for i in $(seq 1990 2021)
do 

 cdo -s -ydaysub -sellonlatbox,-82,-34,-50,15 prec/precip.${i}.nc prec/precip.sa.cpc-noaa.clima.19910101.20201231.nc clim2/precip.anom.${i}.nc

  echo $i
done



cdo mergetime clim1/precip*.nc prec/precip.sa.cpc-noaa.anom.19800101.20111231.nc

cdo mergetime clim2/precip*.nc prec/precip.sa.cpc-noaa.anom.19900101.20211231.nc

cdo mergetime clim3/precip*.nc prec/precip.sa.cpc-noaa.anom.19800101.20211231.nc



# # ##### RECORTA PARA O PERIODO DE 01-03-1991 ATE 28-06-2021 
# # ##### para avaliancao de perda de sinal
# # Cria o desvio padrão climatologico 


cdo -s -f nc -timstd -seldate,1981-01-01,2020-12-31 data/uwnd/filtrados/ncep/200hpa/u20.ncep.filtrado.19800101.20211231.nc  data/uwnd/desvio_padrao/ncep/200hpa/u20.ncep.std-filtrado.19810101.20201231.nc

cdo -s -f nc -timstd -seldate,1991-01-01,2020-12-31 data/uwnd/filtrados/ncep/200hpa/u20.ncep.filtrado.19900101.20211231.nc  data/uwnd/desvio_padrao/ncep/200hpa/u20.ncep.std-filtrado.19910101.20201231.nc

cdo -s -f nc -timstd -seldate,1981-01-01,2010-12-31 data/uwnd/filtrados/ncep/200hpa/u20.ncep.filtrado.19800101.20111231.nc  data/uwnd/desvio_padrao/ncep/200hpa/u20.ncep.std-filtrado.19810101.20101231.nc

######## 

cdo -s -f nc -timstd -seldate,1981-01-01,2020-12-31 data/uwnd/filtrados/ncep/850hpa/u85.ncep.filtrado.19800101.20211231.nc  data/uwnd/desvio_padrao/ncep/850hpa/u85.ncep.std-filtrado.19810101.20201231.nc

cdo -s -f nc -timstd -seldate,1991-01-01,2020-12-31 data/uwnd/filtrados/ncep/850hpa/u85.ncep.filtrado.19900101.20211231.nc  data/uwnd/desvio_padrao/ncep/850hpa/u85.ncep.std-filtrado.19910101.20201231.nc

cdo -s -f nc -timstd -seldate,1981-01-01,2010-12-31 data/uwnd/filtrados/ncep/850hpa/u85.ncep.filtrado.19800101.20111231.nc  data/uwnd/desvio_padrao/ncep/850hpa/u85.ncep.std-filtrado.19810101.20101231.nc

# # # ## ## ## ## ### ### ### #### #### #### #### ##### ##### ##### ####### 



cdo -s -f nc -timstd -seldate,1981-01-01,2020-12-31 data/olr/filtrados/olr.noaa.v2.filtrado.19800101.20211231.nc  data/olr/desvio_padrao/olr.noaa.v2.std-filtrado.19810101.20201231.nc

cdo -s -f nc -b F32 -timstd -seldate,1991-01-01,2020-12-31 data/olr/filtrados/olr.noaa.v2.filtrado.19900101.20211231.nc  data/olr/desvio_padrao/olr.noaa.v2.std-filtrado.19910101.20201231.nc

cdo -s -f nc -b F32 -timstd -seldate,1981-01-01,2010-12-31 data/olr/filtrados/olr.noaa.v2.filtrado.19800101.20111231.nc  data/olr/desvio_padrao/olr.noaa.v2.std-filtrado.19810101.20101231.nc

######## 

cdo -s -f nc -timstd -seldate,1981-01-01,2020-12-31 filtrados/precip.sa.cpc-noaa.filtrado.19800101.20211231.nc  filtrados/precip.sa.cpc-noaa.std-filtrado.19810101.20201231.nc

cdo -s -f nc -timstd -seldate,1991-01-01,2020-12-31 filtrados/precip.sa.cpc-noaa.filtrado.19900101.20211231.nc  filtrados/precip.sa.cpc-noaa.std-filtrado.19910101.20201231.nc

cdo -s -f nc -timstd -seldate,1981-01-01,2010-12-31 filtrados/precip.sa.cpc-noaa.filtrado.19800101.20111231.nc  filtrados/precip.sa.cpc-noaa.std-filtrado.19810101.20101231.nc





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




