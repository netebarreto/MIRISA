#!/usr/bin/env bash
# Configuração apenas de caminhos; comandos científicos preservados.
_mirisa_script_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${_mirisa_script_root}/config/paths.sh" || exit 1


olr_clim=data/olr/climatologia/v01r02/1981_2010/olr.dayclim.v01r02.19810101.20101231.nc
u20_clim=data/uwnd/climatologia/ncep/200hpa/1981_2010/u20.dayclim.19810101.20101231.nc
u85_clim=data/uwnd/climatologia/ncep/850hpa/1981_2010/u85.dayclim.19810101.20101231.nc



for i in $(seq 2025 2025)
do 

 cdo -s -ydaysub data/olr/brutos/v01r02/olr.${i}.nc ${olr_clim} data/olr/anomalias/v01r02/historico/anuais/olr.anom.${i}.nc

 cdo -s -ydaysub -sellevel,200 data/uwnd/brutos/ncep/uwnd.${i}.nc ${u20_clim} data/uwnd/anomalias/ncep/200hpa/historico/anuais/u20.anom.${i}.nc
 
 cdo -s -ydaysub -sellevel,850 data/uwnd/brutos/ncep/uwnd.${i}.nc ${u85_clim} data/uwnd/anomalias/ncep/850hpa/historico/anuais/u85.anom.${i}.nc

  echo $i
done


for i in $(seq 2026 2026)
do 

 cdo -s -seltimestep,1/66 -ydaysub data/olr/brutos/v01r02/olr.${i}.nc ${olr_clim} data/olr/anomalias/v01r02/historico/anuais/olr.anom.${i}.nc

 cdo -s -seltimestep,1/66 -ydaysub -sellevel,200 data/uwnd/brutos/ncep/uwnd.${i}.nc ${u20_clim} data/uwnd/anomalias/ncep/200hpa/historico/anuais/u20.anom.${i}.nc
 
 cdo -s -seltimestep,1/66 -ydaysub -sellevel,850 data/uwnd/brutos/ncep/uwnd.${i}.nc ${u85_clim} data/uwnd/anomalias/ncep/850hpa/historico/anuais/u85.anom.${i}.nc

  echo $i
done


 cdo -mergetime data/olr/anomalias/v01r02/historico/anuais/olr.anom.20*.nc  data/olr/anomalias/v01r02/historico/olr.anom.daily.v01r02.20180101.20260307.nc 

 cdo  -mergetime data/uwnd/anomalias/ncep/200hpa/historico/anuais/u20.anom.20*.nc  data/uwnd/anomalias/ncep/200hpa/historico/u20.anom.daily.ncep.20180101.20260307.nc

 cdo -mergetime data/uwnd/anomalias/ncep/850hpa/historico/anuais/u85.anom.20*.nc  data/uwnd/anomalias/ncep/850hpa/historico/u85.anom.daily.ncep.20180101.20260307.nc 


# ##### RECORTA PARA O PERIODO DE 01-03-1991 ATE 28-06-2021 
# ##### para avaliancao de perda de sinal
# Cria o desvio padrão climatologico 

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/uwnd/filtrados/ncep/200hpa/historico/butterworth_seewave/u20.abtw.daily.ncep.19910301.20210628.nc data/uwnd/desvio_padrao/ncep/200hpa/historico/butterworth_seewave/u20.std.abtw.daily.ncep.1991.2020.nc

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/uwnd/filtrados/ncep/850hpa/historico/butterworth_seewave/u85.abtw.daily.ncep.19910301.20210628.nc data/uwnd/desvio_padrao/ncep/850hpa/historico/butterworth_seewave/u85.std.abtw.daily.ncep.1991.2020.nc 

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/olr/filtrados/v01r02/historico/butterworth_seewave/olr.abtw.daily.v01r02.19910301.20201231.nc data/olr/desvio_padrao/v01r02/historico/butterworth_seewave/olr.std.daily.v01r02.cpc.1991.2020.nc

# ############

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/200hpa/historico/butterworth_signal/u20.abtw.daily.ncep.20180101.20260307.nc data/uwnd/desvio_padrao/ncep/200hpa/historico/butterworth_seewave/u20.std.abtw.daily.ncep.1991.2020.nc data/uwnd/padronizados/ncep/200hpa/historico/u20.apad.mca.daily.ncep.20180101.20260307.nc

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div data/uwnd/filtrados/ncep/850hpa/historico/butterworth_signal/u85.abtw.daily.ncep.20180101.20260307.nc data/uwnd/desvio_padrao/ncep/850hpa/historico/butterworth_seewave/u85.std.abtw.daily.ncep.1991.2020.nc data/uwnd/padronizados/ncep/850hpa/historico/u85.apad.mca.daily.ncep.20180101.20260307.nc

cdo -s -b F32 -mermean -sellonlatbox,0.5,359.5,-15,15 -div data/olr/filtrados/v01r02/historico/butterworth_signal/olr.abtw.daily.v01r02.20180101.20260307.nc data/olr/desvio_padrao/v01r02/historico/butterworth_seewave/olr.std.daily.v01r02.cpc.1991.2020.nc data/olr/padronizados/v01r02/historico/olr.apad.mca.daily.v01r02.20180101.20260307.nc

# cdo -s -b F32 -div -seldate,1991-03-01,2020-02-28 data/prec/filtrados/cpc/historico/butterworth_seewave/prec.AMS.abtw.daily.cpc.19910301.20210628.nc data/prec/desvio_padrao/cpc/historico/butterworth_seewave/prec.AMS.std.abtw.daily.cpc.1991.2020.nc data/prec/padronizados/cpc/historico/prec.AMS.apad.mca.daily.cpc.19910301.20200228.nc
# ############







