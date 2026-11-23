#
# ROTINA QUE CALCULA A ANALISE DE MAXIMA COVARIANCIA 
#

# CHAMANDO AS ROTINAS, FUNÇÕES E BIBLIOTECA

rm(list=ls())

 

# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
# source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))

library(ncdf4)
library(fields)


print(" Iniciando Etapa 0")

load("D:/NETE_PROJETOS/MIRISA/MIRISA_GITHUB/INDEX_MIRISA/outputs/models/MCA_SA_1991-2020_20261111.RData")

mca_ref <- mca.dataset

##########################

nc <- nc_open("D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/prec/padronizados/cpc-noaa/precip.sa.cpc-noaa.anom_padronizada.20200101.20251231.nc")
varname = 'precip'
varsize = nc$var[[varname]]$size

x.prec <- nc$dim$lon  ; lon.prec <-x.prec$vals  ; nx.prec = varsize[1]
y.prec <- nc$dim$lat  ; lat.prec <-y.prec$vals  ; ny.prec = varsize[2]
t.prec <- nc$dim$time  ; time.prec <-t.prec$vals  ; nt.prec = varsize[3]


input.p = ncvar_get(nc, varname, start=c(1,1,1),count=c(-1,-1,-1))


##########################
# Le a mascara espacial. As posicoes NA identificam pontos excluidos da precipitacao.

n.undef=attr(na.exclude(c(input.p[,,1]*0)),"na.action")

# Reorganiza o array: cada linha representa um dia e cada coluna um ponto da grade.
# A ordem espacial corresponde a longitude variando antes de latitude.
tmp1<-matrix(input.p,nrow=nt.prec,byrow=T) # transforma o array em ts

# Retira as colunas identificadas como ausentes na mascara.

{if (length(n.undef) > 0) 
    PRP.dataset <- tmp1[,-n.undef]
    else 
        PRP.dataset <- tmp1}


##########################

nc <- nc_open("D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/olr/padronizados/olr.noaa.v2.anom_padronizada.20200101.20251231.nc")
varname = 'olr'
varsize = nc$var[[varname]]$size

x.olr <- nc$dim$lon  ; lon.olr <-x.olr$vals  ; nx.olr = varsize[1]
y.olr <- nc$dim$lat  ; lat.olr <-y.olr$vals  ; ny.olr = varsize[2]
t.olr <- nc$dim$time  ; time.olr <-t.olr$vals  ; nt.olr = varsize[3]

input.o<-array(numeric(),c(nx.olr,ny.olr,nt.olr))


for( i in 1:nt.olr ) {
    input.o[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }

OLR<-matrix(input.o,nrow=nt.olr,byrow=T) # transforma o array em ts


##########################

nc <- nc_open("D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/uwnd/padronizados/ncep_r1/200hpa/u20.ncep.anom_padronizada.20200101.20251231.nc")

varname = 'uwnd'
varsize = nc$var[[varname]]$size

x.u20 <- nc$dim$lon  ; lon.u20 <-x.u20$vals  ; nx.u20 = varsize[1]
y.u20 <- nc$dim$lat  ; lat.u20 <-y.u20$vals  ; ny.u20 = varsize[2]
t.u20 <- nc$dim$time  ; time.u20 <-t.u20$vals  ; nt.u20 = varsize[3]

input.u20<-array(numeric(),c(nx.u20,ny.u20,nt.u20))


for( i in 1:nt.u20 ) {
    input.u20[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }

U20<-matrix(input.u20,nrow=nt.u20,byrow=T) # transforma o array em ts

##########################

nc <- nc_open("D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/uwnd/padronizados/ncep_r1/850hpa/u85.ncep.anom_padronizada.20200101.20251231.nc")
varname = 'uwnd'
varsize = nc$var[[varname]]$size

x.u85 <- nc$dim$lon  ; lon.u85 <-x.u85$vals  ; nx.u85 = varsize[1]
y.u85 <- nc$dim$lat  ; lat.u85 <-y.u85$vals  ; ny.u85 = varsize[2]
t.u85 <- nc$dim$time  ; time.u85 <-t.u85$vals  ; nt.u85 = varsize[3]

input.u85<-array(numeric(),c(nx.u85,ny.u85,nt.u85))


for( i in 1:nt.u85 ) {
    input.u85[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }

U85<-matrix(input.u85,nrow=nt.u85,byrow=T) # transforma o array em ts

VAR.dataset<-cbind(OLR,U85,U20)

##########################
##########################
print("##########################")
print(" Iniciando Etapa 1")

# Na projeção:
U <- mca_ref$u[, 1:2, drop = FALSE]
V <- mca_ref$v[, 1:2, drop = FALSE]

    A_coeff = NULL
    A_norm = NULL
    A = NULL
    B_coeff = NULL
    B_norm = NULL
    B = NULL
 
    #trim columns of original data
    F1 = PRP.dataset
    F1_cols_incl=1:length(F1[1,])
    F1 <- as.matrix(F1[,F1_cols_incl])
 
    #setup for norm
    F1_val<-replace(F1, which(!is.na(F1)), 1)
    F1_val<-replace(F1_val, which(is.na(F1_val)), 0)
 
    A_coeff <- replace(F1, which(is.na(F1)), 0) %*% U
    A_norm  <- F1_val %*% (U^2)
    A <- A_coeff / A_norm


     F2 <- VAR.dataset 
     F2_cols_incl=1:length(F2[1,])
     F2 <- F2[,F2_cols_incl]       
 
    #setup for norm
    F2_val<-replace(F2, which(!is.na(F2)), 1)
    F2_val<-replace(F2_val, which(is.na(F2_val)), 0)

   #calc of expansion coefficient and scaling norm

    B_coeff <- replace(F2, which(is.na(F2)), 0) %*% V
    B_norm  <- F2_val %*% (V^2)
    B <- B_coeff / B_norm


    mca.dataset<-list(
        Lambda=L$d, Lambda_err=Lambda_err,
        u=L$u[,1:nu], v=L$v[,1:nv], 
        expl_var=expl_var, sq_cov_frac=sq_cov_frac, 
        B=B,A=A)


print(" Iniciando Etapa 2")
#############################################################################
#===============================================================================
#===============================================================================

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
units<-strsplit(t.prec$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.prec$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.prec$vals * multiplicator
time.idx<-as.character(as.Date(time.out))


# Monta a tabela diaria: ano, mes, dia, duas componentes, fase e amplitude.
mirisa<-data.frame(Year=substr(time.idx,1,4),
    Month=substr(time.idx,6,7),
    day=substr(time.idx,9,10),MIRISA1c1=index1, MIRISA1c2=index2,indexT,dataset="ncep_r1",periodo="projetado")

mirisa_clim <- read.csv("D:/NETE_PROJETOS/MIRISA/MIRISA_GITHUB/INDEX_MIRISA/outputs/tables/mirisa_clim_19910101.20201231_CREATE_20261111.txt",sep=";",dec=".")

rec_clim<- tail(mirisa_clim,365)

data_clim=as.Date(paste(mirisa_clim[,1],mirisa_clim[,2],mirisa_clim[,3],sep="-"))

comum_data <- intersect(as.character(data_clim),time.idx)

nn1 = match(comum_data,time.idx)

mirisa_all <- rbind(mirisa_clim,mirisa[-nn1,])
dtoday = format(Sys.Date(), "%Y%m%d") 

write.table(mirisa_all,file=paste0("D:/NETE_PROJETOS/MIRISA/MIRISA_GITHUB/INDEX_MIRISA/outputs/tables/mirisa_proj_19910101.20251231_CREATE_",dtoday,".txt"),sep=";",dec=".",col.names=T,row.names=FALSE)

print(" Terminou ")


