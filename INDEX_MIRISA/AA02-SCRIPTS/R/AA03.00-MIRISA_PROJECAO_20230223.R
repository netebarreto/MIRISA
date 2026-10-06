#
# ROTINA QUE CALCULA A ANALISE DE MAXIMA COVARIANCIA 
#

# CHAMANDO AS ROTINAS, FUNÇÕES E BIBLIOTECA

rm(list=ls())

 
setwd("C:/Users/Nete/Documents/NETE_PROJETOS/AB00-PROJETOS_NETE/MIRISA_PROJECT/")
library("beepr")
library(ncdf4)
library(fields)


print(" Iniciando Etapa 0")

load("AA03-RData_TxT/MCA_SA_20230226.RData")


var_total <- diag(mca.dataset$C1_F1)  # variância total da chuva (covariância de F1)
var_modes <- diag(cov(mca.dataset$A)) # variância explicada pelos modos (lado da chuva)

frac_explicada <- var_modes / sum(var_total)
print(frac_explicada[1:5]*100)

##########################

nc <- nc_open("AA01-NC_INPUT/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.20180101.20260307.nc")
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

nc <- nc_open("AA01-NC_INPUT/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.20180101.20260307.nc")
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

nc <- nc_open("AA01-NC_INPUT/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.20180101.20260307.nc")
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


 F2 <- VAR.dataset 
     F2_cols_incl=1:length(F2[1,])
     F2 <- F2[,F2_cols_incl]       
 
    #setup for norm
    F2_val<-replace(F2, which(!is.na(F2)), 1)
    F2_val<-replace(F2_val, which(is.na(F2_val)), 0)

   #calc of expansion coefficient and scaling norm
    B_coeff <- replace(F2, which(is.na(F2)), 0)%*%(L$v[,1:nv]*-1)
    B_norm <- F2_val%*%((L$v[,1:nv]*-1)^2)
    B=B_coeff/B_norm



    mca.dataset<-list(
        Lambda=L$d, Lambda_err=Lambda_err,
        u=L$u[,1:nu], v=L$v[,1:nv], 
        expl_var=expl_var, sq_cov_frac=sq_cov_frac, 
        B=B)


print(" Iniciando Etapa 2")
#############################################################################
#===============================================================================
#===============================================================================


perfil1<-function(x2,x1){
        angl<-((atan2(x1,x2))*-180/pi)+180
        ampl<-round(sqrt(x1^2+x2^2),3)
        phase<-as.integer(angl/45)+1
        phase[phase==0]=8
        return(data.frame(Phase=phase,Amplitude=ampl))  
}

# Transformando em valores padronizados
coef.B1<-mca.dataset$B[,1]/sqrt(mca.dataset$Lambda[1]) 
coef.B2<-mca.dataset$B[,2]/sqrt(mca.dataset$Lambda[2])


index1=round(coef.B1,4)
index2=round(coef.B2,4)


indexT= perfil1(index1,index2)

units<-strsplit(t.olr$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.olr$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.olr$vals * multiplicator
time.out<-as.character(as.Date(time.out))


MIRI.SA<-data.frame(Year=substr(time.out,1,4),
    Month=substr(time.out,6,7),
    Day=substr(time.out,9,10),MIRISA1c1=index1, MIRISA1c2=index2,indexT)

data1 = format(Sys.Date(), "%Y%m%d") 

write.table(MIRI.SA,file=paste0("AA03-RData_TxT/MIRISA_REALT_20180101_20260307_CREATE_",data1,".txt"),sep=";",dec=".",col.names=T,row.names=FALSE)

print(" Terminou ")

