
rm(list=ls())


# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))

library(seewave)
library(signal)
library(ncdf4)


# ---- B. Parâmetros dos filtros ----
low <- 1 / 100
high <- 1 / 20
wn <- c(low, high) * 2  # normalizado para Nyquist (fs = 1)


# ---- 2. Filtro Butterworth (ordem 5) ----
bf       <- butter(3, wn, type = "pass")

# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

nc <- nc_open("data/intermediate/AB01-NOF_ANOM/u20.anom.daily.ncep.20180101.20260307.nc")

varname = 'uwnd'
varsize = nc$var[[varname]]$size

x.u20 <- nc$dim$lon   ; lon.u20 <-x.u20$vals  ; nx.u20 = varsize[1]
y.u20 <- nc$dim$lat   ; lat.u20 <-y.u20$vals  ; ny.u20 = varsize[2]
t.u20 <- nc$dim$time  ; time.u20<-t.u20$vals  ; nt.u20 = varsize[4]

#t1 = 20
#t2 = 100
nn = nt.u20

input<-array(numeric(),c(nx.u20,ny.u20,nt.u20))

for( i in 1:nt.u20) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,1,i),count=c(-1,-1,-1,1))
                 }


input_btw<-array(numeric(),c(nx.u20,ny.u20,nt.u20))

for (i in 1:nx.u20) 
{
	for (j in 1:ny.u20) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,] <- filtfilt(bf,input[i,j,] )
		}
	}
}


U20<- ncvar_def("uwnd","[m/s]",  list(x.u20,y.u20,t.u20),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/intermediate/AC01-BTW_ANOM/u20.abtw.daily.ncep.20180101.20260307.nc"), list(U20))
ncvar_put( ncnew,U20,c(input_btw))
nc_close(ncnew)


# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

nc <- nc_open("data/intermediate/AB01-NOF_ANOM/u85.anom.daily.ncep.20180101.20260307.nc")

varname = 'uwnd'
varsize = nc$var[[varname]]$size

x.u85 <- nc$dim$lon   ; lon.u85 <-x.u85$vals  ; nx.u85 = varsize[1]
y.u85 <- nc$dim$lat   ; lat.u85 <-y.u85$vals  ; ny.u85 = varsize[2]
t.u85 <- nc$dim$time  ; time.u85<-t.u85$vals  ; nt.u85 = varsize[4]

nn = nt.u85

input<-array(numeric(),c(nx.u85,ny.u85,nt.u85))

for( i in 1:nt.u85) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,1,i),count=c(-1,-1,-1,1))
                 }


input_btw<-array(numeric(),c(nx.u85,ny.u85,nt.u85))

for (i in 1:nx.u85) 
{
	for (j in 1:ny.u85) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,] <- filtfilt(bf,input[i,j,] )
		}
	}
}


U85<- ncvar_def("uwnd","[m/s]",  list(x.u85,y.u85,t.u85),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/intermediate/AC01-BTW_ANOM/u85.abtw.daily.ncep.20180101.20260307.nc"), list(U85))
ncvar_put( ncnew,U85,c(input_btw))
nc_close(ncnew)



# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

nc <- nc_open("data/intermediate/AB01-NOF_ANOM/olr.anom.daily.v01r02.20180101.20260307.nc")

varname = 'olr'
varsize = nc$var[[varname]]$size

x.olr <- nc$dim$lon   ; lon.olr <-x.olr$vals  ; nx.olr = varsize[1]
y.olr <- nc$dim$lat   ; lat.olr <-y.olr$vals  ; ny.olr = varsize[2]
t.olr <- nc$dim$time  ; time.olr<-t.olr$vals  ; nt.olr = varsize[3]

nn = nt.olr

input<-array(numeric(),c(nx.olr,ny.olr,nt.olr))

for( i in 1:nt.olr) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }

### tempos 1375, 1376, 1377, 1378com problemas 

input[,,1375:1378] <- apply(aperm(input[,,c(1372:1374,1379:1382)]),2,colMeans)

input_btw<-array(numeric(),c(nx.olr,ny.olr,nt.olr))

for (i in 1:nx.olr) 
{
	for (j in 1:ny.olr) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,]<-filtfilt(bf,input[i,j,] )
		}
	}
}

rm(input)

OLR<- ncvar_def("olr","[m/s]",  list(x.olr,y.olr,t.olr),-999999,prec="float" )
ncnew <- nc_create(paste0("data/intermediate/AC01-BTW_ANOM/olr.abtw.daily.v01r02.20180101.20260307.nc"), list(OLR))
ncvar_put( ncnew,OLR,c(input_btw))
nc_close(ncnew)



