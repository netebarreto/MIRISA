# ============================================================
# GLMM logístico para prever active e break spells de chuva
# com base no MIRISA
#
# Requer:
# install.packages(c("dplyr", "lme4", "pROC"))
# ============================================================

rm(list=ls())
# Executar a partir de INDEX_MIRISA ou definir MIRISA_ROOT.
source(file.path(Sys.getenv("MIRISA_ROOT", unset = "."), "config", "paths.R"))

library(dplyr)
library(lme4)
library(pROC)
library(ncdf4)

f1 <- function(){shell("cls")}



source("scripts/functions/R/Function_Data_nc_convert_20260320.R")
source("scripts/functions/R/Function_monsoon_atividade_20260322.r")

mirisa1<-read.table("outputs/tables/MIRISA_CLIM_19910401_20210331_CREATE_20260314.txt",sep=";",dec=".",header=T)
data1=as.Date(paste(mirisa1[,1],mirisa1[,2],mirisa1[,3],sep="-")) 

#round(quantile(mirisa1$Amplitude,prob=c(0.2,0.4,0.6,0.8,0.95)),1)
#20% 40% 60% 80% 95% 
#               (Inativa)      0.6   0  
#          0.6  (Fraca)        0.8   1
#          0.8  (Ativa)        1.2   2
#          1.2  (Forte)        1.5   3
#          1.5  (Muito Forte)  2.1   4 
#          2.1  (Extrema)            5

    # LIMIARES ESCOLHIDOS PARA AS AMPLITUDES
    #               (Inativa)      0.8   0  
    #          0.8  (Fraca)        1.2   1
    #          1.2  (Ativa)        1.6   2
    #          1.6  (Forte)        2.0   3
    #          2.0  (Extrema)            4

      ## Amplitudes de origem do RMM 
        #               (Inativa)      1.0   0  
        #          1.0  (Fraca)        1.5   1
        #          1.5  (Ativa)        2.0   2
        #          2.0  (Extrema)            3

mirisa1$cat_amp_num = findInterval(mirisa1$Amplitude,c(1.0,1.5,2.0))


mirisa1$cat_amp_va = findInterval(mirisa1$Amplitude,c(1.5))

mirisa1$seas = NA 
mirisa1$seas[mirisa1$Month %in% c(12,1,2)] = "DJF"
mirisa1$seas[mirisa1$Month %in% c(3,4,5)] = "MAM"
mirisa1$seas[mirisa1$Month %in% c(6,7,8)] = "JJA"
mirisa1$seas[mirisa1$Month %in% c(9,10,11)] = "SON"

#### 
nc <- nc_open("outputs/netcdf/mpi.1981.2022.nc")
rain = ncvar_get(nc, "precip", start=c(1,1,1),count=c(-1,-1,-1))
time_nc = data_nc_convert(nc)
    
mpi=data.frame(data = time_nc,mpi=rain)

####### Avaliando os tempos iguais 

nt_mpi = match(intersect(time_nc,as.character(data1)),time_nc)
nt_mri = match(intersect(time_nc,as.character(data1)),data1)

mpi_t = mpi[nt_mpi,]
mirisa_t = mirisa1[nt_mri,]
dados <- data.frame(data=mpi[nt_mpi,1],mirisa1[nt_mri,],mpi=mpi[nt_mpi,2])

dados$active <- 0
dados$breaks <- 0

dados$active3d <- 0
dados$breaks3d <- 0


#######################################################
    # CONSTRUINDO OS LAGS 

################################
# Lags 
dados$Phase_lag_1  <- dplyr::lag(dados$Phase, 1)
dados$Phase_lag_2  <- dplyr::lag(dados$Phase, 2)
dados$Phase_lag_3  <- dplyr::lag(dados$Phase, 3)
dados$Phase_lag_4  <- dplyr::lag(dados$Phase, 4)
dados$Phase_lag_5  <- dplyr::lag(dados$Phase, 5)
dados$Phase_lag_6  <- dplyr::lag(dados$Phase, 6)
dados$Phase_lag_7  <- dplyr::lag(dados$Phase, 7)
dados$Phase_lag_8  <- dplyr::lag(dados$Phase, 8)
dados$Phase_lag_9  <- dplyr::lag(dados$Phase, 9)
dados$Phase_lag_10 <- dplyr::lag(dados$Phase, 10)
dados$Phase_lag_11 <- dplyr::lag(dados$Phase, 11)
dados$Phase_lag_12 <- dplyr::lag(dados$Phase, 12)
dados$Phase_lag_13 <- dplyr::lag(dados$Phase, 13)
dados$Phase_lag_14 <- dplyr::lag(dados$Phase, 14)
dados$Phase_lag_15  <- dplyr::lag(dados$Phase, 15)
dados$Phase_lag_16  <- dplyr::lag(dados$Phase, 16)
dados$Phase_lag_17  <- dplyr::lag(dados$Phase, 17)
dados$Phase_lag_18 <- dplyr::lag(dados$Phase, 18)
dados$Phase_lag_19 <- dplyr::lag(dados$Phase, 19)
dados$Phase_lag_20 <- dplyr::lag(dados$Phase, 20)
dados$Phase_lag_21 <- dplyr::lag(dados$Phase, 21)
dados$Phase_lag_22 <- dplyr::lag(dados$Phase, 22)
dados$Phase_lag_23 <- dplyr::lag(dados$Phase, 23)
dados$Phase_lag_24 <- dplyr::lag(dados$Phase, 24)
dados$Phase_lag_25 <- dplyr::lag(dados$Phase, 25)
dados$Phase_lag_26 <- dplyr::lag(dados$Phase, 26)
dados$Phase_lag_27 <- dplyr::lag(dados$Phase, 27)
dados$Phase_lag_28 <- dplyr::lag(dados$Phase, 28)

# Lags 
dados$cat_amp_va_lag_1  <- dplyr::lag(dados$cat_amp_va, 1)
dados$cat_amp_va_lag_2  <- dplyr::lag(dados$cat_amp_va, 2)
dados$cat_amp_va_lag_3  <- dplyr::lag(dados$cat_amp_va, 3)
dados$cat_amp_va_lag_4  <- dplyr::lag(dados$cat_amp_va, 4)
dados$cat_amp_va_lag_5  <- dplyr::lag(dados$cat_amp_va, 5)
dados$cat_amp_va_lag_6  <- dplyr::lag(dados$cat_amp_va, 6)
dados$cat_amp_va_lag_7  <- dplyr::lag(dados$cat_amp_va, 7)
dados$cat_amp_va_lag_8  <- dplyr::lag(dados$cat_amp_va, 8)
dados$cat_amp_va_lag_9  <- dplyr::lag(dados$cat_amp_va, 9)
dados$cat_amp_va_lag_10 <- dplyr::lag(dados$cat_amp_va, 10)
dados$cat_amp_va_lag_11 <- dplyr::lag(dados$cat_amp_va, 11)
dados$cat_amp_va_lag_12 <- dplyr::lag(dados$cat_amp_va, 12)
dados$cat_amp_va_lag_13 <- dplyr::lag(dados$cat_amp_va, 13)
dados$cat_amp_va_lag_14 <- dplyr::lag(dados$cat_amp_va, 14)
dados$cat_amp_va_lag_15  <- dplyr::lag(dados$cat_amp_va, 15)
dados$cat_amp_va_lag_16  <- dplyr::lag(dados$cat_amp_va, 16)
dados$cat_amp_va_lag_17  <- dplyr::lag(dados$cat_amp_va, 17)
dados$cat_amp_va_lag_18 <- dplyr::lag(dados$cat_amp_va, 18)
dados$cat_amp_va_lag_19 <- dplyr::lag(dados$cat_amp_va, 19)
dados$cat_amp_va_lag_20 <- dplyr::lag(dados$cat_amp_va, 20)
dados$cat_amp_va_lag_21 <- dplyr::lag(dados$cat_amp_va, 21)
dados$cat_amp_va_lag_22 <- dplyr::lag(dados$cat_amp_va, 22)
dados$cat_amp_va_lag_23 <- dplyr::lag(dados$cat_amp_va, 23)
dados$cat_amp_va_lag_24 <- dplyr::lag(dados$cat_amp_va, 24)
dados$cat_amp_va_lag_25 <- dplyr::lag(dados$cat_amp_va, 25)
dados$cat_amp_va_lag_26 <- dplyr::lag(dados$cat_amp_va, 26)
dados$cat_amp_va_lag_27 <- dplyr::lag(dados$cat_amp_va, 27)
dados$cat_amp_va_lag_28 <- dplyr::lag(dados$cat_amp_va, 28)


###########################
    #
    #  ACTIVE
    #

active_ms = monsoon_active(dados,varname="mpi",1,type="active") 


fases_active <- fase_in_monsoon(dados$Phase,
                              active_ms$start,
                              active_ms$end)

amp_active <- mapply(function(s, e) mean(dados$Amplitude[s:e]),
                     active_ms$start,
                     active_ms$end)


active_ms_all <- data.frame(Index=fases_active$index,
                            active_ms,fases_active[,-1],
                            amplitude=amp_active)

      # active_all_djf = subset(active_ms_all,active_ms_all$seas=="DJF")
      # active_3day_djf = subset(active_all_djf,active_all_djf$length>=3)
   
    #
    #  BREAKS
    #

breaks_ms = monsoon_active(dados,varname="mpi",-1,type="break") 

fases_breaks <- fase_in_monsoon(dados$Phase,
                              breaks_ms$start,
                              breaks_ms$end)

amp_breaks <- mapply(function(s, e) mean(dados$Amplitude[s:e]),
                     breaks_ms$start,
                     breaks_ms$end)

breaks_ms_all <- data.frame(Index=fases_breaks$index,
                            breaks_ms,fases_breaks[,-1],
                            amplitude=amp_breaks)

      # breaks_all_djf = subset(breaks_ms_all,breaks_ms_all$seas=="DJF")
      # breaks_3day_djf = subset(breaks_all_djf,breaks_all_djf$length>=3)

###########################
## Estabelecendo os periodos de active e breaks spell 

  for(i in seq_along(active_ms_all$start)) 
    { dados$active[active_ms_all$start[i]:active_ms_all$end[i]] <- 1 }

  for(i in seq_along(breaks_ms_all$start)) 
    { dados$breaks[breaks_ms_all$start[i]:breaks_ms_all$end[i]] <- 1 }

na = active_ms_all[active_ms_all$length>=3,8:9]

  for(i in seq_along(na$start)) 
    { dados$active3d[na$start[i]:na$end[i]] <- 1 }

nb = breaks_ms_all[breaks_ms_all$length>=3,8:9]

  for(i in seq_along(nb$start)) 
    { dados$breaks3d[nb$start[i]:nb$end[i]] <- 1 }

dados_s1 = subset(dados,dados$seas == "DJF")



###################################################################
####### Dados para avaliação de categorias 
### Avaliação inicial mostrando que existe uma relação 
###  entre actives e breaks spell da monsoon da América do Sul 
###  e as fases e intensidade do mirisa. 

dados_s1 <- dados_s1 %>%
  mutate(
    active3d = as.integer(active3d),
    breaks3d = as.integer(breaks3d),
    Phase = factor(Phase, levels = 1:8),
    cat_amp_va = factor(cat_amp_va, levels = 0:1)
  )
  ### Dados compilados por fase (active e breaks spell >=3)
tab_events_fase <- dados_s1 %>%
   group_by(Phase) %>%
   summarise(
    n_total = n(),
    n_active = sum(active3d),
    freq_active = round(mean(active3d),2),
    n_breaks = sum(breaks3d),
    freq_breaks = round(mean(breaks3d),2),
     .groups = "drop"
   )

 ### Dados compilados por fase e amplitude
events_fase_amp <- dados_s1 %>%
   group_by(Phase, cat_amp_va) %>%
   summarise(
    n_total = n(),
    n_active = sum(active3d),
    freq_active = round(mean(active3d),2),
    n_breaks = sum(breaks3d),
    freq_breaks = round(mean(breaks3d),2),
     .groups = "drop"
   )


  events_fase_amp1 <- events_fase_amp %>%
                filter(cat_amp_va == 1)



tab_temp <- table(dados_s1$active3d[dados_s1$Phase == f])
,
                                dados_s1$cat_amp_va[dados_s1$Phase == f]) 

# # # ACTIVES SPELL
res_active <- lapply(1:8, function(f) {
              tab_temp <- table(dados_s1$active3d[dados_s1$Phase == f],
                                dados_s1$cat_amp_va[dados_s1$Phase == f]) 
  
              test <- chisq.test(tab_temp)
              data.frame( Phase = f,
                          X2 = test$statistic,
                          df = test$parameter,
                          p_value = test$p.value)
              })

res_active <- bind_rows(res_active)

res_active <- res_active %>%
              mutate(
                significant = p_value < 0.05,
                interpretacao = ifelse(significant,
                                "Associação significativa",
                                "Sem evidência"))

f=1
tab_temp <- table(dados_s1$active3d[dados_s1$Phase == f],
                                dados_s1$cat_amp_va[dados_s1$Phase == f]) 


# # # BREAKS SPELLS 

res_break <- lapply(1:8, function(f) {
              tab_temp <- table(dados_s1$breaks3d[dados_s1$Phase == f],
                                dados_s1$cat_amp_va[dados_s1$Phase == f]) 
  
              test <- chisq.test(tab_temp)
              data.frame( Phase = f,
                          X2 = test$statistic,
                          df = test$parameter,
                          p_value = test$p.value)
              })

res_break <- bind_rows(res_break)

res_break <- res_break %>%
              mutate(
                significant = p_value < 0.05,
                interpretacao = ifelse(significant,
                                "Associação significativa",
                                "Sem evidência"))

############################### 



total_active <- sum(dados_s1$active3d == 1, na.rm = TRUE)
total_inactive <- sum(dados_s1$active3d == 0, na.rm = TRUE)

odds_global <- total_active / total_inactive

df_phase <- dados_s1 %>%
  group_by(Phase,cat_amp_va) %>%
  summarise(
    active = sum(active3d == 1),
    inactive = sum(active3d == 0)
  ) %>%
  mutate(
    odds = (active + 0.5) / (inactive + 0.5)
  )

df_phase <- df_phase %>%
  mutate(
    OR = odds / odds_global
  )

df_phase  



head(dados_s1[[nvalores]])



df_phase1 <- dados_s1 %>%
  group_by(!!rlang::sym(nvalores), cat_amp_va) %>%
  summarise(
    active = sum(active3d == 1),
    inactive = sum(active3d == 0),
    .groups = "drop"
  ) %>%
  mutate(
    odds = (active + 0.5) / (inactive + 0.5)
  )


library(dplyr)
library(rlang)
library(tidyr)

total_active <- sum(dados_s1$active3d == 1, na.rm = TRUE)
total_inactive <- sum(dados_s1$active3d == 0, na.rm = TRUE)

odds_global_active <- total_active / total_inactive
odds_global_active

lista_resultados_active <- list()

for (k in 2:28) {

  col_phase <- paste0("Phase_lag_", k)
  col_amp <- paste0("cat_amp_va_lag_", k)

  df_temp <- dados_s1 %>%
    group_by(!!sym(col_phase), !!sym(col_amp)) %>%
    summarise(
      active = sum(active3d == 1, na.rm = TRUE),
      inactive = sum(active3d == 0, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      odds = (active + 0.5) / (inactive + 0.5),
      OR_global = odds / odds_global_active,
      lag = k
    ) %>%
    rename(
      Phase_lag = !!sym(col_phase),
      Amplitude_lag = !!sym(col_amp) 
    )

  lista_resultados_active[[as.character(k)]] <- df_temp
}

resultado_active_lags <- bind_rows(lista_resultados_active)


tabela_or <- resultado_active_lags %>%
  filter(Amplitude_lag == 1) %>%
  select(lag, Phase_lag, OR_global) %>%
  pivot_wider(
    names_from = Phase_lag,
    values_from = OR_global,
    names_prefix = "Phase_"
  )


tab_act_or_long <- tabela_or %>%
  pivot_longer(
    cols = starts_with("Phase_"),
    names_to = "Phase_lag",
    values_to = "OR_global"
  ) %>%
  mutate(
    Phase_lag = factor(Phase_lag, levels = paste0("Phase_", 1:8))
  )


ggplot(tab_act_or_long, aes(x = Phase_lag, y = lag, fill = OR_global)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 1,
    name = "Odds Ratio"
  ) +
  labs(
    x = "Fase",
    y = "Lag"
  ) +
  theme_minimal()


##### Breaks Spell 
total_breaks <- sum(dados_s1$breaks3d == 1, na.rm = TRUE)
total_inbreaks <- sum(dados_s1$breaks3d == 0, na.rm = TRUE)

odds_global_breaks <- total_breaks / total_inbreaks
odds_global_breaks

lista_resultados_breaks <- list()

for (k in 2:28) {

  col_phase <- paste0("Phase_lag_", k)
  col_amp <- paste0("cat_amp_va_lag_", k)

  df_temp <- dados_s1 %>%
    group_by(!!sym(col_phase), !!sym(col_amp)) %>%
    summarise(
      breaks = sum(breaks3d == 1, na.rm = TRUE),
      inbreaks = sum(breaks3d == 0, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      odds = (breaks + 0.5) / (inbreaks + 0.5),
      OR_global = odds / odds_global_breaks,
      lag = k
    ) %>%
    rename(
      Phase_lag = !!sym(col_phase),
      Amplitude_lag = !!sym(col_amp) 
    )

  lista_resultados_breaks[[as.character(k)]] <- df_temp
}

resultado_breaks_lags <- bind_rows(lista_resultados_breaks)


tab_or_breaks <- resultado_breaks_lags %>%
  filter(Amplitude_lag == 1) %>%
  select(lag, Phase_lag, OR_global) %>%
  pivot_wider(
    names_from = Phase_lag,
    values_from = OR_global,
    names_prefix = "Phase_"
  )


tabela_or_long <- tab_or_breaks %>%
  pivot_longer(
    cols = starts_with("Phase_"),
    names_to = "Phase_lag",
    values_to = "OR_global"
  ) %>%
  mutate(
    Phase_lag = factor(Phase_lag, levels = paste0("Phase_", 1:8))
  )

ggplot(tabela_or_long, aes(x = Phase_lag, y = lag, fill = OR_global)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 1,
    name = "Odds Ratio"
  ) +
  labs(
    x = "Fase",
    y = "Lag"
  ) +
  theme_minimal()



######


vars_validas <- names(dados_s1)[
  grepl("lag_[5-9]|lag_1[0-1]", names(dados_s1))
]
dados_mprox <- dados_s1[, c("breaks3d","active3d", vars_validas)]

df_proximo <- dados_mprox %>% 
  rowwise() %>% 
  mutate(
    Phase_lagP = names(sort(table(c_across(Phase_lag_5:Phase_lag_11)), decreasing = TRUE))[1],
    Amp_lagP = names(sort(table(c_across(cat_amp_va_lag_5:cat_amp_va_lag_11)), decreasing = TRUE))[1] ) %>% 
  ungroup()

df_proximo <- df_proximo %>%
  mutate(
    Phase_lagP = factor(Phase_lagP),
    Amp_lagP = factor(Amp_lagP)
  )

model_active3 <- glm(active3d ~Phase_lagP*Amp_lagP,
                      data = df_proximo,
                      family = binomial)

summary(model_active3)

library(brglm2)

model_br <- glm(
  active3d ~ Phase_lagP * Amp_lagP,
  data = df_proximo,
  family = binomial,
  method = "brglmFit"
)

summary(model_br)
prob_mbr <- predict(model_br, type = "response")


library("PRROC")

obs = df_proximo$active3d
prob = prob_mbr
cutoffs <- seq(0.01, 0.25, by = 0.01)

resultado_cut <- data.frame()

for (c in cutoffs) {
  
  pred <- ifelse(prob >= c, 1, 0)
  
  TP <- sum(pred == 1 & obs == 1, na.rm = TRUE)
  TN <- sum(pred == 0 & obs == 0, na.rm = TRUE)
  FP <- sum(pred == 1 & obs == 0, na.rm = TRUE)
  FN <- sum(pred == 0 & obs == 1, na.rm = TRUE)
  
  acc  <- (TP + TN) / (TP + TN + FP + FN)
  sens <- TP / (TP + FN)
  spec <- TN / (TN + FP)
  prec <- TP / (TP + FP)
  f1   <- 2 * (prec * sens) / (prec + sens)
  youden <- sens + spec - 1
  
  resultado_cut <- rbind(
    resultado_cut,
    data.frame(
      cutoff = c,
      TP = TP,
      TN = TN,
      FP = FP,
      FN = FN,
      accuracy = acc,
      sensitivity = sens,
      specificity = spec,
      precision = prec,
      F1 = f1,
      youden = youden
    )
  )
}

resultado_cut[which.max(resultado_cut$youden), ]
resultado_cut[which.max(resultado_cut$F1), ]


cutoff <- 0.12
pred <- ifelse(prob_mbr >= cutoff, 1, 0)
table(Predito = pred, Observado = dados_mprox$active3d)


clim <- mean(df_proximo$active3d)

brier_model1 <- mean((prob_mbr - dados_mprox$active3d)^2)
brier_clim <- mean((clim - dados_mprox$active3d)^2)

skill1 <- 1 - (brier_model1 / brier_clim)


####### #


model_break <- glm(breaks3d ~Phase_lagP*Amp_lagP,
                      data = df_proximo,
                      family = binomial)

summary(model_break)


model_break_bc <- glm(
  breaks3d ~ Phase_lagP * Amp_lagP,
  data = df_proximo,
  family = binomial,
  method = "brglmFit"
)

auc(roc(dados_mprox$breaks3d, predict(model_break, type = "response")))

auc(roc(dados_mprox$breaks3d, predict(model_break_bc, type = "response")))

prob_break2 <- predict(model_break_bc, type = "response")

obs = dados_mprox$breaks3d
prob = prob_break2
cutoffs <- seq(0.01, 0.25, by = 0.01) 

resultado_cut <- data.frame()

for (c in cutoffs) {
  
  pred <- ifelse(prob >= c, 1, 0)
  
  TP <- sum(pred == 1 & obs == 1, na.rm = TRUE)
  TN <- sum(pred == 0 & obs == 0, na.rm = TRUE)
  FP <- sum(pred == 1 & obs == 0, na.rm = TRUE)
  FN <- sum(pred == 0 & obs == 1, na.rm = TRUE)
  
  acc  <- (TP + TN) / (TP + TN + FP + FN)
  sens <- TP / (TP + FN)
  spec <- TN / (TN + FP)
  prec <- TP / (TP + FP)
  f1   <- 2 * (prec * sens) / (prec + sens)
  youden <- sens + spec - 1
  
  resultado_cut <- rbind(
    resultado_cut,
    data.frame(
      cutoff = c,
      TP = TP,
      TN = TN,
      FP = FP,
      FN = FN,
      accuracy = acc,
      sensitivity = sens,
      specificity = spec,
      precision = prec,
      F1 = f1,
      youden = youden
    )
  )
}

resultado_cut[which.max(resultado_cut$youden), ]
resultado_cut[which.max(resultado_cut$F1), ]


cutoff <- 0.12
pred <- ifelse(prob_break2 >= cutoff, 1, 0)
table(Predito = pred, Observado = dados_mprox$breaks3d)


clim <- mean(df_proximo$breaks3d)

brier_model1 <- mean((prob_break2 - df_proximo$breaks3d)^2)
brier_clim <- mean((clim - df_proximo$breaks3d)^2)

skill1 <- 1 - (brier_model1 / brier_clim)
skill1


