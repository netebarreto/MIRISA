# ========================================================================== #
anomaly<-function(y, x, level="daily"){ 
#y is a vector or matrix of measurements
#x is a time series for the vector measurements in POSIXlt format
#level is "daily" or "monthly"
 
 y <- as.matrix(y)
 
 if(level=="monthly"){levs=unique(x$mon)}
 if(level=="daily"){levs=unique(x$yday)}
 
 levs_lookup=vector("list", length(levs))
 names(levs_lookup)<-levs
 for(i in 1:length(levs)){
  if(level=="monthly"){levs_lookup[[i]]<-which(x$mon == names(levs_lookup[i]))}
  if(level=="daily"){levs_lookup[[i]]<-which(x$yday == names(levs_lookup[i]))}
 }
 
 for(j in 1:length(levs)){     #for every time level
  y[levs_lookup[[j]],] <- t(t(as.matrix(y[levs_lookup[[j]],])) - apply(as.matrix(y[levs_lookup[[j]],]), 2, mean, na.rm=TRUE))
 }
 
 y
 
}
# ========================================================================== #

