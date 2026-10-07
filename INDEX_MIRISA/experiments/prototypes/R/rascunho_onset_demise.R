#
#
#


# 

rm(list=ls())

setwd("C:/Users/Nete/Documents/NETE_PROJETOS/AB00-PROJETOS/MIRISA_PROJECT")
dir()

f1 <-function() {shell("cls")}

f1()

library("zoo")
dir("AA03-Rdata_TxT")

mirisa <- read.csv("AA03-RData_TxT/MIRISA_CLIM_19910301_20200228_CREATE_20230225.txt",head=TRUE,sep=";",dec=".")
ptdas=data.frame(day5=as.character(seq(as.Date("1981-01-03"),
                                              as.Date("1981-12-31"),by = 5)) )
ptdas$n = c(1:nrow(ptdas))
ptdas$jday = format(as.Date(ptdas$day5),"%j")
ddate = as.Date(paste(mirisa[,1],mirisa[,2],mirisa[,3],sep="-"))
ddate_j = format(ddate,"%j")

mirisa1 <- mirisa[,FALSE]
mirisa1[,1:3] <-mirisa[,1:3]
mirisa1$jday = as.numeric(ddate_j)


head(mirisa1)


onset <- read.csv("AA03-RData_TxT/Onset_DEMISE_REANALISE_NCEP.txt",head=TRUE,sep=";",dec=".")


onset_dt <- paste0(onset$Y_ONSET,substr(pentadas[match(onset$Onset,pentadas$N),2],5,10))
onset_dt

demise_dt <- paste0(onset$Y_DEMISE,substr(pentadas[match(onset$Demise,pentadas$N),2],5,10))
demise_dt




n1 = na.exclude(match(onset_dt,ddate))
n2 = na.exclude(match(demise_dt,ddate))

ff1 = function(x) {
    x1 = NULL
    for(i in 1:length(x))
    x1 = c(x1,(x[i]-2):(x[i]+2))
    return(x1)}

nn1 = ff1(n1)
nn2 = ff1(n2)


df1 = mirisa[nn1,]
df2 = mirisa[nn2,]

dev.off()
dev.new()
barplot(table(df1$Phase))
dev.new()
hist(df1$Amplitude)
table(df1$Phase)

dev.set(2)
barplot(mirisa$Phase[n1])
dev.set(3)
hist(mirisa$Amplitude[n1])

mirisa[n1,]
mirisa[n1-5,]

table(mirisa$Month[n1],mirisa$Phase[n1])
table(mirisa$Phase[n1-5])



dev.new()
barplot(table(df2$Phase))
hist(df2$Amplitude)
dev.set(2)
table(df2$Phase)
f1()
