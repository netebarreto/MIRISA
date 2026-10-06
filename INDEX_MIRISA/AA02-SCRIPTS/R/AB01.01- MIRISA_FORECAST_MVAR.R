
rm(list=ls())
f1 <- function() {shell("cls")}

mirisa1=read.table("AA03-RData_TxT/MIRISA_CLIM_19910301_20200228_CREATE_20230225.txt",sep=";",dec=".",header=TRUE)

mirisa2=read.table("AA03-RData_TxT/MIRISA_CLIM_19910301_20200228_CREATE_20230225.txt",sep=";",dec=".",header=TRUE)


library("dynlm")


miri1 <- ts(mirisa[,4], 
              start = c(1991, 1), 
              end = c(2020, 12), 
              frequency = 30)

miri2 <- ts(mirisa[,5], 
              start = c(1991, 1), 
              end = c(2020, 12), 
              frequency = 30)

VAR_EQ1 <- dynlm(miri1 ~ L(miri1, 1:2) + L(miri2, 1:2), 
                 start = c(1991, 1), 
                 end = c(2019, 12))


coef(VAR_EQ1) %*% c(1, # intercept
                           window(miri1, start = c(2020, 1), end = c(2020, 12)), 
                           window(miri2, start = c(2020, 1), end = c(2020, 12)))



VAR_data <- window(ts.union(GDPGrowth, TSpread), start = c(1980, 3), end = c(2012, 4))

# estimate model coefficients using `VAR()`
VAR_est <- VAR(y = VAR_data, p = 2)
VAR_est
