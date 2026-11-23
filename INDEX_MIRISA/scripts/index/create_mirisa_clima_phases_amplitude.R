#
# ROTINA QUE CALCULA A ANALISE DE MAXIMA COVARIANCIA 
#

# CHAMANDO AS ROTINAS, FUNÇÕES E BIBLIOTECA

# PREPARACAO DO AMBIENTE
# Remove os objetos da sessao atual para evitar interferencia de execucoes anteriores.
rm(list=ls())

# Define a raiz do projeto; os caminhos de entrada e saida abaixo sao relativos a ela.
#setwd("C:/Users/Nete/Documents/NETE_PROJETOS/AB00-PROJETOS_NETE/MIRISA_PROJECT/MIRISA_organizado/INDEX_MIRISA")

setwd("D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA/")
# setwd("D:/DATASET")
# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
#source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))


# ncdf4 permite ler/gravar NetCDF; fields fornece image.plot para os mapas.
library(ncdf4)
library(fields) 

# Carrega as funcoes auxiliares; cov4gappy calcula covariancias com dados faltantes.
source("scripts/functions/R/miri_lags.R")

f1()

ystart = 1991
yend = 2020

dversion = "20261111" # Referencia do input

input_files = list(
    mca_result=paste0("outputs/models/MCA_SA_",ystart,"-",yend,"_",dversion,".RData"),
    prec = paste0("data/prec/filtrados/cpc/precip.sa.cpc-noaa.filtrado.",ystart-1,"0101.",yend+1,"1231.nc"),
    olr = paste0("data/olr/filtrados/olr.noaa.v2.filtrado.",ystart-1,"0101.",yend+1,"1231.nc"),
    u85 = paste0("data/uwnd/filtrados/ncep/850hpa/u85.ncep.filtrado.",ystart-1,"0101.",yend+1,"1231.nc"),
    v85 = paste0("data/vwnd/filtrados/ncep/850hpa/v85.ncep.filtrado.",ystart-1,"0101.",yend+1,"1231.nc"))

period <- paste0(ystart,"-",yend)
dtoday <- format(Sys.Date(), "%Y%m%d")

output_files = list(
    mirisa=paste0("outputs/tables/mirisa_clim_",ystart,"0101.",yend,"1231_CREATE_",dtoday,".txt"),
    compostos=paste0("outputs/tables/composicao_mirisa_phases_",ystart,"-",yend,"_lags_",dtoday,".txt"),
    prec = paste0("outputs/netcdf/phases_compostos/prec.mirisa.phases.cpc.",ystart,"-",yend,"_",dtoday,".nc"),
    olr = paste0("outputs/netcdf/phases_compostos/olr.mirisa.phases.noaa.v2.",ystart,"-",yend,"_",dtoday,".nc"),
    u85=paste0("outputs/netcdf/phases_compostos/u85.mirisa.phases.ncep.r1.",ystart,"-",yend,"_",dtoday,".nc"),
    v85=paste0("outputs/netcdf/phases_compostos/v85.mirisa.phases.ncep.r1.",ystart,"-",yend,"_",dtoday,".nc"))
#===============================================================================

load(input_files$mca_result)


# Transformando em valores padronizados
# Escala os coeficientes dos dois primeiros modos pela raiz do valor singular associado.
coef.A1<-mca.dataset$A[,1]/sqrt(mca.dataset$Lambda[1]) 
coef.A2<-mca.dataset$A[,2]/sqrt(mca.dataset$Lambda[2])
coef.B1<-mca.dataset$B[,1]/sqrt(mca.dataset$Lambda[1]) 
coef.B2<-mca.dataset$B[,2]/sqrt(mca.dataset$Lambda[2])

# Calcula as combinacoes definidas na rotina: index1 usa A1 e B1; index2 usa A2 e B2.
# dessa forma o index maximiza as anomalias associadas a chuva.
index1=round((coef.A1+coef.B1)/2,4)
index2=round((coef.A2+coef.B2)/2,4)

# INDICE MIRISA - COMPONENTES, AMPLITUDE E FASE
# Converte as duas componentes em angulo e amplitude; setores de 45 graus definem a fase.
# A ordem dos argumentos (x2, x1) determina a orientacao do angulo em atan2.


perfil1 <- function(x2, x1) {   # x2 = MIRISA2, x1 = MIRISA1
  angl  <- (180 - atan2(x2, x1) * 180/pi) %% 360
  phase <- as.integer(floor(angl / 45)) + 1L   # F1 = 0–45°, ..., F8 = 315–360°
  ampl  <- round(sqrt(x1^2 + x2^2), 3)
  data.frame(Angle = angl, Phase = phase, Amplitude = ampl)
}

phi  <- seq(22.5, 337.5, by = 45)   # centro de cada octante (M1 → direita, M2 → cima)
t    <- perfil1(x2 = sin(phi*pi/180), x1 = cos(phi*pi/180))
cbind(phi, t$Phase)
# esperado: 22.5→5, 67.5→6, 112.5→7, 157.5→8, 202.5→1, 247.5→2, 292.5→3, 337.5→4

indexT= perfil1(index2,index1)

# Converte o tempo NetCDF em datas usando a unidade e a origem do atributo units.
# O switch reconhece days, hours, minutes e seconds; a origem e interpretada em UTC.
units<-strsplit(t.prp$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.prp$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.prp$vals * multiplicator
time.idx<-as.character(as.Date(time.out))


# Monta a tabela diaria: ano, mes, dia, duas componentes, fase e amplitude.
mirisa<-data.frame(Year=substr(time.idx,1,4),
    Month=substr(time.idx,6,7),
    day=substr(time.idx,9,10),MIRISA1c1=index1, MIRISA1c2=index2,indexT,dataset="ncep_r1",periodo="clim_40yr")


# # Exporta o indice diario em texto separado por ponto e virgula, sem nomes de linhas.

write.table(mirisa,file=output_files$mirisa,sep=";",dec=".",col.names=T,row.names=FALSE)

# ####################################

# ANALISES EXPLORATORIAS - COMPOSTOS SAZONAIS E CORRELACOES
# Cria uma copia da tabela e classifica a amplitude em faixas (codigos de 0 a 6).

mirisa$Intensidade <- findInterval(mirisa$Amplitude,c(1.5,2.0,2.5,3.0,3.5,4.0))

# Seleciona dezembro, janeiro e fevereiro (DJF); nn guarda os indices na serie completa.
# 1. Garantir que as colunas sejam numéricas
mirisa$Month <- as.numeric(mirisa$Month)
mirisa$Year  <- as.numeric(mirisa$Year)

# 2. Filtrar os meses DJF excluindo as pontas incompletas
miri_ext <- subset(
  mirisa, 
  (Month %in% c(12, 1, 2)) &                   # Apenas Dezembro, Janeiro e Fevereiro
  !(Year == 1981 & Month %in% c(1, 2)) &       # Exclui Jan e Fev de 1991
  !(Year == 2020 & Month == 12) &
  (Intensidade >= 3)                # Exclui Dez de 2020
)


# Defasagens desejadas: de -30 até +30 dias
lags <- -30:30

# 1. Identificar as DATAS (ou identificador único diário) onde cada fase ocorre dentro de 'mirie'
# Supondo que as colunas 1, 2, 3 sejam Year, Month, Day ou que exista uma coluna de data 'Date'
# Se não houver coluna de data, podemos associar pelo número de linha original da 'miri':

# Vamos capturar as linhas originais da 'miri' que estão na 'mirie'
# (ou seja, qual é o índice na 'miri' de cada registro da 'mirie')
indices_miri_no_djf <- as.numeric(rownames(miri_ext))

# 2. Mapear as fases usando a coluna 6 de 'mirie'
fases_indices_miri <- list(
  f1 = indices_miri_no_djf[which(miri_ext$Phase == 1)],
  f2 = indices_miri_no_djf[which(miri_ext$Phase == 2)],
  f3 = indices_miri_no_djf[which(miri_ext$Phase == 3)],
  f4 = indices_miri_no_djf[which(miri_ext$Phase == 4)],
  f5 = indices_miri_no_djf[which(miri_ext$Phase == 5)],
  f6 = indices_miri_no_djf[which(miri_ext$Phase == 6)],
  f7 = indices_miri_no_djf[which(miri_ext$Phase == 7)],
  f8 = indices_miri_no_djf[which(miri_ext$Phase == 8)]
)


# 4. Criar a lista de tabelas para cada fase f1 até f8
n_rows_miri <- nrow(mirisa)

tabelas_lags_fases <- lapply(
  fases_indices_miri, 
  gerar_tabela_lags_miri, 
  vector_lags = lags, 
  total_linhas_miri = n_rows_miri
)

# Exemplo: Visualizar a tabela de lags para a fase 1
# Cada linha representa um dia em que a Fase 1 ocorreu durante o DJF
# As colunas vão de lag_-30 (Novembro, por exemplo) até lag_30 (Março, por exemplo)
head(tabelas_lags_fases$f1)

# Capturar os índices originais da tabela 'miri' que correspondem ao subconjunto DJF 'mirie'
indices_miri_no_djf <- as.numeric(rownames(miri_ext))

# Mapear os índices da 'miri' para cada fase (1 a 8)
fases_indices_miri <- lapply(1:8, function(f) {
  indices_miri_no_djf[which(miri_ext$Phase == f)]
})
names(fases_indices_miri) <- paste0("f", 1:8)

# 2. Função para calcular o composto médio de cada Lag


# 3. Gerar a tabela unificada para todas as fases
compostos_list <- lapply(1:8, function(f) {
  calcular_composto_fase(
    fase_num = f, 
    idx_miri = fases_indices_miri[[f]], 
    lags = lags, 
    dados_miri = mirisa
  )
})

# MIRISA2 positivo à esquerda; MIRISA1 positivo em cima
miri1 = c(-4,4)
miri2 = c(-4,4)

plot(NA, xlim = c(-4, 4), ylim = c(4, -4), xlab = "MIRISA1", ylab = "MIRISA2")
abline(v=0,h=0) ; lines(c(-4,0,4),c(-4,0,4)) ; lines(c(4,0,-4),c(-4,0,4))

lines(compostos_list[[1]]$MIRISA1c1[1:30],compostos_list[[1]]$MIRISA1c2[1:30],col=2,lwd=3)
lines(compostos_list[[8]]$MIRISA1c1[1:30],compostos_list[[8]]$MIRISA1c2[1:30],col=4,lwd=3)
lines(compostos_list[[7]]$MIRISA1c1[1:30],compostos_list[[7]]$MIRISA1c2[1:30],col="darkgreen",lwd=3)

############################################# 
# 
# 
#
# 3. Função para gerar a matriz de Lags (mapeando diretamente para a tabela 'miri')


# Empilhar todas as fases em uma única tabela
compostos_df <- do.call(rbind, compostos_list)

# 4. Salvar a tabela em arquivo TXT/CSV formatado
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

write.table(
  compostos_df, 
  file = output_files$compostos, 
  sep = ";", 
  row.names = FALSE, 
  quote = FALSE
)

cat("Tabela salva com sucesso em 'outputs/tables/COMPOSITES_MIRISA_LAG.txt'!\n")

# # # # # # # # # # # # # # # # # # # # # # # # #
nc <- nc_open(input_files$prec)

varname = 'precip'
varsize = nc$var[[varname]]$size

# Recupera coordenadas e tamanhos; os arrays seguem a ordem longitude, latitude, tempo.
x.prp <- nc$dim$lon   ; lon.prp <-x.prp$vals  ; nx.prp = varsize[1]
y.prp <- nc$dim$lat   ; lat.prp <-y.prp$vals  ; ny.prp = varsize[2]
t.prp <- nc$dim$time  ; time.prp<-t.prp$vals  ; nt.prp = varsize[3]

units<-strsplit(t.prp$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.prp$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.prp$vals * multiplicator
time.out<-as.character(as.Date(time.out))

nn.time = match(time.idx,time.out)

input<-array(numeric(),c(nx.prp,ny.prp,length(nn.time)))
j=1
# Le uma fatia espacial por dia e armazena todas as fatias no array input.
for( i in nn.time) {
    input[,,j] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
    j=j+1
                 }


  prp.miri<-array(numeric(),c(nx.prp,ny.prp,8))
  for (l in 1:8) {
  prp.miri[,,l]<-apply(input[,,fases_indices_miri[[l]]],2,rowMeans)
  }



# A dimensao Time abaixo armazena os modos 1 a 4, embora tenha unidade temporal.
# Os arquivos seguintes contêm padroes espaciais, e nao series diarias.
t <- ncdim_def( "Time", "day since 2026-10-07", 1:8, unlim=TRUE) # nolint: spaces_inside_linter.
PRP<- ncvar_def("prp","[mm/dia]",  list(x.prp,y.prp,t),-999999,prec="float" )
ncnew <- nc_create  (output_files$prec, list(PRP))
ncvar_put( ncnew,PRP,c(prp.miri))
nc_close(ncnew)


# # # # # # # # # # # # # # # # # # # # # # # # #
nc <- nc_open(input_files$olr)

varname = 'olr'
varsize = nc$var[[varname]]$size

# Recupera coordenadas e tamanhos; os arrays seguem a ordem longitude, latitude, tempo.
x.olr <- nc$dim$lon   ; lon.olr <-x.olr$vals  ; nx.olr = varsize[1]
y.olr <- nc$dim$lat   ; lat.olr <-y.olr$vals  ; ny.olr = varsize[2]
t.olr <- nc$dim$time  ; time.olr<-t.olr$vals  ; nt.olr = varsize[3]

units<-strsplit(t.olr$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.olr$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.olr$vals * multiplicator
time.out<-as.character(as.Date(time.out))

nn.time = match(time.idx,time.out)

input<-array(numeric(),c(nx.olr,ny.olr,length(nn.time)))
j=1
# Le uma fatia espacial por dia e armazena todas as fatias no array input.
for( i in nn.time) {
    input[,,j] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
    j=j+1
                 }


  olr.miri<-array(numeric(),c(nx.olr,ny.olr,8))
  for (l in 1:8) {
  olr.miri[,,l]<-apply(input[,,fases_indices_miri[[l]]],2,rowMeans)
  }


# A dimensao Time abaixo armazena os modos 1 a 4, embora tenha unidade temporal.
# Os arquivos seguintes contêm padroes espaciais, e nao series diarias.
t <- ncdim_def( "Time", "day since 2026-10-07", 1:8, unlim=TRUE)
olr<- ncvar_def("olr","[mm/dia]",  list(x.olr,y.olr,t),-999999,prec="float" )
ncnew <- nc_create  (output_files$olr, list(olr))
ncvar_put( ncnew,olr,c(olr.miri))
nc_close(ncnew)

# # # # # # # # # # # # # # # # # # # # # # # # #
nc <- nc_open(input_files$u85)

varname = 'uwnd'
varsize = nc$var[[varname]]$size

# Recupera coordenadas e tamanhos; os arrays seguem a ordem longitude, latitude, tempo.
x.u85 <- nc$dim$lon   ; lon.u85 <-x.u85$vals  ; nx.u85 = varsize[1]
y.u85 <- nc$dim$lat   ; lat.u85 <-y.u85$vals  ; ny.u85 = varsize[2]
t.u85 <- nc$dim$time  ; time.u85<-t.u85$vals  ; nt.u85 = varsize[3]

units<-strsplit(t.u85$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.u85$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.u85$vals * multiplicator
time.out<-as.character(as.Date(time.out))

nn.time = match(time.idx,time.out)

input<-array(numeric(),c(nx.u85,ny.u85,length(nn.time)))
j=1
# Le uma fatia espacial por dia e armazena todas as fatias no array input.
for( i in nn.time) {
    input[,,j] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
    j=j+1
                 }


  u85.miri<-array(numeric(),c(nx.u85,ny.u85,8))
  for (l in 1:8) {
  u85.miri[,,l]<-apply(input[,,fases_indices_miri[[l]]],2,rowMeans)
  }


# A dimensao Time abaixo armazena os modos 1 a 4, embora tenha unidade temporal.
# Os arquivos seguintes contêm padroes espaciais, e nao series diarias.
t <- ncdim_def( "Time", "day since 2026-10-07", 1:8, unlim=TRUE)
u85<- ncvar_def("u85","[mm/dia]",  list(x.u85,y.u85,t),-999999,prec="float" )
ncnew <- nc_create  (output_files$u85, list(u85))
ncvar_put( ncnew,u85,c(u85.miri))
nc_close(ncnew)

# # # # # # # # # # # # # # # # # # # # # # # # #
nc <- nc_open(input_files$v85)

varname = 'vwnd'
varsize = nc$var[[varname]]$size

# Recupera coordenadas e tamanhos; os arrays seguem a ordem longitude, latitude, tempo.
x.v85 <- nc$dim$lon   ; lon.v85 <-x.v85$vals  ; nx.v85 = varsize[1]
y.v85 <- nc$dim$lat   ; lat.v85 <-y.v85$vals  ; ny.v85 = varsize[2]
t.v85 <- nc$dim$time  ; time.v85<-t.v85$vals  ; nt.v85 = varsize[3]

units<-strsplit(t.v85$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.v85$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.v85$vals * multiplicator
time.out<-as.character(as.Date(time.out))

nn.time = match(time.idx,time.out)

input<-array(numeric(),c(nx.v85,ny.v85,length(nn.time)))
j=1
# Le uma fatia espacial por dia e armazena todas as fatias no array input.
for( i in nn.time) {
    input[,,j] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
    j=j+1
                 }


  v85.miri<-array(numeric(),c(nx.v85,ny.v85,8))
  for (l in 1:8) {
  v85.miri[,,l]<-apply(input[,,fases_indices_miri[[l]]],2,rowMeans)
  }


# A dimensao Time abaixo armazena os modos 1 a 4, embora tenha unidade temporal.
# Os arquivos seguintes contêm padroes espaciais, e nao series diarias.
t <- ncdim_def( "Time", "day since 2026-10-07", 1:8, unlim=TRUE)
v85<- ncvar_def("v85","[mm/dia]",  list(x.v85,y.v85,t),-999999,prec="float" )
ncnew <- nc_create  (output_files$v85, list(v85))
ncvar_put( ncnew,v85,c(v85.miri))
nc_close(ncnew)


