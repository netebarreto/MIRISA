#
# ROTINA QUE CALCULA A ANALISE DE MAXIMA COVARIANCIA 
#

# CHAMANDO AS ROTINAS, FUNÇÕES E BIBLIOTECA

# PREPARACAO DO AMBIENTE
# Remove os objetos da sessao atual para evitar interferencia de execucoes anteriores.
rm(list=ls())

# Define a raiz do projeto; os caminhos de entrada e saida abaixo sao relativos a ela.
setwd("C:/Users/Nete/Documents/NETE_PROJETOS/AB00-PROJETOS_NETE/MIRISA_PROJECT/MIRISA_organizado/INDEX_MIRISA")
# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
#source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))

# Carrega as funcoes auxiliares; cov4gappy calcula covariancias com dados faltantes.
source("scripts/functions/R/cov4gappy.r")
source("scripts/functions/R/anomaly.R")
 
#library("beepr")
# ncdf4 permite ler/gravar NetCDF; fields fornece image.plot para os mapas.
library(ncdf4)
library(fields)


# Data fixa desta execucao. Os nomes dos arquivos de saida usam datas escritas diretamente.
data1 = 20261007#shell("date +%Y%m%d",intern=T)

print(" Iniciando Etapa 0")

# ETAPA 0 - LEITURA E ORGANIZACAO DOS CAMPOS
# Le os dados diarios previamente padronizados de precipitacao (rain).
# A MCA abaixo pressupoe campos ja preparados e datas alinhadas entre os arquivos.
nc <- nc_open("data/prec/padronizados/cpc/prec.AMS.apad.mca.daily.cpc.19910301.20210228.nc")

varname = 'rain'
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
nc1 <- nc_open("data/static/masks/AS.mask.20161231.nc")

temp1 = ncvar_get(nc1,"rain", start=c(1,1,1),count=c(-1,-1,1))

n.undef=attr(na.exclude(c(temp1)),"na.action")

# Reorganiza o array: cada linha representa um dia e cada coluna um ponto da grade.
# A ordem espacial corresponde a longitude variando antes de latitude.
tmp1<-matrix(input,nrow=nt.prp,byrow=T) # transforma o array em ts

# Retira as colunas identificadas como ausentes na mascara.
PRP.dataset<-tmp1[,-n.undef]

##########################

# Le o campo de radiacao de onda longa emergente (OLR) e suas coordenadas.
nc <- nc_open("data/olr/padronizados/olr.apad.mca.daily.v01r02.19910301.20210228.nc")
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
nc <- nc_open("data/uwnd/padronizados/ncep/200hpa/u20.apad.mca.daily.ncep.19910301.20210228.nc")
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
nc <- nc_open("data/uwnd/padronizados/ncep/850hpa/u85.apad.mca.daily.ncep.19910301.20210228.nc")
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
beep(3)   
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


print(" Iniciando Etapa 2")
  
#############################################################################
# ETAPA 2 - SALVAMENTO E EXPORTACAO DOS QUATRO PRIMEIROS MODOS
# Salva todos os objetos existentes neste ponto para recuperar a analise posteriormente.
save(list=ls(),file="outputs/models/MCA_SA_20261007.RData")

#################################################### 

# Reinsere os modos da precipitacao na grade completa; pontos da mascara ficam NA.
lon.lat.prp<-expand.grid(lon.prp,lat.prp)
lon.lat.prp[,3:6]<-NA
lon.lat.prp[-n.undef,3:6]<-mca.dataset$u[,1:4]
tmp1<-as.matrix(lon.lat.prp[,3:6])
output.prp<-array(tmp1,c(nx.prp,ny.prp,4)) 


# A dimensao Time abaixo armazena os modos 1 a 4, embora tenha unidade temporal.
# Os arquivos seguintes contêm padroes espaciais, e nao series diarias.
t <- ncdim_def( "Time", "day since 2026-10-07", 1:4, unlim=TRUE)
PRP<- ncvar_def("prp","[mm/dia]",  list(x.prp,y.prp,t),-999999,prec="float" )
ncnew <- nc_create  (paste0("outputs/netcdf/prec.mirisa.mca.cpc.19910301.20210228.nc"), list(PRP))
ncvar_put( ncnew,PRP,c(output.prp))
nc_close(ncnew)

#===============================================================================

nx.var<-nx.olr
ny.var<-ny.olr

x.var<-x.olr
y.var<-y.olr

# Extrai o bloco OLR de v; os limites fixos pressupõem 360 pontos de OLR.
output.olr<-array(mca.dataset$v[1:360,1:4],c(nx.var,ny.var,4))
OLR<- ncvar_def("olr","[w/m2]", list(x.var,y.var,t),-999999,prec="float" )

ncnew <- nc_create(paste0("outputs/netcdf/olr.mirisa.mca.v01r02.19910301.20210228.nc"), list(OLR))

ncvar_put( ncnew,OLR,c(output.olr))
nc_close(ncnew)

nx.var<-nx.u85
ny.var<-ny.u85

x.var<-x.u85
y.var<-y.u85

# Extrai 144 pontos de U85 e 144 de U20, conforme a ordem de cbind.
# Ambos usam aqui as dimensoes e coordenadas da grade de U85.
output.u85<-array(mca.dataset$v[361:504,1:4],c(nx.var,ny.var,4))
output.u20<-array(mca.dataset$v[505:648,1:4],c(nx.var,ny.var,4))

U85<- ncvar_def("u85","[m/s]" , list(x.var,y.var,t),-999999,prec="float" )
U20<- ncvar_def("u20","[m/s]" , list(x.var,y.var,t),-999999,prec="float" )

ncnew <- nc_create(paste0("outputs/netcdf/uwnd.mirisa.mca.ncep-r1.19910301.20210228.nc"), list(U85,U20))

ncvar_put( ncnew,U85,c(output.u85))
ncvar_put( ncnew,U20,c(output.u20))

nc_close(ncnew)

beep(1)
#===============================================================================


# INDICE MIRISA - COMPONENTES, AMPLITUDE E FASE
# Converte as duas componentes em angulo e amplitude; setores de 45 graus definem a fase.
# A ordem dos argumentos (x2, x1) determina a orientacao do angulo em atan2.
perfil1<-function(x2,x1){
        angl<-((atan2(x1,x2))*-180/pi)+180
        ampl<-round(sqrt(x1^2+x2^2),3)
        phase<-as.integer(angl/45)+1
        phase[phase==0]=8
        return(data.frame(Phase=phase,Amplitude=ampl))  
}

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

indexT= perfil1(index1,index2)

# Converte o tempo NetCDF em datas usando a unidade e a origem do atributo units.
# O switch reconhece days, hours, minutes e seconds; a origem e interpretada em UTC.
units<-strsplit(t.prp$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.prp$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.prp$vals * multiplicator
time.out<-as.character(as.Date(time.out))


# Monta a tabela diaria: ano, mes, dia, duas componentes, fase e amplitude.
miri.sa<-data.frame(Year=substr(time.out,1,4),
    Month=substr(time.out,6,7),
    day=substr(time.out,9,10),MIRISA1c1=index1, MIRISA1c2=index2,indexT)


# Exporta o indice diario em texto separado por ponto e virgula, sem nomes de linhas.
write.table(miri.sa,file=paste0("outputs/tables/mirisa_clim_19910301_20210228_CREATE_20261007.txt"),sep=";",dec=".",col.names=T,row.names=FALSE)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Exporta a fracao de covariancia quadratica dos quatro primeiros modos, arredondada.
 MCA.EV=data.frame(SCF=round(mca.dataset$sq_cov_frac[1:4],2))
 rownames(MCA.EV)=paste0("MCA",c(1:4))

write.table(MCA.EV,file=paste0("outputs/tables/mca_mirisa_fracao_covariancia_quadratica_20261007.txt"),sep=";",dec=".",col.names=T,row.names=FALSE)

print(" Terminou ")


####################################

# ANALISES EXPLORATORIAS - COMPOSTOS SAZONAIS E CORRELACOES
# Cria uma copia da tabela e classifica a amplitude em faixas (codigos de 0 a 6).
miri=miri.sa

miri[,8] <- findInterval(miri[,7],c(0.8,1.0,1.2,1.5,2.0,2.5))

# Seleciona dezembro, janeiro e fevereiro (DJF); nn guarda os indices na serie completa.
mirie<-subset(miri,(Month==12 | Month=="02"| Month=="01"))
nn = as.numeric(rownames(mirie))

# data.djf=as.Date(paste(mirie[,1],mirie[,2],mirie[,3],sep="-")) 

# Localiza cada fase dentro do subconjunto DJF; esses indices sao relativos a mirie.
f8<-which(mirie[,6]==8 )
f1<-which(mirie[,6]==1 )
f2<-which(mirie[,6]==2 )
f3<-which(mirie[,6]==3 )
f4<-which(mirie[,6]==4 )
f5<-which(mirie[,6]==5 )
f6<-which(mirie[,6]==6 )
f7<-which(mirie[,6]==7 )

# Define a ordem dos compostos: fase 8, depois fases 1 a 7.
nt.f<-list(f8,f1,f2,f3,f4,f5,f6,f7)

  prp.miri<-array(numeric(),c(nx.prp,ny.prp,8))

# Converte os indices de cada fase para a serie completa com nn e calcula
# a media temporal da precipitacao em cada ponto, multiplicando pela mascara.
  for (l in 1:8) {
  prp.miri[,,l]<-apply(input[,,nn[nt.f[[l]]]],2,rowMeans)*temp1
  }

 image.plot(prp.miri[,,1])


# Calcula a correlacao ponto a ponto com a primeira componente usando os indices f5.
# Atencao: f5 foi obtido em mirie, mas aqui indexa input e miri diretamente,
# sem a conversao nn[f5] empregada nos compostos acima.
mapa_cor <- apply(
  input[,,f5],
  MARGIN = c(1, 2),
  FUN = function(x) cor(x, miri[f5,4], use = "pairwise.complete.obs")
)
image.plot(mapa_cor*temp1)

# Calcula a correlacao entre toda a serie de precipitacao e a segunda componente.
# pairwise.complete.obs usa apenas pares validos; a mascara e aplicada ao mapa.
mapa_cor2 <- apply(
  input,
  MARGIN = c(1, 2),
  FUN = function(x) cor(x, miri[,5], use = "pairwise.complete.obs")
)
image.plot(mapa_cor2*temp1)

