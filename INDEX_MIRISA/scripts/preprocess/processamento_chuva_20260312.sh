#!/usr/bin/env bash
# Configuração apenas de caminhos; comandos científicos preservados.
_mirisa_script_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${_mirisa_script_root}/config/paths.sh" || exit 1



cdo sellonlatbox,-75,-34,-40,10 data/raw/chirps/GLOBAL_P25/chirps-v2.0.2024.days_p25.nc data/intermediate/chirps/chirps-v2.0.SA.20240101.20241231.days_p25.nc

cdo sellonlatbox,-75,-34,-40,10 data/raw/chirps/GLOBAL_P25/chirps-v2.0.2025.days_p25.nc data/intermediate/chirps/chirps-v2.0.SA.20250101.20251231.days_p25.nc

cdo mergetime data/raw/chirps/GLOBAL_P25/chirps-v2.0.2026.days_p25.nc -seldate,2026-02-14,2026-02-28 data/raw/chirps/GLOBAL_P25/Pre_2026/chirps-v2.0.2026.02.days_p25.nc data/raw/chirps/GLOBAL_P25/Pre_2026/chirps-v2.0.2026.03.days_p25.nc data/raw/chirps/GLOBAL_P25/chirps-v2.0.prelim.2026.days_p25.nc


cdo sellonlatbox,-75,-34,-40,10 data/raw/chirps/GLOBAL_P25/chirps-v2.0.prelim.2026.days_p25.nc data/intermediate/chirps/chirps-v2.0.SA.20260101.20260305.days_p25.nc

cdo -fldmean -sellonlatbox,-55,-45,-20,-10 data/intermediate/chirps/chirps-v2.0.SA.19810101.20221231.days_p25.nc outputs/netcdf/rain.mpiarea.19810101.20221231.nc 

cdo -ydaysub outputs/netcdf/rain.mpiarea.19810101.20221231.nc -ydaymean outputs/netcdf/rain.mpiarea.19810101.20221231.nc outputs/netcdf/teste2a.nc 


cdo -ydaydiv outputs/netcdf/teste2a.nc -ydaystd outputs/netcdf/rain.mpiarea.19810101.20221231.nc outputs/netcdf/teste2.nc 
