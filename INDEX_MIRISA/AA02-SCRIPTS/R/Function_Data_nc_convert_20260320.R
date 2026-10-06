data_nc_convert <- function(ncf){
    units<-strsplit(ncf$dim$time$units," since ")[[1]][1]
    origin<-as.POSIXct(substr(strsplit(ncf$dim$time$units," since ")[[1]][2],1,10), tz = 'UTC')
    multiplicator<-switch(units, days = 60 * 60 * 24, hours = 60 * 60, minutes = 60, seconds = 1)
    time.out <- origin + ncf$dim$time$vals * multiplicator
    time.out<-as.character(as.Date(time.out))
    return(time.out)}

