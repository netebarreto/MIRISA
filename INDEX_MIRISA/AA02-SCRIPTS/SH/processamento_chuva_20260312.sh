

cdo sellonlatbox,-75,-34,-40,10 GLOBAL_P25/chirps-v2.0.2024.days_p25.nc chirps-v2.0.SA.20240101.20241231.days_p25.nc

cdo sellonlatbox,-75,-34,-40,10 GLOBAL_P25/chirps-v2.0.2025.days_p25.nc chirps-v2.0.SA.20250101.20251231.days_p25.nc

cdo mergetime GLOBAL_P25/chirps-v2.0.2026.days_p25.nc -seldate,2026-02-14,2026-02-28 GLOBAL_P25/Pre_2026/chirps-v2.0.2026.02.days_p25.nc GLOBAL_P25/Pre_2026/chirps-v2.0.2026.03.days_p25.nc GLOBAL_P25/chirps-v2.0.prelim.2026.days_p25.nc


cdo sellonlatbox,-75,-34,-40,10 GLOBAL_P25/chirps-v2.0.prelim.2026.days_p25.nc chirps-v2.0.SA.20260101.20260305.days_p25.nc

cdo -fldmean -sellonlatbox,-55,-45,-20,-10 chirps-v2.0.SA.19810101.20221231.days_p25.nc rain.mpiarea.19810101.20221231.nc 

cdo -ydaysub rain.mpiarea.19810101.20221231.nc -ydaymean rain.mpiarea.19810101.20221231.nc teste2a.nc 


cdo -ydaydiv teste2a.nc -ydaystd rain.mpiarea.19810101.20221231.nc teste2.nc 