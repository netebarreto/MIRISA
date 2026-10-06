
olr_clim=AA01-NC_INPUT/AA00-REF_NC/CLIM/olr.dayclim.v01r02.19810101.20101231.nc
u20_clim=AA01-NC_INPUT/AA00-REF_NC/CLIM/u20.dayclim.19810101.20101231.nc
u85_clim=AA01-NC_INPUT/AA00-REF_NC/CLIM/u85.dayclim.19810101.20101231.nc



for i in $(seq 2025 2025)
do 

 cdo -s -ydaysub AA01-NC_INPUT/AA00-NC_BRUTOS/olr/olr.${i}.nc ${olr_clim} AA01-NC_INPUT/AB00-ANOM_YEAR/olr/olr.anom.${i}.nc

 cdo -s -ydaysub -sellevel,200 AA01-NC_INPUT/AA00-NC_BRUTOS/uwind/uwnd.${i}.nc ${u20_clim} AA01-NC_INPUT/AB00-ANOM_YEAR/u20/u20.anom.${i}.nc
 
 cdo -s -ydaysub -sellevel,850 AA01-NC_INPUT/AA00-NC_BRUTOS/uwind/uwnd.${i}.nc ${u85_clim} AA01-NC_INPUT/AB00-ANOM_YEAR/u85/u85.anom.${i}.nc

  echo $i
done


for i in $(seq 2026 2026)
do 

 cdo -s -seltimestep,1/66 -ydaysub AA01-NC_INPUT/AA00-NC_BRUTOS/olr/olr.${i}.nc ${olr_clim} AA01-NC_INPUT/AB00-ANOM_YEAR/olr/olr.anom.${i}.nc

 cdo -s -seltimestep,1/66 -ydaysub -sellevel,200 AA01-NC_INPUT/AA00-NC_BRUTOS/uwind/uwnd.${i}.nc ${u20_clim} AA01-NC_INPUT/AB00-ANOM_YEAR/u20/u20.anom.${i}.nc
 
 cdo -s -seltimestep,1/66 -ydaysub -sellevel,850 AA01-NC_INPUT/AA00-NC_BRUTOS/uwind/uwnd.${i}.nc ${u85_clim} AA01-NC_INPUT/AB00-ANOM_YEAR/u85/u85.anom.${i}.nc

  echo $i
done


 cdo -mergetime AA01-NC_INPUT/AB00-ANOM_YEAR/olr/olr.anom.20*.nc  AA01-NC_INPUT/AB01-NOF_ANOM/olr.anom.daily.v01r02.20180101.20260307.nc 

 cdo  -mergetime AA01-NC_INPUT/AB00-ANOM_YEAR/u20/u20.anom.20*.nc  AA01-NC_INPUT/AB01-NOF_ANOM/u20.anom.daily.ncep.20180101.20260307.nc

 cdo -mergetime AA01-NC_INPUT/AB00-ANOM_YEAR/u85/u85.anom.20*.nc  AA01-NC_INPUT/AB01-NOF_ANOM/u85.anom.daily.ncep.20180101.20260307.nc 


# ##### RECORTA PARA O PERIODO DE 01-03-1991 ATE 28-06-2021 
# ##### para avaliancao de perda de sinal
# Cria o desvio padrão climatologico 

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd AA00-NC_INPUT/AC01-BTW_ANOM_R/u20.abtw.daily.ncep.19910301.20210628.nc AA00-NC_INPUT/AA00-REF_NC/STD_R/u20.std.abtw.daily.ncep.1991.2020.nc

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd AA00-NC_INPUT/AC01-BTW_ANOM_R/u85.abtw.daily.ncep.19910301.20210628.nc AA00-NC_INPUT/AA00-REF_NC/STD_R/u85.std.abtw.daily.ncep.1991.2020.nc 

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd AA00-NC_INPUT/AC01-BTW_ANOM_R/olr.abtw.daily.v01r02.19910301.20201231.nc AA00-NC_INPUT/AA00-REF_NC/STD_R/olr.std.daily.v01r02.cpc.1991.2020.nc

# ############

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div  AA01-NC_INPUT/AC01-BTW_ANOM/u20.abtw.daily.ncep.20180101.20260307.nc AA01-NC_INPUT/AA00-REF_NC/STD_R/u20.std.abtw.daily.ncep.1991.2020.nc AA01-NC_INPUT/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.20180101.20260307.nc

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div AA01-NC_INPUT/AC01-BTW_ANOM/u85.abtw.daily.ncep.20180101.20260307.nc AA01-NC_INPUT/AA00-REF_NC/STD_R/u85.std.abtw.daily.ncep.1991.2020.nc AA01-NC_INPUT/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.20180101.20260307.nc

cdo -s -b F32 -mermean -sellonlatbox,0.5,359.5,-15,15 -div AA01-NC_INPUT/AC01-BTW_ANOM/olr.abtw.daily.v01r02.20180101.20260307.nc AA01-NC_INPUT/AA00-REF_NC/STD_R/olr.std.daily.v01r02.cpc.1991.2020.nc AA01-NC_INPUT/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.20180101.20260307.nc

# cdo -s -b F32 -div -seldate,1991-03-01,2020-02-28 AA00-NC_INPUT/AC01-BTW_ANOM_R/prec.AMS.abtw.daily.cpc.19910301.20210628.nc AA00-NC_INPUT/AA00-REF_NC/STD_R/prec.AMS.std.abtw.daily.cpc.1991.2020.nc AA00-NC_INPUT/AC02-BTW_APAD_R/prec.AMS.apad.mca.daily.cpc.19910301.20200228.nc
# ############






