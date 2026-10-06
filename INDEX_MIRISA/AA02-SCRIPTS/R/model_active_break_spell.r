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

path1 = "Documents/NETE_PROJETOS/AB00-PROJETOS_NETE/MIRISA_PROJECT/"
setwd(path1)

source("AA02-SCRIPTS/R/Function_Data_nc_convert_20260320.R")

mirisa1<-read.table("AA03-RData_TxT/MIRISA_CLIM_19910401_20210331_CREATE_20260314.txt",sep=";",dec=".",header=T)
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
nc <- nc_open("AA03-NC_OUTPUT/mpi.1981.2022.nc")
rain = ncvar_get(nc, "precip", start=c(1,1,1),count=c(-1,-1,-1))
time_nc = data_nc_convert(nc)
    
mpi=data.frame(data = time_nc,mpi=rain)

####### Avaliando os tempos iguais 

nt_mpi = match(intersect(time_nc,as.character(data1)),time_nc)
nt_mri = match(intersect(time_nc,as.character(data1)),data1)

mpi_t = mpi[nt_mpi,]
mirisa_t = mirisa1[nt_mri,]
dados <- data.frame(data=mpi_t[,1],mirisa_t,mpi=mpi_t[,2])

####### comparar relação amplitude MRI e MPI








(df1 = aggregate(dados[,c(8,11)],list(dados$Phase,dados$Cat_amplitude_num),mean))
    
    
    # LIMIARES ESCOLHIDOS PARA AS AMPLITUDES
    #               (Inativa)      0.8   0  
    #          0.8  (Fraca)        1.2   1
    #          1.2  (Ativa)        1.6   2
    #          1.6  (Forte)        2.0   3
    #          2.0  (Extrema)            4




df2 = (aggregate(dados[,c(8,11)],list(dados$Phase,dados$Cat_amplitude_percentil),mean))














