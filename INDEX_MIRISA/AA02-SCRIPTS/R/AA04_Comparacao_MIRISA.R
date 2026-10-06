

setwd("C:/Users/Nete/Documents/NETE_PROJETOS/AB00-PROJETOS_NETE/MIRISA_PROJECT")

mirisa1<-read.table("AA03-RData_TxT/MIRISA_REALT_20180101_20260307_CREATE_20260311.txt",sep=";",dec=".",header=T)
data1=as.Date(paste(mirisa1[,1],mirisa1[,2],mirisa1[,3],sep="-")) 


mirisa2<-read.table("AA03-RData_TxT/MIRISA_REALT_20200301_20250907_CREATE_20250922.txt",sep=";",dec=".",header=T)
data2=as.Date(paste(mirisa2[,1],mirisa2[,2],mirisa2[,3],sep="-")) 


plot.ts(mirisa1[mirisa1[,1]>=2023,5],lwd=2)
lines(mirisa2[mirisa2[,1]>=2023,5],col="red",lwd=1.5)





lines(mirisa1[1600:1877,4],col="blue",lwd=1.5)

perfil1<-function(x1,x2){
        angl<-((atan2(x1,x2))*-180/pi)+180
        ampl<-round(sqrt(x1^2+x2^2),3)
        phase<-as.integer(angl/45)+1
        phase[phase==0]=8
        return(data.frame(Phase=phase,Amplitude=ampl))  
}

miri[,4:5] <- miri[,4:5]*-1
miri[,6]= perfil1(miri[,5],miri[,4])[,1]


miri.djf.e<-miri[((miri[,1]>=1991 & miri[,1]<=2020) & (miri[,2]==12 | miri[,2]<=2) & (miri[,7]>=1.5)),]

data.djf=as.Date(paste(miri.djf.e[,1],miri.djf.e[,2],miri.djf.e[,3],sep="-")) 

miri.11<-miri[((miri[,1]>=1991 & miri[,1]<=2020) & (miri[,2]==11)),]

f8<-which(miri.djf.e[,6]==8 )
f1<-which(miri.djf.e[,6]==1 )
f2<-which(miri.djf.e[,6]==2 )
f3<-which(miri.djf.e[,6]==3 )
f4<-which(miri.djf.e[,6]==4 )
f5<-which(miri.djf.e[,6]==5 )
f6<-which(miri.djf.e[,6]==6 )
f7<-which(miri.djf.e[,6]==7 )

nn1 <- match(data.djf[f1],data1)
nn2 <- match(data.djf[f2],data1)
nn3 <- match(data.djf[f3],data1)
nn4 <- match(data.djf[f4],data1)
nn5 <- match(data.djf[f5],data1)
nn6 <- match(data.djf[f6],data1)
nn7 <- match(data.djf[f7],data1)
nn8 <- match(data.djf[f8],data1)


mirif1 <- NULL 
for(i in 30:0) 
{   
	mirif1 <- rbind(mirif1,colMeans(miri[nn1-i,4:5]))
}

mirif5 <- NULL 
for(i in 30:0) 
{   
	mirif5 <- rbind(mirif5,colMeans(miri[nn5-i,4:5]))
}


miriRT = tail(mirisa1,70)
plot(c(-3:3),c(-3:3),xlab="mirisa1",ylab="mirisa2",xlim=c(-2.5,2.5),ylim=c(2.5,-2.5),typ="n")
points(miriRT[,4],miriRT[,5],col="red")

abline(h=0,v=0)




#source("R/AA04_Comparacao_MIRISA.R")

# x = c(1:10)

# y = c(21:30) 

# plot(x,y)

d1d2 = match(intersect(data1,data2),data1)
d2d1 = match(intersect(data1,data2),data2)
