#
# ROTINA QUE CALCULA A ANALISE DE MAXIMA COVARIANCIA 
#

# CHAMANDO AS ROTINAS, FUNÇÕES E BIBLIOTECA

rm(list=ls())

source("R/AA00-Functions/val2col.R")
source("R/AA00-Functions/lon.lat.filter.R")
source("R/AA00-Functions/image.scale.R")
source("R/AA00-Functions/eof.mca.R")
source("R/AA00-Functions/cov4gappy.R")
source("R/AA00-Functions/color.palette.R")
source("R/AA00-Functions/anomaly.R")
 
library("beepr")
library(ncdf4)
library(fields)


data1 = 20230222#shell("date +%Y%m%d",intern=T)

print(" Iniciando Etapa 0")

nc <- nc_open("INPUT_NC/AC02-BTW_APAD_R/prec.AMS.apad.mca.daily.cpc.19910301.20200228.nc")

varname = 'precip'
varsize = nc$var[[varname]]$size

x.prp <- nc$dim$lon   ; lon.prp <-x.prp$vals  ; nx.prp = varsize[1]
y.prp <- nc$dim$lat   ; lat.prp <-y.prp$vals  ; ny.prp = varsize[2]
t.prp <- nc$dim$time  ; time.prp<-t.prp$vals  ; nt.prp = varsize[3]

input<-array(numeric(),c(nx.prp,ny.prp,nt.prp))

for( i in 1:nt.prp) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }

##########################
nc1 <- nc_open("INPUT_NC/AA00-REF_NC/AS.mask.20161231.nc")

temp1 = ncvar_get(nc1,"rain", start=c(1,1,1),count=c(-1,-1,1))

n.undef=attr(na.exclude(c(temp1)),"na.action")

tmp1<-matrix(input,nrow=nt.prp,byrow=T) # transforma o array em ts

PRP.dataset<-tmp1[,-n.undef]

##########################

nc <- nc_open("INPUT_NC/AC02-BTW_APAD_R/olr.apad.mca.daily.v01r02.19910301.20200228.nc")
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

nc <- nc_open("INPUT_NC/AC02-BTW_APAD_R/u20.apad.mca.daily.ncep.19910301.20200228.nc")
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

nc <- nc_open("INPUT_NC/AC02-BTW_APAD_R/u85.apad.mca.daily.ncep.19910301.20200228.nc")
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
 
 F1_val<-replace(F1, which(!is.na(F1)), 1)
 F1_val<-replace(F1_val, which(is.na(F1_val)), 0) 
 F2_val<-replace(F2, which(!is.na(F2)), 1)
 F2_val<-replace(F2_val, which(is.na(F2_val)), 0) 
 n_pairs=(t(F1_val)%*%F2_val)
 
 F1<-replace(F1, which(is.na(F1)), 0)
 F2<-replace(F2, which(is.na(F2)), 0)
 cov_mat <- (t(F1)%*%F2)/n_pairs
 C <- replace(cov_mat, which(is.na(cov_mat)), 0) 

  nu=min(F1_dim[2], F2_dim[2])
  nv=min(F1_dim[2], F2_dim[2])
  L <- svd(C)
beep(3)   
expl_var=L$d/sum(L$d) #explained variance
sq_cov_frac=L$d^2/sum(L$d^2) #squared covariance fraction

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
 n_sig <- min(which(NORTHok==0))-1

  ##########################################################
    ###expansion of eof coefficients "principle components"###
    ##########################################################
 

print(" Iniciando Etapa 1b ")  

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
    A_coeff <- replace(F1, which(is.na(F1)), 0)%*%L$u[,1:nu]
    A_norm <- F1_val%*%(L$u[,1:nu]^2)
    A=A_coeff/A_norm
 
    #trim columns of original data then center then scale
    F2 <- F2[,F2_cols_incl]       
 
    #setup for norm
    F2_val<-replace(F2, which(!is.na(F2)), 1)
    F2_val<-replace(F2_val, which(is.na(F2_val)), 0)
 
   #calc of expansion coefficient and scaling norm
    B_coeff <- replace(F2, which(is.na(F2)), 0)%*%L$v[,1:nv]
    B_norm <- F2_val%*%(L$v[,1:nv]^2)
    B=B_coeff/B_norm

    C1_F1<- cov4gappy(F1)
    C1_F2<- cov4gappy(F2)

#      C1_A <- cov4gappy(A)
#      C1_B <- cov4gappy(B)

#      exp_var_u=diag(C1_A)/sum(diag(C1_F1))
#      exp_var_v=diag(C1_B)/sum(diag(C1_F2))      
beep(3)    
    mca.dataset<-list(
        Lambda=L$d, Lambda_err=Lambda_err,
        u=L$u[,1:nu], v=L$v[,1:nv], 
        expl_var=expl_var, sq_cov_frac=sq_cov_frac, 
        A=A, B=B,C1_F1=C1_F1,C1_F2=C1_F2)


print(" Iniciando Etapa 2")
beep(1)   
#############################################################################
rm(F1) 
rm(F2)
save(list=ls(),file="AA03-RData_TxT/MCA_SA_20230222.RData")

### CORRECAO FORCADA, PARA O SINAL FICAREM IGUAIS AO DO ARTIGO ##### 
load(paste0("AA03-RData_TxT/MCA_SA_20230222.RData"))
#data1a = system("date +%Y%m%d",intern=T)


    mca.dataset<-list(
        Lambda=L$d, Lambda_err=Lambda_err,
        u=L$u[,1:nu], v=L$v[,1:nv]*-1, 
        expl_var=expl_var, sq_cov_frac=sq_cov_frac, 
        A=A, B=B*-1,C1_F1=C1_F1,C1_F2=C1_F2)

save(list=ls(),file="AA03-RData_TxT/MCA_SA_20230225.RData")

#################################################### 

lon.lat.prp<-expand.grid(lon.prp,lat.prp)
lon.lat.prp[,3:5]<-NA
lon.lat.prp[-n.undef,3:5]<-mca.dataset$u[,1:3]
tmp1<-as.matrix(lon.lat.prp[,3:5])
output.prp<-array(tmp1,c(nx.prp,ny.prp,3)) 



t <- ncdim_def( "Time", "day since 2017-01-01", 1:3, unlim=TRUE)
PRP<- ncvar_def("prp","[mm/dia]",  list(x.prp,y.prp,t),-999999,prec="float" )
ncnew <- nc_create  (paste0("AA03-NC_OUTPUT/PRP.MIRISA.",data1,".nc"), list(PRP))
ncvar_put( ncnew,PRP,c(output.prp))
nc_close(ncnew)
beep(1)
#===============================================================================

nx.var<-nx.olr
ny.var<-ny.olr

x.var<-x.olr
y.var<-y.olr

output.olr<-array(mca.dataset$v[1:360,1:3],c(nx.var,ny.var,3))
OLR<- ncvar_def("olr","[w/m2]", list(x.var,y.var,t),-999999,prec="float" )

ncnew <- nc_create(paste0("AA03-NC_OUTPUT/OLR.MIRISA.",data1,".nc"), list(OLR))

ncvar_put( ncnew,OLR,c(output.olr))
nc_close(ncnew)

nx.var<-nx.u85
ny.var<-ny.u85

x.var<-x.u85
y.var<-y.u85

output.u85<-array(mca.dataset$v[361:504,1:3],c(nx.var,ny.var,3))
output.u20<-array(mca.dataset$v[505:648,1:3],c(nx.var,ny.var,3))

U85<- ncvar_def("u85","[m/s]" , list(x.var,y.var,t),-999999,prec="float" )
U20<- ncvar_def("u20","[m/s]" , list(x.var,y.var,t),-999999,prec="float" )

ncnew <- nc_create(paste0("AA03-NC_OUTPUT/VAR.MIRISA.",data1,".nc"), list(U85,U20))

ncvar_put( ncnew,U85,c(output.u85))
ncvar_put( ncnew,U20,c(output.u20))

nc_close(ncnew)

beep(1)
#===============================================================================


perfil1<-function(x2,x1){
        angl<-((atan2(x1,x2))*-180/pi)+180
        ampl<-round(sqrt(x1^2+x2^2),3)
        phase<-as.integer(angl/45)+1
        phase[phase==0]=8
        return(data.frame(Phase=phase,Amplitude=ampl))  
}

# Transformando em valores padronizados
coef.A1<-mca.dataset$A[,1]/sqrt(mca.dataset$Lambda[1]) 
coef.A2<-mca.dataset$A[,2]/sqrt(mca.dataset$Lambda[2])
coef.B1<-mca.dataset$B[,1]/sqrt(mca.dataset$Lambda[1]) 
coef.B2<-mca.dataset$B[,2]/sqrt(mca.dataset$Lambda[2])


index1=round(coef.B1,4)
index2=round(coef.B2,4)


indexT= perfil1(index1,index2)

units<-strsplit(t.prp$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.prp$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.prp$vals * multiplicator
time.out<-as.character(as.Date(time.out))


MIRI.SA<-data.frame(Year=substr(time.out,1,4),
    Month=substr(time.out,6,7),
    day=substr(time.out,9,10),MIRISA1c1=index1, MIRISA1c2=index2,indexT)


write.table(MIRI.SA,file=paste0("AA03-RData_TxT/MIRISA_CLIM_19910301_20200228_CREATE_20230225.txt"),sep=";",dec=".",col.names=T,row.names=FALSE)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

 MCA.EV=data.frame(SCF=round(mca.dataset$sq_cov_frac[1:4],2))
 rownames(MCA.EV)=paste0("MCA",c(1:4))

write.table(MCA.EV,file=paste0("AA03-RData_txt/MCA_EV_20230225.txt"),sep=";",dec=".",col.names=T,row.names=FALSE)

print(" Terminou ")

beep(3)
