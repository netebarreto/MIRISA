#
# ROTINA QUE CALCULA A ANALISE DE MAXIMA COVARIANCIA 
#

# CHAMANDO AS ROTINAS, FUNÇÕES E BIBLIOTECA

# PREPARACAO DO AMBIENTE
# Remove os objetos da sessao atual para evitar interferencia de execucoes anteriores.
rm(list=ls())

# Define a raiz do projeto; os caminhos de entrada e saida abaixo sao relativos a ela.

# setwd("C:/Users/Nete/Documents/NETE_PROJETOS/AB00-PROJETOS_NETE/MIRISA_PROJECT/MIRISA_organizado/INDEX_MIRISA")
setwd("D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA/")
# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
#source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))

# Carrega as funcoes auxiliares; cov4gappy calcula covariancias com dados faltantes.
source("scripts/functions/R/cov4gappy.R")
source("scripts/functions/R/anomaly.R")

# ncdf4 permite ler/gravar NetCDF; fields fornece image.plot para os mapas.
library(ncdf4)
library(fields)

f1 <- function() {shell("cls")}

ystart = 1981
yend = 2020

files_input = list(
    prp = paste0("data/prec/padronizados/cpc/precip.sa.cpc-noaa.anom_padronizada.",ystart,"0101.",yend,"1231.nc"),
    olr = paste0("data/olr/padronizados/olr.noaa.v2.anom_padronizada.",ystart,"0101.",yend,"1231.nc"),
    u85 = paste0("data/uwnd/padronizados/ncep/850hPa/u85.ncep.anom_padronizada.",ystart,"0101.",yend,"1231.nc"),
    u20 = paste0("data/uwnd/padronizados/ncep/200hPa/u20.ncep.anom_padronizada.",ystart,"0101.",yend,"1231.nc"))

period <- paste0(ystart,"-",yend)
dtoday <- format(Sys.Date(), "%Y%m%d")

files_output = list(
    mca_result=paste0("outputs/models/MCA_SA_",ystart,"-",yend,"_",dtoday,".RData"),
    prec = paste0("outputs/netcdf/mca_pattern/",ystart,"-",yend,"/prec.mirisa.mca.cpc.",ystart,"0101.",yend,"1231_",dtoday,".nc"),
    olr=paste0("outputs/netcdf/mca_pattern/",ystart,"-",yend,"/olr.mirisa.mca.v01r02.",ystart,"0101.",yend,"1231_",dtoday,".nc"),
    uwnd=paste0("outputs/netcdf/mca_pattern/",ystart,"-",yend,"/uwnd.mirisa.mca.ncep-r1.",ystart,"0101.",yend,"1231_",dtoday,".nc"),
    mca_fcq=paste0("outputs/tables/mca_mirisa_fracao_covariancia_quadratica_",ystart,"-",yend,"_",dtoday,".txt"))

# Data fixa desta execucao. Os nomes dos arquivos de saida usam datas escritas diretamente.

print(" Iniciando Etapa 0")

# ETAPA 0 - LEITURA E ORGANIZACAO DOS CAMPOS
# Le os dados diarios previamente padronizados de precipitacao (rain).
# A MCA abaixo pressupoe campos ja preparados e datas alinhadas entre os arquivos.
nc <- nc_open(files_input$prp)

varname = 'precip'
varsize = nc$var[[varname]]$size

# Recupera coordenadas e tamanhos; os arrays seguem a ordem longitude, latitude, tempo.
x.prp <- nc$dim$lon   ; lon.prp <-x.prp$vals  ; nx.prp = varsize[1]
y.prp <- nc$dim$lat   ; lat.prp <-y.prp$vals  ; ny.prp = varsize[2]
t.prp <- nc$dim$time  ; time.prp<-t.prp$vals  ; nt.prp = varsize[3]

input<-array(numeric(),c(nx.prp,ny.prp,nt.prp))

# Le uma fatia espacial por dia e armazena todas as fatias no array input.
for( i in 1:nt.prp) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }

##########################
# Le a mascara espacial. As posicoes NA identificam pontos excluidos da precipitacao.

n.undef=attr(na.exclude(c(input[,,1]*0)),"na.action")

# Reorganiza o array: cada linha representa um dia e cada coluna um ponto da grade.
# A ordem espacial corresponde a longitude variando antes de latitude.
tmp1<-matrix(input,nrow=nt.prp,byrow=T) # transforma o array em ts

# Retira as colunas identificadas como ausentes na mascara.

{if (length(n.undef) > 0) 
    PRP.dataset <- tmp1[,-n.undef]
    else 
        PRP.dataset <- tmp1}

##########################

# Le o campo de radiacao de onda longa emergente (OLR) e suas coordenadas.
nc <- nc_open(files_input$olr)
varname = 'olr'
varsize = nc$var[[varname]]$size

x.olr <- nc$dim$lon  ; lon.olr <-x.olr$vals  ; nx.olr = varsize[1]
y.olr <- nc$dim$lat  ; lat.olr <-y.olr$vals  ; ny.olr = varsize[2]
t.olr <- nc$dim$time  ; time.olr <-t.olr$vals  ; nt.olr = varsize[3]

input.o<-array(numeric(),c(nx.olr,ny.olr,nt.olr))


for( i in 1:nt.olr ) {
    input.o[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }

# Converte OLR para a mesma estrutura tempo x pontos de grade.
OLR<-matrix(input.o,nrow=nt.olr,byrow=T) # transforma o array em ts


##########################

# Le o vento zonal a 200 hPa, depois organiza as series em tempo x pontos.
nc <- nc_open(files_input$u20)
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

# Le o vento zonal a 850 hPa, depois organiza as series em tempo x pontos.
nc <- nc_open(files_input$u85)
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

# Concatena as variaveis do segundo conjunto na ordem OLR, U85, U20.
# Essa ordem determina os blocos de linhas de v usados na exportacao dos modos.
VAR.dataset<-cbind(OLR,U85,U20)

##########################
##########################
print("##########################")
print(" Iniciando Etapa 1")


# ETAPA 1 - MATRIZ DE COVARIANCIA CRUZADA E DECOMPOSICAO
# F1 representa precipitacao; F2 reune OLR e os dois niveis de vento zonal.
 F1 <- PRP.dataset 
 F2 <- VAR.dataset 

 rm(PRP.dataset)
 rm(VAR.dataset)

 F1_ts <- rownames(F1)
 F2_ts <- rownames(F2)

 F1_dim <- dim(F1)
 F2_dim <- dim(F2)

 F1 <- as.matrix(F1)
 F2 <- as.matrix(F2)
 
# Cria indicadores de disponibilidade: 1 para valor valido e 0 para NA.
# O produto matricial conta os pares validos de dias para cada par de pontos espaciais.
 F1_val<-replace(F1, which(!is.na(F1)), 1)
 F1_val<-replace(F1_val, which(is.na(F1_val)), 0) 
 F2_val<-replace(F2, which(!is.na(F2)), 1)
 F2_val<-replace(F2_val, which(is.na(F2_val)), 0) 
 n_pairs=(t(F1_val)%*%F2_val)
 
# Substitui NA por zero para calcular os produtos apenas com as contribuicoes validas.
# Divide pelo numero de pares, sem subtrair medias nesta etapa; os dados devem
# chegar centrados para interpretar o resultado como covariancia cruzada.
 F1<-replace(F1, which(is.na(F1)), 0)
 F2<-replace(F2, which(is.na(F2)), 0)
 cov_mat <- (t(F1)%*%F2)/n_pairs
 C <- replace(cov_mat, which(is.na(cov_mat)), 0) 

# Define o numero de modos e decompoe C = u %*% diag(d) %*% t(v) por SVD.
# u e v sao padroes espaciais associados; d contem os valores singulares.
  nu=min(F1_dim[2], F2_dim[2])
  nv=min(F1_dim[2], F2_dim[2])
  L <- svd(C)

# Sinal sonoro: beep exige que a funcao do pacote beepr esteja disponivel na sessao.
  
# expl_var normaliza os valores singulares; sq_cov_frac normaliza seus quadrados.
# A fracao de covariancia quadratica mede a participacao de cada modo na MCA.
expl_var=L$d/sum(L$d) #explained variance
sq_cov_frac=L$d^2/sum(L$d^2) #squared covariance fraction

# Estima a incerteza dos valores singulares e verifica a separacao entre modos
# pelo criterio de North. Aqui, o fator usa o menor numero de colunas dos conjuntos.
 Lambda_err <- sqrt(2/min(F1_dim[2], F2_dim[2]))*L$d
 upper.lim <- L$d+Lambda_err
 lower.lim <- L$d-Lambda_err
 NORTHok=0*L$d

      for(i in seq(L$d)){
        Lambdas <- L$d
        Lambdas[i] <- NaN
        nearest <- which.min(abs(L$d[i]-Lambdas))
        if(nearest > i){
         if(lower.lim[i] > upper.lim[nearest]) NORTHok[i] <- 1
            }
         if(nearest < i){
          if(upper.lim[i] < lower.lim[nearest]) NORTHok[i] <- 1
           }
        }
# Conta os modos consecutivos separados antes do primeiro modo com NORTHok igual a zero.
 n_sig <- min(which(NORTHok==0))-1

  ##########################################################
    ###expansion of eof coefficients "principle components"###
    ##########################################################
 

print(" Iniciando Etapa 1b ")  

# ETAPA 1b - COEFICIENTES TEMPORAIS DOS MODOS
# Seleciona todas as colunas para projetar os campos nos vetores singulares.
  F1_cols_incl=1:length(F1[1,])
  F2_cols_incl=1:length(F2[1,])
    A_coeff = NULL
    A_norm = NULL
    A = NULL
    B_coeff = NULL
    B_norm = NULL
    B = NULL
 
    #trim columns of original data
    F1 <- as.matrix(F1[,F1_cols_incl])
 
    #setup for norm
    F1_val<-replace(F1, which(!is.na(F1)), 1)
    F1_val<-replace(F1_val, which(is.na(F1_val)), 0)
 
    #calc of expansion coefficient and scaling norm
# Projeta F1 nos modos u e divide pela soma dos pesos quadrados disponiveis.
# Como os NA de F1 ja foram convertidos em zero, F1_val nesta etapa indica
# todos os pontos como validos, inclusive aqueles originalmente ausentes.
    A_coeff <- replace(F1, which(is.na(F1)), 0)%*%L$u[,1:nu]
    A_norm <- F1_val%*%(L$u[,1:nu]^2)
    A=A_coeff/A_norm
 
    #trim columns of original data then center then scale
    F2 <- F2[,F2_cols_incl]       
 
    #setup for norm
    F2_val<-replace(F2, which(!is.na(F2)), 1)
    F2_val<-replace(F2_val, which(is.na(F2_val)), 0)
 
   #calc of expansion coefficient and scaling norm
# Repete a projecao e a normalizacao para F2 usando os modos v.
# A mesma observacao sobre os NA convertidos em zero se aplica a F2_val.
    B_coeff <- replace(F2, which(is.na(F2)), 0)%*%L$v[,1:nv]
    B_norm <- F2_val%*%(L$v[,1:nv]^2)
    B=B_coeff/B_norm

# Calcula as covariancias internas dos dois conjuntos usados na analise.
    C1_F1<- cov4gappy(F1)
    C1_F2<- cov4gappy(F2)

#      C1_A <- cov4gappy(A)
#      C1_B <- cov4gappy(B)

#      exp_var_u=diag(C1_A)/sum(diag(C1_F1))
#      exp_var_v=diag(C1_B)/sum(diag(C1_F2))      
  
# Agrupa valores singulares, padroes espaciais, fracoes e coeficientes temporais.
    mca.dataset<-list(
        Lambda=L$d, Lambda_err=Lambda_err,
        u=L$u[,1:nu], v=L$v[,1:nv], 
        expl_var=expl_var, sq_cov_frac=sq_cov_frac, 
        A=A, B=B,C1_F1=C1_F1,C1_F2=C1_F2)

########  Correção apenas para o intervalo de 1991 - 2020 
######## e para a segunda componente 
 if(period == "1991-2020")
    {
        mca.dataset$u[,2] =mca.dataset$u[,2]*-1 
        mca.dataset$v[,2] =mca.dataset$v[,2]*-1
        mca.dataset$A[,2] = mca.dataset$A[,2]*-1
        mca.dataset$B[,2] = mca.dataset$B[,2]*-1
    }    

print(" Iniciando Etapa 2")
  
#############################################################################
# ETAPA 2 - SALVAMENTO E EXPORTACAO DOS QUATRO PRIMEIROS MODOS
# Salva todos os objetos existentes neste ponto para recuperar a analise posteriormente.
save(list=ls(),file=files_output$mca_result)

#################################################### 

# Reinsere os modos da precipitacao na grade completa; pontos da mascara ficam NA.
lon.lat.prp<-expand.grid(lon.prp,lat.prp)
lon.lat.prp[,3:6]<-NA

if (length(n.undef) > 0)
    {lon.lat.prp[-n.undef,3:6] <- mca.dataset$u[,1:4]}
    else 
        {lon.lat.prp[,3:6] <- mca.dataset$u[,1:4]}

tmp1<-as.matrix(lon.lat.prp[,3:6])
output.prp<-array(tmp1,c(nx.prp,ny.prp,4)) 


# A dimensao Time abaixo armazena os modos 1 a 4, embora tenha unidade temporal.
# Os arquivos seguintes contêm padroes espaciais, e nao series diarias.
t <- ncdim_def( "Time", "day since 2026-10-07", 1:4, unlim=TRUE)
PRP<- ncvar_def("prp","[mm/dia]",  list(x.prp,y.prp,t),-999999,prec="float" )
ncnew <- nc_create  (files_output$prec, list(PRP))
ncvar_put( ncnew,PRP,c(output.prp))
nc_close(ncnew)

#===============================================================================

nx.var<-nx.olr
ny.var<-ny.olr

x.var<-x.olr
y.var<-y.olr

# Extrai o bloco OLR de v; os limites fixos pressupõem 360 pontos de OLR.
output.olr<-array(mca.dataset$v[1:191,1:4],c(nx.var,ny.var,4))
OLR<- ncvar_def("olr","[w/m2]", list(x.var,y.var,t),-999999,prec="float" )

ncnew <- nc_create(files_output$olr, list(OLR))

ncvar_put( ncnew,OLR,c(output.olr))
nc_close(ncnew)

nx.var<-nx.u85
ny.var<-ny.u85

x.var<-x.u85
y.var<-y.u85

# Extrai 144 pontos de U85 e 144 de U20, conforme a ordem de cbind.
# Ambos usam aqui as dimensoes e coordenadas da grade de U85.
output.u85<-array(mca.dataset$v[192:382,1:4],c(nx.var,ny.var,4))
output.u20<-array(mca.dataset$v[383:573,1:4],c(nx.var,ny.var,4))

U85<- ncvar_def("u85","[m/s]" , list(x.var,y.var,t),-999999,prec="float" )
U20<- ncvar_def("u20","[m/s]" , list(x.var,y.var,t),-999999,prec="float" )

ncnew <- nc_create(files_output$uwnd, list(U85,U20))

ncvar_put( ncnew,U85,c(output.u85))
ncvar_put( ncnew,U20,c(output.u20))

nc_close(ncnew)

#===============================================================================

# Exporta a fracao de covariancia quadratica dos quatro primeiros modos, arredondada.
 MCA.EV=data.frame(SCF=round(mca.dataset$sq_cov_frac[1:4],2))
 rownames(MCA.EV)=paste0("MCA",c(1:4))

write.table(MCA.EV,file=files_output$mca_fcq,sep=";",dec=".",col.names=T,row.names=FALSE)

print(" Terminou ")


# ####################################
