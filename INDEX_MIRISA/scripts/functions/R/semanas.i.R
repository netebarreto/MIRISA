
iden.weekly <- function(X,Y)
            { 
# X= dados diarios
# Y dados semanais

x1=as.data.frame(matrix(as.numeric(unlist(strsplit(as.character(X),"-"))),ncol=3,byrow=T))
y1=as.data.frame(matrix(as.numeric(unlist(strsplit(as.character(Y),"-"))),ncol=3,byrow=T))

x2=NULL
for (i in 1:nrow(y1))
{a1<-x1[which(x1[,1]==y1[i,1] & x1[,2]==y1[i,2] & x1[,3]==y1[i,3]),]
 x2<-c(x2,as.numeric(rownames(a1)))}
y1<-data.frame(y1,x2)
return(y1)
}


n.semana<- function(X)
            { 

dd1 <- as.Date(paste(as.character(X[1,1]),"01-01",sep="-"))
dd2 <- as.Date(paste(X[1,1:3],collapse="-"))
ss1 <- seq(dd2,dd1,by="-7 day")
ss2 <- as.data.frame(matrix(as.numeric(unlist(strsplit(as.character(ss1),"-"))),ncol=3,byrow=T))
Z <- rbind(ss2,X[,1:3])
ano<-as.numeric(attr(factor(Z[,1]),"levels"))
Z[,4]<-NA
for (i in ano)
{ n <-which(Z[,1]==i) 
  Z[n,4]<-c(1:length(n))
}

return(Z[-(1:length(ss1)),4])
}

