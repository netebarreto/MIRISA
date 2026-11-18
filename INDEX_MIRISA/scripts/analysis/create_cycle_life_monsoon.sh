#!/usr/bin/env bash
# =============================================================================
# Índice de monção UVIMT (Raia & Cavalcanti 2008; Cavalcanti & Raia 2017)
#   UVIMT = (1/g) * ∫_{1000}^{700 hPa} q·u dp   na área A3 (10–15°S, 65–55°W)
#   pêntadas -> normalização [-1,+1] -> onset/demise
#
# Entrada: arquivos diários (ou sub-diários) em níveis de pressão, ex. NCEP R1:
#   shum.YYYY.nc (var shum, kg/kg)   uwnd.YYYY.nc (var uwnd, m/s)
# Dependências: cdo (>=1.9), awk
# =============================================================================
set -euo pipefail

# ----------------------------- configuração ---------------------------------
DIR_IN=${DIR_IN:-./dados}            # onde estão shum.*.nc e uwnd.*.nc
DIR_OUT=${DIR_OUT:-./saida}
VAR_Q=${VAR_Q:-shum}
VAR_U=${VAR_U:-uwnd}
ANO_I=${ANO_I:-1980}                  # período de análise
ANO_F=${ANO_F:-2000}
CLIM_I=${CLIM_I:-$ANO_I}              # período da climatologia (min/max da Eq. 2)
CLIM_F=${CLIM_F:-$ANO_F}
BOX="-65,-55,-15,-10"                 # A3: lon1,lon2,lat1,lat2
G=9.80665
# pesos trapezoidais (Pa) p/ 1000,925,850,700 hPa: dp/2 nas bordas
#   1000: 75/2=37.5 | 925: (75+75)/2=75 | 850: (75+150)/2=112.5 | 700: 150/2=75
declare -A W=( [1000]=3750 [925]=7500 [850]=11250 [700]=7500 )
LEVS="1000,925,850,700"
# ----------------------------------------------------------------------------

mkdir -p "$DIR_OUT"; TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
export CDO_FILE_SUFFIX=.nc

echo ">> 1. recorte A3 + níveis 1000–700 hPa + média diária"
for v in "$VAR_Q" "$VAR_U"; do
  files=()
  for y in $(seq "$ANO_I" "$ANO_F"); do files+=("$DIR_IN/$v.$y.nc"); done
  cdo -s -O -L daymean -sellevel,$LEVS -sellonlatbox,$BOX -selname,$v \
      -mergetime "${files[@]}" "$TMP/$v.nc"
done

echo ">> 2. fluxo q·u por nível"
# chname p/ evitar conflito de nome; mul usa o nome do 1º arquivo
cdo -s -O mul "$TMP/$VAR_Q.nc" "$TMP/$VAR_U.nc" "$TMP/qu.nc"

echo ">> 3. integral vertical trapezoidal / g  -> kg m-1 s-1"
parts=()
for p in 1000 925 850 700; do
  cdo -s -O mulc,${W[$p]} -sellevel,$p "$TMP/qu.nc" "$TMP/qu_$p.nc"
  # zera o eixo z para que enssum some níveis diferentes
  cdo -s -O setlevel,0 "$TMP/qu_$p.nc" "$TMP/quz_$p.nc"
  parts+=("$TMP/quz_$p.nc")
done
cdo -s -O -L divc,$G -enssum "${parts[@]}" "$TMP/uvimt_grid.nc"

echo ">> 4. média na área A3 (ponderada por cos(lat))"
cdo -s -O -L setname,uvimt -setunit,"kg m-1 s-1" -fldmean \
    "$TMP/uvimt_grid.nc" "$TMP/uvimt_dia.nc"

echo ">> 5. pêntadas (73/ano; 29/fev removido)"
# após del29feb cada ano tem 365 d = 73x5, então timselmean,5 fica alinhado
cdo -s -O -L timselmean,5 -setcalendar,365_day -del29feb "$TMP/uvimt_dia.nc" "$DIR_OUT/uvimt_pentada.nc"

echo ">> 6. climatologia pentadal + min/max (X da Eq. 2)"
cdo -s -O -L ydaymean -selyear,$CLIM_I/$CLIM_F \
    "$DIR_OUT/uvimt_pentada.nc" "$DIR_OUT/uvimt_clim.nc"
cdo -s -O timmin "$DIR_OUT/uvimt_clim.nc" "$TMP/min.nc"
cdo -s -O timmax "$DIR_OUT/uvimt_clim.nc" "$TMP/max.nc"
cdo -s -O sub "$TMP/max.nc" "$TMP/min.nc" "$TMP/rng.nc"

echo ">> 7. normalização: chi = 2*(X-min)/(max-min) - 1"
norm() {  # $1 entrada, $2 saída
  cdo -s -O -L setname,chi -subc,1 -mulc,2 -div -sub "$1" "$TMP/min.nc" "$TMP/rng.nc" "$2"
}
norm "$DIR_OUT/uvimt_pentada.nc" "$DIR_OUT/chi_pentada.nc"
norm "$DIR_OUT/uvimt_clim.nc"    "$DIR_OUT/chi_clim.nc"

echo ">> 8. tabela texto (ano pentada chi)"
to_txt() {
  cdo -s outputtab,date,value "$1" | awk 'NR>1 && $1!~/#/{
      split($1,d,"-"); n[d[1]]++; print d[1], n[d[1]], $2}' > "$2"
}
to_txt "$DIR_OUT/chi_pentada.nc" "$DIR_OUT/chi_pentada.txt"
to_txt "$DIR_OUT/chi_clim.nc"    "$DIR_OUT/chi_clim.txt"

echo ">> 9. onset/demise"
# Onset : 1ª pêntada com chi>0 (anterior <=0) e >=3 das 4 seguintes >0
# Demise: 1ª pêntada após o onset com chi<0 (anterior >=0) e >=3 das 4 seguintes <0
# Busca no ano hidrológico: pêntada 37 (~1/jul) do ano Y até a 36 de Y+1
DETECT='
{ ano[NR]=$1; pt[NR]=$2; c[NR]=$3+0 }
END{
  N=NR; printf "%-9s %6s %6s %8s\n","ano_hid","onset","demise","duracao"
  for(i=1;i<=N;i++){
    if(pt[i]!=P0) continue
    on=0; de=0; fim=i+72
    for(k=i+1;k<=fim && (W || k+4<=N);k++){
      if(!on){
        if(v(k)>0 && v(k-1)<=0 && cnt(k,1)>=3){ on=k }
      } else if(v(k)<0 && v(k-1)>=0 && cnt(k,-1)>=3){ de=k; break }
    }
    lab= W ? "clim" : ano[i] "/" substr(ano[i]+1,3)
    so= on? pt[idx(on)] : "-"; sd= de? pt[idx(de)] : "-"
    du= (on&&de)? de-on : "-"
    printf "%-9s %6s %6s %8s\n", lab, so, sd, du
    if(W) break
  }
}
function idx(k){ return W ? ((k-1)%N)+1 : k }
function v(k){ return c[idx(k)] }
function cnt(k,s,  j,n){ n=0; for(j=1;j<=4;j++) if((s>0 && v(k+j)>0)||(s<0 && v(k+j)<0)) n++; return n }
'
# série anual (sem wrap)
awk -v P0=37 -v W=0 "$DETECT" "$DIR_OUT/chi_pentada.txt" | tee "$DIR_OUT/onset_demise_anual.txt"
echo "--- climatologia (ciclo médio, cíclico) ---"
awk -v P0=37 -v W=1 "$DETECT" "$DIR_OUT/chi_clim.txt"    | tee "$DIR_OUT/onset_demise_clim.txt"

echo ">> pronto: $DIR_OUT"

# DIR_IN=/ncep DIR_OUT=./saida ANO_I=1980 ANO_F=2000 bash indice_sams_uvimt.sh