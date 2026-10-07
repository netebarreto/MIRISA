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

miri<-read.table("outputs/tables/MIRISA_CLIM_19910301_20200228_CREATE_20230225.txt",sep=";",dec=".",header=T)


miri.djf.e<-miri[((miri[,1]>=1991 & miri[,1]<=2020) & (miri[,2]==12 | miri[,2]<=2) & (miri[,7]>=1.5)),]

data.djf=as.Date(paste(miri.djf.e[,1],miri.djf.e[,2],miri.djf.e[,3],sep="-")) 

f8<-which(miri.djf.e[,6]==8 )
f1<-which(miri.djf.e[,6]==1 )
f2<-which(miri.djf.e[,6]==2 )
f3<-which(miri.djf.e[,6]==3 )
f4<-which(miri.djf.e[,6]==4 )
f5<-which(miri.djf.e[,6]==5 )
f6<-which(miri.djf.e[,6]==6 )
f7<-which(miri.djf.e[,6]==7 )

######################################################################
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

  nt.f=list(f1=match(as.character(data.djf[f1]),time.out),
            f2=match(as.character(data.djf[f2]),time.out),
            f3=match(as.character(data.djf[f3]),time.out),
            f4=match(as.character(data.djf[f4]),time.out),
            f5=match(as.character(data.djf[f5]),time.out),
            f6=match(as.character(data.djf[f6]),time.out),
            f7=match(as.character(data.djf[f7]),time.out),
            f8=match(as.character(data.djf[f8]),time.out))


  prp.miri<-array(numeric(),c(nx.pr,ny.pr,8))

  for (l in 1:8) {
  input.pr<-array(numeric(),c(nx.pr,ny.pr,length(nt.f[[l]])))
  
   for( i in 1:length(nt.f[[l]])) {
    input.pr[,,i] = ncvar_get(nc, varname,
                   start=c(1,1,nt.f[[l]][i]),count=c(-1,-1,1)) }
  prp.miri[,,l]<-mat.anomt(input.pr)*mask
  }


  
  t <- ncdim_def( "time", "day since 2012-01-01", c(1:8), unlim=TRUE) 
  # definindo a variavel
  PRP1<- ncvar_def("miripr","[mm/dia]",  list(x.pr,y.pr,t),-999999,prec="float" )
 
  ncnew <- nc_create(paste0("outputs/netcdf/MIRISA.PHASES.PRP.20230225_2.nc"), list(PRP1))
  ncvar_put( ncnew,PRP1,c(prp.miri))
  nc_close(ncnew)

#
#####################################################################
#
nc <- nc_open("data/olr/filtrados/v01r02/historico/butterworth_signal/olr.abtw.daily.v01r02.19910301.20211231.nc")
varname = 'olr'
varsize = nc$var[[varname]]$size

  x.olr <- nc$dim$lon   ; lon.olr <-x.olr$vals  ; nx.olr = varsize[1]
  y.olr <- nc$dim$lat   ; lat.olr <-y.olr$vals  ; ny.olr = varsize[2]
  t.olr <- nc$dim$time  ; time.olr<-t.olr$vals  ; nt.olr = varsize[3] 


units<-strsplit(t.olr$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.olr$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.olr$vals * multiplicator
time.out<-as.character(as.Date(time.out))

  nt.f=list(f1=match(as.character(data.djf[f1]),time.out),
            f2=match(as.character(data.djf[f2]),time.out),
            f3=match(as.character(data.djf[f3]),time.out),
            f4=match(as.character(data.djf[f4]),time.out),
            f5=match(as.character(data.djf[f5]),time.out),
            f6=match(as.character(data.djf[f6]),time.out),
            f7=match(as.character(data.djf[f7]),time.out),
            f8=match(as.character(data.djf[f8]),time.out))


  olr.miri<-array(numeric(),c(nx.olr,ny.olr,8))

  for (l in 1:8) {
  input.olr<-array(numeric(),c(nx.olr,ny.olr,length(nt.f[[l]])))
  
   for( i in 1:length(nt.f[[l]])) {
    input.olr[,,i] = ncvar_get(nc, varname,
                   start=c(1,1,nt.f[[l]][i]),count=c(-1,-1,1)) }
  olr.miri[,,l]<-mat.anomt(input.olr)
  }

  
  t <- ncdim_def( "time", "month since 2020-01-01", c(1:8), unlim=TRUE) 
  # definindo a variavel
  olr1<- ncvar_def("miriolr","[mm/dia]",  list(x.olr,y.olr,t),-999999,prec="float" )
 
  ncnew <- nc_create(paste0("outputs/netcdf/MIRISA.PHASES.OLR.M2xM1.20230225_2.nc"), list(olr1))
  ncvar_put( ncnew,olr1,c(olr.miri))
  nc_close(ncnew)

#
#####################################################################
#
nc <- nc_open("data/uwnd/anomalias/ncep/200hpa/historico/u20.anom.daily.ncep.19910301.20210228.nc")
varname = 'uwnd'
varsize = nc$var[[varname]]$size

  x.uwnd <- nc$dim$lon   ; lon.uwnd <-x.uwnd$vals  ; nx.uwnd = varsize[1]
  y.uwnd <- nc$dim$lat   ; lat.uwnd <-y.uwnd$vals  ; ny.uwnd = varsize[2]
  t.uwnd <- nc$dim$time  ; time.uwnd<-t.uwnd$vals  ; nt.uwnd = varsize[4] 

  uwnd.miri<-array(numeric(),c(nx.uwnd,ny.uwnd,8))

units<-strsplit(t.uwnd$units," since ")[[1]][1]
origin<-as.POSIXct(substr(strsplit(t.uwnd$units," since ")[[1]][2],1,10), tz = 'UTC')
multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
time.out <- origin + t.uwnd$vals * multiplicator
time.out<-as.character(as.Date(time.out))

  nt.f=list(f1=match(as.character(data.djf[f1]),time.out),
            f2=match(as.character(data.djf[f2]),time.out),
            f3=match(as.character(data.djf[f3]),time.out),
            f4=match(as.character(data.djf[f4]),time.out),
            f5=match(as.character(data.djf[f5]),time.out),
            f6=match(as.character(data.djf[f6]),time.out),
            f7=match(as.character(data.djf[f7]),time.out),
            f8=match(as.character(data.djf[f8]),time.out))


  for (l in 1:8) {
  input.uwnd<-array(numeric(),c(nx.uwnd,ny.uwnd,length(nt.f[[l]])))
  
   for( i in 1:length(nt.f[[l]])) {
    input.uwnd[,,i] = ncvar_get(nc, varname,
                   start=c(1,1,1,nt.f[[l]][i]),count=c(-1,-1,-1,1)) }
  uwnd.miri[,,l]<-mat.anomt.uv(input.uwnd)
  }

  
  t <- ncdim_def( "time", "month since 2020-01-01", c(1:8), unlim=TRUE) 
  # definindo a variavel
  uwnd1<- ncvar_def("u20","[mm/dia]",  list(x.uwnd,y.uwnd,t),-999999,prec="float" )
 
  ncnew <- nc_create("outputs/netcdf/MIRISA.PHASES.U20.20230225.nc", list(uwnd1))
  ncvar_put( ncnew,uwnd1,c(uwnd.miri))
  nc_close(ncnew)


#
#####################################################################
#
nc <- nc_open("data/vwnd/filtrados/ncep/850hpa/historico/butterworth_legado/v85.abtw.daily.ncep.19810101.20201231.nc")
varname = 'vwnd'
varsize = nc$var[[varname]]$size

  x.vwnd <- nc$dim$lon   ; lon.vwnd <-x.vwnd$vals  ; nx.vwnd = varsize[1]
  y.vwnd <- nc$dim$lat   ; lat.vwnd <-y.vwnd$vals  ; ny.vwnd = varsize[2]
  t.vwnd <- nc$dim$Time  ; time.vwnd<-t.vwnd$vals  ; nt.vwnd = varsize[4] 


  vwnd.miri<-array(numeric(),c(nx.vwnd,ny.vwnd,8))

  for (l in 1:8) {
  input.vwnd<-array(numeric(),c(nx.vwnd,ny.vwnd,length(nt.f[[l]])))
  
   for( i in 1:length(nt.f[[l]])) {
    input.vwnd[,,i] = ncvar_get(nc, varname,
                   start=c(1,1,nt.f[[l]][i]),count=c(-1,-1,1)) }
  vwnd.miri[,,l]<-mat.anomt.uv(input.vwnd)
  }


  t <- ncdim_def( "time", "day since 2012-01-01", c(1:8), unlim=TRUE) 
  # definindo a variavel
  vwnd1<- ncvar_def("v85","[mm/dia]",  list(x.vwnd,y.vwnd,t),-999999,prec="float" )
 
  ncnew <- nc_create(paste0("outputs/netcdf/miri.phases.V85.",d.hoje,".nc"), list(vwnd1))
  ncvar_put( ncnew,vwnd1,c(vwnd.miri))
  nc_close(ncnew)

############################################################################################  
  


