#!/usr/bin/env bash
# Configuração apenas de caminhos; comandos científicos preservados.
_mirisa_script_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${_mirisa_script_root}/config/paths.sh" || exit 1


##### RECORTA PARA O PERIODO DE 01-03-1991 ATE 28-06-2021 
##### para avaliancao de perda de sinal


cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/uwnd/filtrados/ncep/200hpa/historico/butterworth_seewave/u20.abtw.daily.ncep.19910301.20210628.nc data/uwnd/desvio_padrao/ncep/200hpa/historico/referencia_legada/u20.std.abtw.daily.ncep.1991.2020.nc

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/uwnd/filtrados/ncep/850hpa/historico/butterworth_seewave/u85.abtw.daily.ncep.19910301.20210628.nc data/uwnd/desvio_padrao/ncep/850hpa/historico/referencia_legada/u85.std.abtw.daily.ncep.1991.2020.nc 

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/prec/filtrados/cpc/historico/butterworth_seewave/prec.AMS.abtw.daily.cpc.19910301.20210628.nc data/prec/desvio_padrao/cpc/historico/referencia_legada/prec.AMS.std.abtw.daily.cpc.1991.2020.nc

cdo -s -b F32 -seldate,1991-03-01,2020-02-28 -timstd data/olr/filtrados/v01r02/historico/butterworth_signal/olr.abtw.daily.v01r02.19910301.20211231.nc data/olr/desvio_padrao/v01r02/historico/referencia_legada/olr.std.daily.v01r02.cpc.1991.2020.nc

############
cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div -seldate,1991-03-01,2020-02-28 data/uwnd/filtrados/ncep/200hpa/historico/butterworth_seewave/u20.abtw.daily.ncep.19910301.20210628.nc data/uwnd/desvio_padrao/ncep/200hpa/historico/referencia_legada/u20.std.abtw.daily.ncep.1991.2020.nc data/uwnd/padronizados/ncep/200hpa/historico/u20.apad.mca.daily.ncep.19910301.20200228.nc

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div -seldate,1991-03-01,2020-02-28 data/uwnd/filtrados/ncep/850hpa/historico/butterworth_seewave/u85.abtw.daily.ncep.19910301.20210628.nc data/uwnd/desvio_padrao/ncep/850hpa/historico/referencia_legada/u85.std.abtw.daily.ncep.1991.2020.nc data/uwnd/padronizados/ncep/850hpa/historico/u85.apad.mca.daily.ncep.19910301.20200228.nc

cdo -s -b F32 -mermean -sellonlatbox,0.5,359.5,-15,15 -div -seldate,1991-03-01,2020-02-28 data/olr/filtrados/v01r02/historico/butterworth_signal/olr.abtw.daily.v01r02.19910301.20211231.nc data/olr/desvio_padrao/v01r02/historico/referencia_legada/olr.std.daily.v01r02.cpc.1991.2020.nc data/olr/padronizados/v01r02/historico/olr.apad.mca.daily.v01r02.19910301.20200228.nc

cdo -s -b F32 -div -seldate,1991-03-01,2020-02-28 data/prec/filtrados/cpc/historico/butterworth_seewave/prec.AMS.abtw.daily.cpc.19910301.20210628.nc data/prec/desvio_padrao/cpc/historico/referencia_legada/prec.AMS.std.abtw.daily.cpc.1991.2020.nc data/prec/padronizados/cpc/historico/prec.AMS.apad.mca.daily.cpc.19910301.20200228.nc
############





############
cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/200hpa/historico/butterworth_signal/u20.abtw.daily.ncep.20180101.20250907.nc data/uwnd/desvio_padrao/ncep/200hpa/historico/referencia_legada/u20.std.abtw.daily.ncep.1991.2020.nc data/uwnd/padronizados/ncep/200hpa/historico/u20.apad.mca.daily.ncep.20180101.20250907.nc

cdo -s -b F32 -mermean -sellonlatbox,0,357.5,-15,15 -div  data/uwnd/filtrados/ncep/850hpa/historico/butterworth_signal/u85.abtw.daily.ncep.20180101.20250907.nc data/uwnd/desvio_padrao/ncep/850hpa/historico/referencia_legada/u85.std.abtw.daily.ncep.1991.2020.nc data/uwnd/padronizados/ncep/850hpa/historico/u85.apad.mca.daily.ncep.20180101.20250907.nc

cdo -s -b F32 -mermean -sellonlatbox,0.5,359.5,-15,15 -div  data/olr/filtrados/v01r02/historico/butterworth_signal/olr.abtw.daily.v01r02.20180101.20250907.nc data/olr/desvio_padrao/v01r02/historico/referencia_legada/olr.std.daily.v01r02.cpc.1991.2020.nc data/olr/padronizados/v01r02/historico/olr.apad.mca.daily.v01r02.20180101.20250907.nc


############


