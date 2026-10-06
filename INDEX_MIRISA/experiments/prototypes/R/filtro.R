

load("R/teste.RData")

write.csv(dd1,file="teste.csv")


library(seewave)

btw_py = read.table("PYTHON/btw_py.csv",header=T,sep=",",dec=".")


bf <- butter(dd1, 1/20,1/100, type="pass")


res1a <- bwfilter(dd1[1:365], n=3,f=length(dd1), from=20, to=100,bandpass=TRUE)

res1c <- bwfilter(dd1[366:732], n=3,f=length(dd1), from=20, to=100,bandpass=TRUE)

res1b <- bwfilter(dd1[733:1097], n=3,f=length(dd1), from=20, to=100,bandpass=TRUE)




plot.ts(dd2[1:1097],lwd=6)
lines(res1a,col="blue",lwd=4)
lines(res1b,col="red",lwd=2)
lines(res1c[1192:1592],col="green",lwd=2)
 


 #######################################################################################

library(ncdf4)
library(seewave)
library(signal)

nc <- nc_open("RAIN_BTW_NCL.nc")
varname = 'precip'
rain.btwn = ncvar_get(nc, varname, start=c(1,1,1),count=c(-1,-1,-1))


nc <- nc_open("Teste1.nc")
varname = 'precip'
rain.nf = ncvar_get(nc, varname, start=c(1,1,1),count=c(-1,-1,-1))

t1 = 20
t2 = 100
rain.btwr1 <- bwfilter(rain.nf, n=3,f=nn, from=nn/t2, to=nn/t1,bandpass=TRUE)

r1.btwr1 <- bwfilter(rain.nf[1:5539], n=3,f=5539, from=5539/t2, to=5539/t1,bandpass=TRUE)



 plot.ts(rain.btwn[1:1765]) 
 lines(rain.btwr1[1:1765],lwd=4,col=2)
 lines(r1.btwr1[1:1765],lwd=2,col="blue")







rain.btwr2 <- filter(butter(3, c(20/365,100/365),type="pass",plane="z"), rain.nf)

dr2 = spec.ar(rain.btwr2, method = "burg")
dr1 = spec.ar(rain.btwr1, method = "burg")

btw_py = read.table("PYTHON/btw_py.csv",header=T,sep=",",dec=".")
dp1 = spec.ar(btw_py[,2], method = "burg")
dp2 = spec.ar(dd2, method = "burg")
plot(1/dp2$freq,dp2$spec,type="l",log="x")

lines(1/dp1$freq,dp1$spec,type="l",log="x",col=2,lwd=2)

lines(1/dr1$freq,dr1$spec,type="l",log="x",col=2,lwd=2)

 plot.ts(rain.btwn[1:1765]) 
 lines(rain.btwr1[1:1765],lwd=2,col=2)


 lines(rain.btwr2[1365:1765],lwd=2,col="blue")


plot(1/dd1$freq,dd1$spec,type="l",log="x")


spec.ar(lh)

spec.ar(ldeaths)
spec.ar(rain.nf, method = "burg")


bf <- butter(2, 1/50, type="low")
b <- filter(bf, y+noise1)

















iris <- new("IrisClient")

starttime <- as.POSIXct("2009-02-18 22:01:07",tz="GMT")
endtime <- starttime + 630
verticalLines <- starttime + seq(30,630,100)

# Get data
stZ <- getSNCL(iris,"ZU.NZ19..BHZ",starttime,endtime)


# Demean, Detrend, Taper
trZ <- DDT(stZ@traces[[1]],TRUE,TRUE,0.05)


# Bandpass filter
trZ_f <- butterworth(trZ,2,0.02,0.04,type='pass')

