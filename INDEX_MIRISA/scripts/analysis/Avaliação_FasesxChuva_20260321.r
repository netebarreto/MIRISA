# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))
# ============================================================
# GLMM logístico para prever active e break spells de chuva
# com base no MIRISA
#
# Requer:
# install.packages(c("dplyr", "lme4", "pROC"))
# ============================================================

library(dplyr)
library(lme4)
library(pROC)
library(ncdf4)

f1 <- function(){shell("cls")}



source("scripts/functions/R/Function_Data_nc_convert_20260320.R")

mirisa1<-read.table("outputs/tables/MIRISA_CLIM_19910401_20210331_CREATE_20260314.txt",sep=";",dec=".",header=T)
data1=as.Date(paste(mirisa1[,1],mirisa1[,2],mirisa1[,3],sep="-")) 

#round(quantile(mirisa1$Amplitude,prob=c(0.2,0.4,0.6,0.8,0.95)),1)
#20% 40% 60% 80% 95% 
#               (Inativa)      0.6   0  
#          0.6  (Fraca)        0.8   1
#          0.8  (Ativa)        1.2   2
#          1.2  (Forte)        1.5   3
#          1.5  (Muito Forte)  2.1   4 
#          2.1  (Extrema)            5

mirisa1$Cat_amplitude_percentil = findInterval(mirisa1$Amplitude,round(quantile(mirisa1$Amplitude,prob=c(0.2,0.4,0.6,0.8,0.95)),1))

mirisa1$Cat_amplitude_num = findInterval(mirisa1$Amplitude,c(0.8,1.2,1.6,2.0))

#### 
nc <- nc_open("outputs/netcdf/mpi.1981.2022.nc")
rain = ncvar_get(nc, "precip", start=c(1,1,1),count=c(-1,-1,-1))
time_nc = data_nc_convert(nc)
    
mpi=data.frame(data = time_nc,mpi=rain)

####### Avaliando os tempos iguais 

nt_mpi = match(intersect(time_nc,as.character(data1)),time_nc)
nt_mri = match(intersect(time_nc,as.character(data1)),data1)

mpi_t = mpi[nt_mpi,]
mirisa_t = mirisa1[nt_mri,]
dados <- data.frame(data=mpi_t[,1],mirisa_t,mpi=mpi_t[,2])
 
    # LIMIARES ESCOLHIDOS PARA AS AMPLITUDES
    #               (Inativa)      0.8   0  
    #          0.8  (Fraca)        1.2   1
    #          1.2  (Ativa)        1.6   2
    #          1.6  (Forte)        2.0   3
    #          2.0  (Extrema)            4

####### comparar relação amplitude MRI e MPI

dados$seas = NA 
dados$seas[dados$Month %in% c(12,1,2)] = "DJF"
dados$seas[dados$Month %in% c(3,4,5)] = "MAM"
dados$seas[dados$Month %in% c(6,7,8)] = "JJA"
dados$seas[dados$Month %in% c(9,10,11)] = "SON"


miri1 = subset(dados,dados$seas == "DJF")
miri2 = subset(dados,dados$seas == "MAM")
miri3 = subset(dados,dados$seas == "JJA")
miri4 = subset(dados,dados$seas == "SON")


library("ncdf4")
nc <- nc_open("data/prec/filtrados/cpc/historico/butterworth_signal/apreci.AMS.day.btw.19820101.20161231.nc")
varname = 'precip'
varsize = nc$var[[varname]]$size


##########################
nc1 <- nc_open("data/static/masks/AS.mask.20161231.nc")

mask = ncvar_get(nc1,"rain", start=c(1,1,1),count=c(-1,-1,1))

##################################################################
  x.pr <- nc$dim$lon   ; lon.pr <-x.pr$vals  ; nx.pr = varsize[1]
  y.pr <- nc$dim$lat   ; lat.pr <-y.pr$vals  ; ny.pr = varsize[2]
  t.pr <- nc$dim$time  ; time.pr<-t.pr$vals  ; nt.pr = varsize[3] 

units<-strsplit(t.pr$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.pr$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.pr$vals * multiplicator
time.out<-as.character(as.Date(time.out))

int_time1 = match(intersect(time.out,as.character(data1[nt_mri])),time.out)

int_time2 = match(intersect(time.out,as.character(data1[nt_mri])),as.character(data1[nt_mri]))
dados2 = dados[int_time2,]
miri1 = subset(dados2,dados2$seas == "DJF")

f8<-which(miri1$Phase==8 )
f1<-which(miri1$Phase==1 )
f2<-which(miri1$Phase==2 )
f3<-which(miri1$Phase==3 )
f4<-which(miri1$Phase==4 )
f5<-which(miri1$Phase==5 )
f6<-which(miri1$Phase==6 )
f7<-which(miri1$Phase==7 )

input.pr = ncvar_get(nc, "rain" ,start=c(1,1,1),count=c(-1,-1,-1)) 
rain = input.pr[,,int_time1]
rain2 = rain[,,which(dados2$seas == "DJF")]



raincf6 = apply(rain2[,,f6],2,rowMeans,na.rm=TRUE)
image.plot(raincf6)

raincf7 = apply(rain2[,,f7],2,rowMeans,na.rm=TRUE)
image.plot(raincf7)

raincf8 = apply(rain2[,,f8],2,rowMeans,na.rm=TRUE)
image.plot(raincf8)

raincf1 = apply(rain2[,,f1],2,rowMeans,na.rm=TRUE)
image.plot(raincf1)

raincf3 = apply(rain2[,,f3],2,rowMeans,na.rm=TRUE)
image.plot(raincf3)

######################################

table(miri1$Phase)

