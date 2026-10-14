# =============================================================================
# ÍNDICE DE PRECIPITAÇÃO DA MONÇÃO — MPI (Monsoon Precipitation Index)
# =============================================================================
#
# Calcula o MPI a partir da precipitação diária do CPC/NOAA, seguindo a
# definição de Grimm, Hakoyama e Scheibe (2021), com adaptação da base de
# dados e do período climatológico.
#
# O índice representa a anomalia padronizada da precipitação diária média
# na região central da monção sul-americana: 10–20°S e 45–55°W.
#
# Formulação:
#   MPI(t) = [P_area(t) - climatologia_suavizada(d)] / desvio_padrao(d)
#
# em que:
#   P_area(t): precipitação diária média na região, ponderada pela área;
#   d: dia do calendário correspondente à data t;
#   climatologia_suavizada(d): média climatológica diária suavizada com
#                            janela móvel centrada de 31 dias;
#   desvio_padrao(d): desvio-padrão climatológico diário da série regional.
#
# Configuração desta aplicação:
#   - Período climatológico: 01/01/1991 a 31/12/2020.
#   - Período de saída: 01/03/1991 a 28/02/2021.
#   - Suavização com continuidade entre dezembro e janeiro.
#   - Desvio-padrão diário sem suavização, calculado com ydaystd.
#   - Precipitação diária sem filtro temporal.
#   - MPI adimensional.
#
# Limiares para classificação posterior:
#   MPI >= +1: dia ativo (active).
#   MPI <= -1: dia inativo (break).
#   -1 < MPI < +1: dia fora dos limiares de active e break.
#
# O script calcula o índice; a classificação e o agrupamento dos dias
# em episódios são realizados em etapa posterior. O estudo original
# concentra a análise no verão austral (DJF).
#
# Referência:
# GRIMM, A. M.; HAKOYAMA, L. R.; SCHEIBE, L. A. (2021).
# Active and break phases of the South American summer monsoon:
# MJO influence and subseasonal prediction.
# Climate Dynamics, 56, 3603–3624.
# DOI: https://doi.org/10.1007/s00382-021-05658-3
# =============================================================================



cdo mergetime data/prec/brutos/cpc_noaa/precip.{1991..2021}.nc data/prec/brutos/cpc_noaa/precip.cpc-noaa.19910101.20211231.nc

cdo -detrend -fldmean -sellonlatbox,-55,-45,-20,-10 data/prec/brutos/cpc_noaa/precip.cpc-noaa.19910101.20211231.nc data/prec/brutos/cpc_noaa/precip.cpc-noaa.mean_area_mpi.19910101.20211231_V2.nc
 
# Série da precipitação média regional já calculada
AREA="data/prec/brutos/cpc_noaa/precip.cpc-noaa.mean_area_mpi.19910101.20211231_V2.nc"


# 1. Climatologia diária: referência 1991–2020
cdo -ydaymean -seldate,1991-01-01,2020-12-31 \
    "$AREA" data/monsoon_index/mpi_clim_diaria_V2.nc


# 2. Extrair os últimos e os primeiros 15 dias da climatologia
# Para calendário gregoriano completo: 366 passos, incluindo 29/02
cdo -seltimestep,362/366 data/monsoon_index/mpi_clim_diaria_V2.nc data/monsoon_index/mpi_clim_fim_V2.nc
cdo -seltimestep,1/4 data/monsoon_index/mpi_clim_diaria_V2.nc data/monsoon_index/mpi_clim_inicio_V2.nc

# 3. Acrescentar dezembro antes de janeiro e janeiro depois de dezembro
cdo cat data/monsoon_index/mpi_clim_fim_V2.nc data/monsoon_index/mpi_clim_diaria_V2.nc data/monsoon_index/mpi_clim_inicio_V2.nc \
    data/monsoon_index/mpi_clim_estendida_V2.nc

# 4. Organizar as datas e aplicar a média móvel centrada
# O resultado terá datas de 01/01/2000 a 31/12/2000
cdo -runmean,10 -settaxis,1999-12-27,12:00:00,1day \
    data/monsoon_index/mpi_clim_estendida_V2.nc data/monsoon_index/mpi_clim_suavizada31_V2.nc

# 5. Anomalia em relação à climatologia suavizada
cdo -ydaysub "$AREA" data/monsoon_index/mpi_clim_suavizada31_V2.nc data/monsoon_index/mpi_anomalia_V2.nc

# 6. Desvio-padrão diário da precipitação média regional

cdo -ydaystd -seldate,1991-01-01,2020-12-31 \
    "$AREA" data/monsoon_index/mpi_std_diario_V2.nc

# 7. Padronização e seleção do período de análise
cdo -seldate,1991-03-01,2021-02-28 \
    -ydaydiv data/monsoon_index/mpi_anomalia_V2.nc data/monsoon_index/mpi_std_diario_V2.nc \
    outputs/netcdf/monsoon.prec.index.cpc-noaa.19910301.20210228_V2.nc 
