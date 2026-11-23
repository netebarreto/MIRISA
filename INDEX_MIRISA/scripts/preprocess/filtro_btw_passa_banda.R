# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
# source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))
rm(list=ls())

# Define a raiz do projeto; os caminhos de entrada e saida abaixo sao relativos a ela.
#setwd("C:/Users/Nete/Documents/NETE_PROJETOS/AB00-PROJETOS_NETE/MIRISA_PROJECT/MIRISA_organizado/INDEX_MIRISA")
# setwd("D:/AB00-NETE_PROJETOS/MIRISA/INDEX_MIRISA/")

f1 <- function() {shell("cls")}

library(seewave)

library(ncdf4)

library(zoo)

library(optparse)

# option_list <- list(
#   make_option(c("-d", "--diretorio"), type = "character", default = "."),
#   make_option(c("-e", "--entrada"), type = "character", default = NULL),
#   make_option(c("-v", "--varname"), type = "character", default = NULL),
#   make_option(c("-s", "--saida"), type = "character", default = "resultado.csv")
# )

# opt <- parse_args(OptionParser(option_list = option_list))

# input<-file.path(opt$diretorio, opt$entrada)
# output<-file.path(opt$diretorio, opt$saida)

 
 input <- "D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/prec/anomalias/cpc-noaa/precip.sa.cpc-noaa.anom.20200101.20251231.nc"

# input <- "D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/olr/anomalias/olr.noaa.v2.anomalia.20200101.20251231.nc"

# input <- "D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/uwnd/anomalias/ncep_r1/200hpa/u20.ncep.anom.20200101.20251231.nc"

#input <- "D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/uwnd/anomalias/ncep_r1/850hpa/u85.ncep.anom.20200101.20251231.nc"

#file.path(opt$diretorio, opt$entrada)


 output <-  "D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/prec/filtrados/cpc-noaa/precip.sa.cpc-noaa.filtrado.20200101.20251231.nc"

# output <- "D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/olr/filtrados/olr.noaa.v2.filtrado.20200101.20251231.nc"

# output <- "D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/uwnd/filtrados/ncep_r1/200hpa/u20.ncep.filtrado.20200101.20251231.nc"

# output <- "D:/NETE_PROJETOS/MIRISA/INDEX_MIRISA_Local/data/uwnd/filtrados/ncep_r1/850hpa/u85.ncep.filtrado.20200101.20251231.nc"

#file.path(opt$diretorio, opt$saida)

nc <- nc_open(input)

varname = "precip" #opt$varname
varsize = nc$var[[varname]]$size

if(length(varsize)==3) 
{ 
 x.var <- nc$dim$lon   ; lon.var <-x.var$vals  ; nx.var = varsize[1]
 y.var <- nc$dim$lat   ; lat.var <-y.var$vals  ; ny.var = varsize[2]
 t.var <- nc$dim$time  ; time.var<-t.var$vals  ; nt.var = varsize[3]

input = ncvar_get(nc, varname, start=c(1,1,1),count=c(-1,-1,-1))
}

if(length(varsize)==4) 
{ 
 x.var <- nc$dim$lon   ; lon.var <-x.var$vals  ; nx.var = varsize[1]
 y.var <- nc$dim$lat   ; lat.var <-y.var$vals  ; ny.var = varsize[2]
 t.var <- nc$dim$time  ; time.var<-t.var$vals  ; nt.var = varsize[4]

input = ncvar_get(nc, varname, start=c(1,1,1,1),count=c(-1,-1,-1,-1))
}

t1 = 20
t2 = 100
nn = nt.var

input_btw <- array(numeric(), c(nx.var, ny.var, nt.var))

# # Definimos o limite máximo de NAs permitidos (30%)
limite_na <- as.integer(0.3 * nt.var)

for (i in 1:nx.var) {
  for (j in 1:ny.var) {
    
    # Captura a série temporal do pixel atual
    serie_temporal <- input[i, j, ]
    qtd_na <- sum(is.na(serie_temporal))
    
    # 1. Se a série inteira for NA, ou passar de 30% de NAs, pula para o próximo pixel
    if (qtd_na == nt.var || qtd_na >= limite_na) {
      next
    }
    
    # 2. Se houver NAs (mas menos que 30%), aplica a interpolação linear
    if (qtd_na > 0) {
      # na.rm = FALSE mantém o tamanho original; na.flex=TRUE ou rule=2 lida com as pontas
      serie_temporal <- na.approx(serie_temporal, na.rm = FALSE, rule = 2)
    }
    
    # 3. Executa a função do filtro Butterworth
    input_btw[i, j, ] <- bwfilter(
      serie_temporal, 
      n = 3, 
      f = nn, 
      from = nn / t2, 
      to = nn / t1, 
      bandpass = TRUE
    )
  }
}


VAR<- ncvar_def(varname,"not_def",  list(x.var,y.var,t.var),-999999,prec="float" )
ncnew <- nc_create  (output, list(VAR))
ncvar_put( ncnew,VAR,c(input_btw))
nc_close(ncnew)


# # # * - * - *- -* -* -*- -* -* -* *-* -** --* -** 
# # # * - * - *- -* -* -*- -* -* -* *-* -** --* -** 

