#
#
#
#


rm(list=ls())


# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))

testt<-function(x){
  ifelse(all(is.na(x)), NA,
    ifelse(t.test(x,mu=0,alternative="two",conf.level=0.95)$p.value<0.05,t.test(x,mu=0,alternative="two",conf.level=0.95)$estimate,NA))
      }
mat.anomt <- function(x) {
  zz<-function(xx) apply(xx,1,testt)
    zz1 <- aperm(apply(x,1,zz)) }

testt.uv<-function(x){
  ifelse(all(is.na(x)), 0,
    ifelse(t.test(x,mu=0,alternative="two",conf.level=0.95)$p.value<0.05,t.test(x,mu=0,alternative="two",conf.level=0.95)$estimate,0))
      }
mat.anomt.uv <- function(x) {
  zz<-function(xx) apply(xx,1,testt.uv)
    zz1 <- aperm(apply(x,1,zz)) }


library(ncdf4)
library(fields)
library(beepr)

miri<-read.table("outputs/tables/MIRISA_CLIM_19910301_20210228_CREATE_20261007.txt",sep=";",dec=".",header=T)
data=as.Date(paste(miri[,1],miri[,2],miri[,3],sep="-")) 


djf<-subset(miri,((Month<=2 | Month==12) & Amplitude>=1.1))

data.djf=as.Date(paste(djf[,1],djf[,2],djf[,3],sep="-")) 

f8<-which(djf[,6]==8 )
f1<-which(djf[,6]==1 )
f2<-which(djf[,6]==2 )
f3<-which(djf[,6]==3 )
f4<-which(djf[,6]==4 )
f5<-which(djf[,6]==5 )
f6<-which(djf[,6]==6 )
f7<-which(djf[,6]==7 )

######################################################################
library("ncdf4")
nc <- nc_open("data/prec/filtrados/cpc/prec.AMS.abtw.daily.cpc.19910301.20210228.nc")
varname = 'rain'
varsize = nc$var[[varname]]$size


##########################
nc1 <- nc_open("data/static/masks/AS.mask.20161231.nc")

mask = ncvar_get(nc1,"rain", start=c(1,1,1),count=c(-1,-1,1))

##################################################################
  x.pr <- nc$dim$lon   ; lon.pr <-x.pr$vals  ; nx.pr = varsize[1]
  y.pr <- nc$dim$lat   ; lat.pr <-y.pr$vals  ; ny.pr = varsize[2]
  t.pr <- nc$dim$time  ; time.pr<-t.pr$vals  ; nt.pr = varsize[3] 

units<-strsplit(t.prp$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.prp$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.prp$vals * multiplicator
time.out<-as.character(as.Date(time.out))

  nt.f=list(f1=match(as.character(data.djf[f1]),time.out),
            f2=match(as.character(data.djf[f2]),time.out),
            f3=match(as.character(data.djf[f3]),time.out),
            f4=match(as.character(data.djf[f4]),time.out),
            f5=match(as.character(data.djf[f5]),time.out),
            f6=na.exclude(match(as.character(data.djf[f6]),time.out)),
            f7=match(as.character(data.djf[f7]),time.out),
            f8=match(as.character(data.djf[f8]),time.out))


  prp.miri<-array(numeric(),c(nx.prp,ny.prp,8))

    input = ncvar_get(nc, varname, start=c(1,1,1),count=c(-1,-1,-1))

  for (l in 1:8) {
  prp.miri[,,l]<-apply(input[,,nt.f[[l]]],2,rowMeans)
  }

