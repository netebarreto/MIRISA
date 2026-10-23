# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
# source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))
rm(list=ls())

# Define a raiz do projeto; os caminhos de entrada e saida abaixo sao relativos a ela.
#setwd("C:/Users/Nete/Documents/NETE_PROJETOS/AB00-PROJETOS_NETE/MIRISA_PROJECT/MIRISA_organizado/INDEX_MIRISA")
setwd("D:/AB00-NETE_PROJETOS/MIRISA/INDEX_MIRISA/")

f1 <- function() {shell("cls")}

library(seewave)

library(ncdf4)

library(zoo)


# nc <- nc_open("prec/precip.sa.cpc-noaa.anom.19800101.20111231.nc")

# varname = 'precip'
# varsize = nc$var[[varname]]$size

# x.prp <- nc$dim$lon   ; lon.prp <-x.prp$vals  ; nx.prp = varsize[1]
# y.prp <- nc$dim$lat   ; lat.prp <-y.prp$vals  ; ny.prp = varsize[2]
# t.prp <- nc$dim$time  ; time.prp<-t.prp$vals  ; nt.prp = varsize[3]

#     input = ncvar_get(nc, varname, start=c(1,1,1),count=c(-1,-1,-1))

# t1 = 20
# t2 = 100
# nn = nt.prp

# input_btw <- array(numeric(), c(nx.prp, ny.prp, nt.prp))

# # Definimos o limite máximo de NAs permitidos (30%)
# limite_na <- as.integer(0.3 * nt.prp)

# for (i in 1:nx.prp) {
#   for (j in 1:ny.prp) {
    
#     # Captura a série temporal do pixel atual
#     serie_temporal <- input[i, j, ]
#     qtd_na <- sum(is.na(serie_temporal))
    
#     # 1. Se a série inteira for NA, ou passar de 30% de NAs, pula para o próximo pixel
#     if (qtd_na == nt.prp || qtd_na >= limite_na) {
#       next
#     }
    
#     # 2. Se houver NAs (mas menos que 30%), aplica a interpolação linear
#     if (qtd_na > 0) {
#       # na.rm = FALSE mantém o tamanho original; na.flex=TRUE ou rule=2 lida com as pontas
#       serie_temporal <- na.approx(serie_temporal, na.rm = FALSE, rule = 2)
#     }
    
#     # 3. Executa a função do filtro Butterworth
#     input_btw[i, j, ] <- bwfilter(
#       serie_temporal, 
#       n = 3, 
#       f = nn, 
#       from = nn / t2, 
#       to = nn / t1, 
#       bandpass = TRUE
#     )
#   }
# }



# PRP<- ncvar_def("precip","[mm/dia]",  list(x.prp,y.prp,t.prp),-999999,prec="float" )
# ncnew <- nc_create  (paste0("filtrados/precip.sa.cpc-noaa.filtrada.19800101.20111231.nc"), list(PRP))
# ncvar_put( ncnew,PRP,c(input_btw))
# nc_close(ncnew)


# # * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
print("inicio v20 1980 - 2011 ")
nc <- nc_open("data/vwnd/anomalias/ncep/200hpa/v20.ncep.anom.19800101.20111231.nc")

varname = 'vwnd'
varsize = nc$var[[varname]]$size

x.v20 <- nc$dim$lon   ; lon.v20 <-x.v20$vals  ; nx.v20 = varsize[1]
y.v20 <- nc$dim$lat   ; lat.v20 <-y.v20$vals  ; ny.v20 = varsize[2]
t.v20 <- nc$dim$time  ; time.v20<-t.v20$vals  ; nt.v20 = varsize[4]


t1 = 20
t2 = 100
nn = nt.v20

input<-array(numeric(),c(nx.v20,ny.v20,nt.v20))

for( i in 1:nt.v20) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,1,i),count=c(-1,-1,-1,1))
                 }


input_btw<-array(numeric(),c(nx.v20,ny.v20,nt.v20))

for (i in 1:nx.v20) 
{
	for (j in 1:ny.v20) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}


v20<- ncvar_def("vwnd","[m/s]",  list(x.v20,y.v20,t.v20),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/vwnd/filtrados/ncep/200hpa/v20.ncep.filtrado.19800101.20111231.nc"), list(v20))
ncvar_put( ncnew,v20,c(input_btw))
nc_close(ncnew)


# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

# print("inicio v20 1980 - 2021 ")
# nc <- nc_open("data/vwnd/anomalias/ncep/200hpa/v20.ncep.anom.19800101.20211231.nc")

# varname = 'vwnd'
# varsize = nc$var[[varname]]$size

# x.v20 <- nc$dim$lon   ; lon.v20 <-x.v20$vals  ; nx.v20 = varsize[1]
# y.v20 <- nc$dim$lat   ; lat.v20 <-y.v20$vals  ; ny.v20 = varsize[2]
# t.v20 <- nc$dim$time  ; time.v20<-t.v20$vals  ; nt.v20 = varsize[4]


# t1 = 20
# t2 = 100
# nn = nt.v20

# input<-array(numeric(),c(nx.v20,ny.v20,nt.v20))

# for( i in 1:nt.v20) {
#     input[,,i] = ncvar_get(nc, varname, start=c(1,1,1,i),count=c(-1,-1,-1,1))
#                  }


# input_btw<-array(numeric(),c(nx.v20,ny.v20,nt.v20))

# for (i in 1:nx.v20) 
# {
# 	for (j in 1:ny.v20) 
# 	{
# 		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
# 		{
# 			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
# 		}
# 	}
# }


# v20<- ncvar_def("vwnd","[m/s]",  list(x.v20,y.v20,t.v20),-999999,prec="float" )
# ncnew <- nc_create  (paste0("data/vwnd/filtrados/ncep/200hpa/v20.ncep.filtrado.19800101.20211231.nc"), list(v20))
# ncvar_put( ncnew,v20,c(input_btw))
# nc_close(ncnew)


# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
print("inicio v20 1990 - 2021 ")
nc <- nc_open("data/vwnd/anomalias/ncep/200hpa/v20.ncep.anom.19900101.20211231.nc")

varname = 'vwnd'
varsize = nc$var[[varname]]$size

x.v20 <- nc$dim$lon   ; lon.v20 <-x.v20$vals  ; nx.v20 = varsize[1]
y.v20 <- nc$dim$lat   ; lat.v20 <-y.v20$vals  ; ny.v20 = varsize[2]
t.v20 <- nc$dim$time  ; time.v20<-t.v20$vals  ; nt.v20 = varsize[4]


t1 = 20
t2 = 100
nn = nt.v20

input<-array(numeric(),c(nx.v20,ny.v20,nt.v20))

for( i in 1:nt.v20) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,1,i),count=c(-1,-1,-1,1))
                 }


input_btw<-array(numeric(),c(nx.v20,ny.v20,nt.v20))

for (i in 1:nx.v20) 
{
	for (j in 1:ny.v20) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}


v20<- ncvar_def("vwnd","[m/s]",  list(x.v20,y.v20,t.v20),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/vwnd/filtrados/ncep/200hpa/v20.ncep.filtrado.19900101.20211231.nc"), list(v20))
ncvar_put( ncnew,v20,c(input_btw))
nc_close(ncnew)


# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

print("inicio v85 1980 - 2011 ")

nc <- nc_open("data/vwnd/anomalias/ncep/850hpa/v85.ncep.anom.19800101.20111231.nc")

varname = 'vwnd'
varsize = nc$var[[varname]]$size

x.v85 <- nc$dim$lon   ; lon.v85 <-x.v85$vals  ; nx.v85 = varsize[1]
y.v85 <- nc$dim$lat   ; lat.v85 <-y.v85$vals  ; ny.v85 = varsize[2]
t.v85 <- nc$dim$time  ; time.v85<-t.v85$vals  ; nt.v85 = varsize[4]


t1 = 20
t2 = 100
nn = nt.v85


input<-array(numeric(),c(nx.v85,ny.v85,nt.v85))

for( i in 1:nt.v85) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,1,i),count=c(-1,-1,-1,1))
                 }


input_btw<-array(numeric(),c(nx.v85,ny.v85,nt.v85))

for (i in 1:nx.v85) 
{
	for (j in 1:ny.v85) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}


v85<- ncvar_def("vwnd","[m/s]",  list(x.v85,y.v85,t.v85),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/vwnd/filtrados/ncep/850hpa/v85.ncep.filtrado.19800101.20111231.nc"), list(v85))
ncvar_put( ncnew,v85,c(input_btw))
nc_close(ncnew)

# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

print("inicio v85 1980 - 2021 ")

nc <- nc_open("data/vwnd/anomalias/ncep/850hpa/v85.ncep.anom.19800101.20211231.nc")

varname = 'vwnd'
varsize = nc$var[[varname]]$size

x.v85 <- nc$dim$lon   ; lon.v85 <-x.v85$vals  ; nx.v85 = varsize[1]
y.v85 <- nc$dim$lat   ; lat.v85 <-y.v85$vals  ; ny.v85 = varsize[2]
t.v85 <- nc$dim$time  ; time.v85<-t.v85$vals  ; nt.v85 = varsize[4]


t1 = 20
t2 = 100
nn = nt.v85


input<-array(numeric(),c(nx.v85,ny.v85,nt.v85))

for( i in 1:nt.v85) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,1,i),count=c(-1,-1,-1,1))
                 }


input_btw<-array(numeric(),c(nx.v85,ny.v85,nt.v85))

for (i in 1:nx.v85) 
{
	for (j in 1:ny.v85) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}


v85<- ncvar_def("vwnd","[m/s]",  list(x.v85,y.v85,t.v85),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/vwnd/filtrados/ncep/850hpa/v85.ncep.filtrado.19800101.20211231.nc"), list(v85))
ncvar_put( ncnew,v85,c(input_btw))
nc_close(ncnew)
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
print("inicio v85 1990 - 2021 ")

nc <- nc_open("data/vwnd/anomalias/ncep/850hpa/v85.ncep.anom.19900101.20211231.nc")

varname = 'vwnd'
varsize = nc$var[[varname]]$size

x.v85 <- nc$dim$lon   ; lon.v85 <-x.v85$vals  ; nx.v85 = varsize[1]
y.v85 <- nc$dim$lat   ; lat.v85 <-y.v85$vals  ; ny.v85 = varsize[2]
t.v85 <- nc$dim$time  ; time.v85<-t.v85$vals  ; nt.v85 = varsize[4]


t1 = 20
t2 = 100
nn = nt.v85


input<-array(numeric(),c(nx.v85,ny.v85,nt.v85))

for( i in 1:nt.v85) {
    input[,,i] = ncvar_get(nc, varname, start=c(1,1,1,i),count=c(-1,-1,-1,1))
                 }


input_btw<-array(numeric(),c(nx.v85,ny.v85,nt.v85))

for (i in 1:nx.v85) 
{
	for (j in 1:ny.v85) 
	{
		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
		{
			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
		}
	}
}


v85<- ncvar_def("vwnd","[m/s]",  list(x.v85,y.v85,t.v85),-999999,prec="float" )
ncnew <- nc_create  (paste0("data/vwnd/filtrados/ncep/850hpa/v85.ncep.filtrado.19900101.20211231.nc"), list(v85))
ncvar_put( ncnew,v85,c(input_btw))
nc_close(ncnew)


# * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

# nc <- nc_open("data/olr/anomalias/olr.noaa.v2.anomalia.19800101.20211231.nc")

# varname = 'olr'
# varsize = nc$var[[varname]]$size

# x.olr <- nc$dim$lon   ; lon.olr <-x.olr$vals  ; nx.olr = varsize[1]
# y.olr <- nc$dim$lat   ; lat.olr <-y.olr$vals  ; ny.olr = varsize[2]
# t.olr <- nc$dim$time  ; time.olr<-t.olr$vals  ; nt.olr = varsize[3]

# input<-array(numeric(),c(nx.olr,ny.olr,nt.olr))

# for( i in 1:nt.olr) {
#     input[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
#                  }


# input_btw<-array(numeric(),c(nx.olr,ny.olr,nt.olr))

# t1 = 20
# t2 = 100
# nn = nt.olr

# for (i in 1:nx.olr) 
# {
# 	for (j in 1:ny.olr) 
# 	{
# 		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
# 		{
# 			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
# 		}
# 	}
# }

# rm(input)

# OLR<- ncvar_def("olr","[m/s]",  list(x.olr,y.olr,t.olr),-999999,prec="float" )
# ncnew <- nc_create  (paste0("data/olr/filtrados/olr.noaa.v2.filtrado.19800101.20211231.nc"), list(OLR))
# ncvar_put( ncnew,OLR,c(input_btw))
# nc_close(ncnew)


# # * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

# nc <- nc_open("data/olr/anomalias/olr.noaa.v2.anomalia.19900101.20211231.nc")

# varname = 'olr'
# varsize = nc$var[[varname]]$size

# x.olr <- nc$dim$lon   ; lon.olr <-x.olr$vals  ; nx.olr = varsize[1]
# y.olr <- nc$dim$lat   ; lat.olr <-y.olr$vals  ; ny.olr = varsize[2]
# t.olr <- nc$dim$time  ; time.olr<-t.olr$vals  ; nt.olr = varsize[3]

# input<-array(numeric(),c(nx.olr,ny.olr,nt.olr))

# for( i in 1:nt.olr) {
#     input[,,i] = ncvar_get(nc, varname, start=c(1,1,i),count=c(-1,-1,1))
#                  }


# input_btw<-array(numeric(),c(nx.olr,ny.olr,nt.olr))

# t1 = 20
# t2 = 100
# nn = nt.olr

# for (i in 1:nx.olr) 
# {
# 	for (j in 1:ny.olr) 
# 	{
# 		if(!any(is.na(input[i,j,])) & !all(is.na(input[i,j,])) )
# 		{
# 			input_btw[i,j,]<-bwfilter(input[i,j,],n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)
# 		}
# 	}
# }

# rm(input)

# OLR<- ncvar_def("olr","[m/s]",  list(x.olr,y.olr,t.olr),-999999,prec="float" )
# ncnew <- nc_create  (paste0("data/olr/filtrados/olr.noaa.v2.filtrado.19900101.20211231.nc"), list(OLR))
# ncvar_put( ncnew,OLR,c(input_btw))
# nc_close(ncnew)


