
##### RECORTA PARA O PERIODO DE 01-03-1991 ATE 28-06-2021 
##### para avaliancao de perda de sinal


cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd INPUT_NC/AC01-BTW_ANOM_R/u20.abtw.daily.ncep.19910301.20210628.nc INPUT_NC/AA00-REF_NC/STD_R/u20.std.abtw.daily.ncep.1991.2020.nc

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd INPUT_NC/AC01-BTW_ANOM_R/u85.abtw.daily.ncep.19910301.20210628.nc INPUT_NC/AA00-REF_NC/STD_R/u85.std.abtw.daily.ncep.1991.2020.nc 

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd INPUT_NC/AC01-BTW_ANOM_R/prec.AMS.abtw.daily.cpc.19910301.20210628.nc INPUT_NC/AA00-REF_NC/STD_R/prec.AMS.std.abtw.daily.cpc.1991.2020.nc

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd INPUT_NC/AC01-BTW_ANOM/olr.abtw.daily.v01r02.19910301.20211231.nc INPUT_NC/AA00-REF_NC/STD_R/olr.std.daily.v01r02.cpc.1991.2020.nc

############
cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div -seldate,1991-03-01,2020-02-28 INPUT_NC/AC01-BTW_ANOM_R/u20.abtw.daily.ncep.19910301.20210628.nc INPUT_NC/AA00-REF_NC/STD_R/u20.std.abtw.daily.ncep.1991.2020.nc INPUT_NC/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.19910301.20200228.nc

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div -seldate,1991-03-01,2020-02-28 INPUT_NC/AC01-BTW_ANOM_R/u85.abtw.daily.ncep.19910301.20210628.nc INPUT_NC/AA00-REF_NC/STD_R/u85.std.abtw.daily.ncep.1991.2020.nc INPUT_NC/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.19910301.20200228.nc

cdo -s -b F32 -mermean -sellonlatbox,0.5,359.5,-15,15 -div -seldate,1991-03-01,2020-02-28 INPUT_NC/AC01-BTW_ANOM/olr.abtw.daily.v01r02.19910301.20211231.nc INPUT_NC/AA00-REF_NC/STD_R/olr.std.daily.v01r02.cpc.1991.2020.nc INPUT_NC/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.19910301.20200228.nc

cdo -s -b F32 -div -seldate,1991-03-01,2020-02-28 INPUT_NC/AC01-BTW_ANOM_R/prec.AMS.abtw.daily.cpc.19910301.20210628.nc INPUT_NC/AA00-REF_NC/STD_R/prec.AMS.std.abtw.daily.cpc.1991.2020.nc INPUT_NC/AC02-BTW_APAD_R/prec.AMS.apad.mca.daily.cpc.19910301.20200228.nc
############





############
cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div  AA01-NC_INPUT/AC01-BTW_ANOM/u20.abtw.daily.ncep.20180101.20250907.nc AA01-NC_INPUT/AA00-REF_NC/STD_R/u20.std.abtw.daily.ncep.1991.2020.nc AA01-NC_INPUT/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.20180101.20250907.nc

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div  AA01-NC_INPUT/AC01-BTW_ANOM/u85.abtw.daily.ncep.20180101.20250907.nc AA01-NC_INPUT/AA00-REF_NC/STD_R/u85.std.abtw.daily.ncep.1991.2020.nc AA01-NC_INPUT/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.20180101.20250907.nc

cdo -s -b F32 -mermean -sellonlatbox,0.5,359.5,-15,15 -div  AA01-NC_INPUT/AC01-BTW_ANOM/olr.abtw.daily.v01r02.20180101.20250907.nc AA01-NC_INPUT/AA00-REF_NC/STD_R/olr.std.daily.v01r02.cpc.1991.2020.nc AA01-NC_INPUT/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.20180101.20250907.nc


############

