# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))



library(seewave)

library(ncdf4)


nc <- nc_open("data/prec.AMS.anom.daily.cpc.199110301.20210628.nc")

varname = 'precip'
varsize = nc$var[[varname]]$size

x.prp <- nc$dim$lon   ; lon.prp <-x.prp$vals  ; nx.prp = varsize[1]
y.prp <- nc$dim$lat   ; lat.prp <-y.prp$vals  ; ny.prp = varsize[2]
t.prp <- nc$dim$time  ; time.prp<-t.prp$vals  ; nt.prp = varsize[3]

input<-array(numeric(),c(nx.prp,ny.prp,nt.prp))

for( i in 1:nt.prp) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }

t1 = 20
t2 = 100
nn = nt.prp

input_btw<-array(numeric(),c(nx.prp,ny.prp,nt.prp))

for (i in 1:nx.prp) 
{
	for (j in 1:ny.prp) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}


PRP<- ncvar_def("precip","[mm/dia]",  list(x.prp,y.prp,t.prp),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/intermediate/AC01-BTW_ANOM_R/prec.AMS.abtw.daily.cpc.19910301.20210628.nc"), list(PRP))
ncvar_put( ncnew,PRP,c(input_btw))
nc_close(ncnew)


# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

nc <- nc_open("data/u20.anom.daily.ncep.19910301.20210228.nc")

varname = 'uwnd'
varsize = nc$var[[varname]]$size

x.u20 <- nc$dim$lon   ; lon.u20 <-x.u20$vals  ; nx.u20 = varsize[1]
y.u20 <- nc$dim$lat   ; lat.u20 <-y.u20$vals  ; ny.u20 = varsize[2]
t.u20 <- nc$dim$time  ; time.u20<-t.u20$vals  ; nt.u20 = varsize[4]

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
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}


U20<- ncvar_def("uwnd","[m/s]",  list(x.u20,y.u20,t.u20),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/intermediate/AC01-BTW_ANOM_R/u20.abtw.daily.ncep.19910301.20210628.nc"), list(U20))
ncvar_put( ncnew,U20,c(input_btw))
nc_close(ncnew)


# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

nc <- nc_open("data/u85.anom.daily.ncep.19910301.20210228.nc")

varname = 'uwnd'
varsize = nc$var[[varname]]$size

x.u85 <- nc$dim$lon   ; lon.u85 <-x.u85$vals  ; nx.u85 = varsize[1]
y.u85 <- nc$dim$lat   ; lat.u85 <-y.u85$vals  ; ny.u85 = varsize[2]
t.u85 <- nc$dim$time  ; time.u85<-t.u85$vals  ; nt.u85 = varsize[4]

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
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}


U85<- ncvar_def("uwnd","[m/s]",  list(x.u85,y.u85,t.u85),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/intermediate/AC01-BTW_ANOM_R/u85.abtw.daily.ncep.19910301.20210628.nc"), list(U85))
ncvar_put( ncnew,U85,c(input_btw))
nc_close(ncnew)



# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

nc <- nc_open("data/olr.anom.daily.v01r02.19910301.20211231.nc")

varname = 'olr'
varsize = nc$var[[varname]]$size

x.olr <- nc$dim$lon   ; lon.olr <-x.olr$vals  ; nx.olr = varsize[1]
y.olr <- nc$dim$lat   ; lat.olr <-y.olr$vals  ; ny.olr = varsize[2]
t.olr <- nc$dim$time  ; time.olr<-t.olr$vals  ; nt.olr = varsize[3]

input<-array(numeric(),c(nx.olr,ny.olr,nt.olr))

for( i in 1:nt.olr) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
                 }


input_btw<-array(numeric(),c(nx.olr,ny.olr,nt.olr))

for (i in 1:nx.olr) 
{
	for (j in 1:ny.olr) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}

rm(input)

OLR<- ncvar_def("olr","[m/s]",  list(x.olr,y.olr,t.olr),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/intermediate/AC01-BTW_ANOM_R/olr.abtw.daily.v01r02.19910301.20201231.nc"), list(OLR))
ncvar_put( ncnew,OLR,c(input_btw))
nc_close(ncnew)



