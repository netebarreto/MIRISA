
load("index.MIBT_23062014.RData")


y1<-which(y$vals>=-20 & y$vals<=-10)

x1<-which((x$vals-360)>=-50)

world(xlim=c(-50,-30),ylim=c(-20,-10))

image((x$vals-360)[x1],y$vals[y1],data.5[x1,y1,1,930],add=T)
world(xlim=c(-50,-30),ylim=c(-20,-10),add=T)

data.6<-data.5[x1,y1,1,]

for(i in 1:1797)
{ dd6[i]<-mean(na.exclude(data.6[,,i]))

}

nt<-which(dd6>=quantile(dd6,prob=0.75))

dd7<-dd6
dd7[nt]<-1 ; dd7[-nt]<-0 

tt<-which(data.sem[,2]<=5 & data.sem[,1]==1979)

dd8<-as.matrix(dd7[-tt]) ; mib<-MIB.t[-tt,3:4]

tt1<-which(data.sem[,2]==12 | data.sem[,2]<=5)

dd9<-dd8[tt1] ; mib1<-mib[tt1,]

dd9a<-dd9[1:867] ; mib1a<-mib1[1:867,]

dd9b<-dd9[868:893] ; mib1b<-mib1[868:893,]

nn<-which(mib1b[,1]>=3.5) 
fase<-mib[,1] 

fase[nn]<- 1 ; fase[-nn]<-0

MOD<-glm(dd9a~fase,family=binomial("logit"))
(RES<-logistic.display(MOD))

par(mfrow=c(2,1))
plot.ts(MOD$fitted.values[100:150])
plot.ts(dd9a[100:150])



