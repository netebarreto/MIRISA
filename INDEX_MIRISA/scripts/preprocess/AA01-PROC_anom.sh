#!/usr/bin/env bash
# Configuração apenas de caminhos; comandos científicos preservados.
_mirisa_script_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${_mirisa_script_root}/config/paths.sh" || exit 1


olr_clim=data/reference/CLIM/olr.dayclim.v01r02.19810101.20101231.nc
u20_clim=data/reference/CLIM/u20.dayclim.19810101.20101231.nc
u85_clim=data/reference/CLIM/u85.dayclim.19810101.20101231.nc



for i in $(seq 2025 2025)
do 

 cdo -s -ydaysub data/raw/olr/olr.${i}.nc ${olr_clim} data/intermediate/AB00-ANOM_YEAR/olr/olr.anom.${i}.nc

 cdo -s -ydaysub -sellevel,200 data/raw/uwind/uwnd.${i}.nc ${u20_clim} data/intermediate/AB00-ANOM_YEAR/u20/u20.anom.${i}.nc
 
 cdo -s -ydaysub -sellevel,850 data/raw/uwind/uwnd.${i}.nc ${u85_clim} data/intermediate/AB00-ANOM_YEAR/u85/u85.anom.${i}.nc

  echo $i
done


for i in $(seq 2026 2026)
do 

 cdo -s -seltimestep,1/66 -ydaysub data/raw/olr/olr.${i}.nc ${olr_clim} data/intermediate/AB00-ANOM_YEAR/olr/olr.anom.${i}.nc

 cdo -s -seltimestep,1/66 -ydaysub -sellevel,200 data/raw/uwind/uwnd.${i}.nc ${u20_clim} data/intermediate/AB00-ANOM_YEAR/u20/u20.anom.${i}.nc
 
 cdo -s -seltimestep,1/66 -ydaysub -sellevel,850 data/raw/uwind/uwnd.${i}.nc ${u85_clim} data/intermediate/AB00-ANOM_YEAR/u85/u85.anom.${i}.nc

  echo $i
done


 cdo -mergetime data/intermediate/AB00-ANOM_YEAR/olr/olr.anom.20*.nc  data/intermediate/AB01-NOF_ANOM/olr.anom.daily.v01r02.20180101.20260307.nc 

 cdo  -mergetime data/intermediate/AB00-ANOM_YEAR/u20/u20.anom.20*.nc  data/intermediate/AB01-NOF_ANOM/u20.anom.daily.ncep.20180101.20260307.nc

 cdo -mergetime data/intermediate/AB00-ANOM_YEAR/u85/u85.anom.20*.nc  data/intermediate/AB01-NOF_ANOM/u85.anom.daily.ncep.20180101.20260307.nc 


# ##### RECORTA PARA O PERIODO DE 01-03-1991 ATE 28-06-2021 
# ##### para avaliancao de perda de sinal
# Cria o desvio padrão climatologico 

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/intermediate/AC01-BTW_ANOM_R/u20.abtw.daily.ncep.19910301.20210628.nc data/reference/STD_R/u20.std.abtw.daily.ncep.1991.2020.nc

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/intermediate/AC01-BTW_ANOM_R/u85.abtw.daily.ncep.19910301.20210628.nc data/reference/STD_R/u85.std.abtw.daily.ncep.1991.2020.nc 

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/intermediate/AC01-BTW_ANOM_R/olr.abtw.daily.v01r02.19910301.20201231.nc data/reference/STD_R/olr.std.daily.v01r02.cpc.1991.2020.nc

# ############

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/intermediate/AC01-BTW_ANOM/u20.abtw.daily.ncep.20180101.20260307.nc data/reference/STD_R/u20.std.abtw.daily.ncep.1991.2020.nc data/intermediate/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.20180101.20260307.nc

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div data/intermediate/AC01-BTW_ANOM/u85.abtw.daily.ncep.20180101.20260307.nc data/reference/STD_R/u85.std.abtw.daily.ncep.1991.2020.nc data/intermediate/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.20180101.20260307.nc

cdo -s -b F32 -mermean -sellonlatbox,0.5,359.5,-15,15 -div data/intermediate/AC01-BTW_ANOM/olr.abtw.daily.v01r02.20180101.20260307.nc data/reference/STD_R/olr.std.daily.v01r02.cpc.1991.2020.nc data/intermediate/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.20180101.20260307.nc

# cdo -s -b F32 -div -seldate,1991-03-01,2020-02-28 data/intermediate/AC01-BTW_ANOM_R/prec.AMS.abtw.daily.cpc.19910301.20210628.nc data/reference/STD_R/prec.AMS.std.abtw.daily.cpc.1991.2020.nc data/intermediate/AC02-BTW_APAD_R/prec.AMS.apad.mca.daily.cpc.19910301.20200228.nc
# ############







