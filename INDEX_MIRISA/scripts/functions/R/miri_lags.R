

f1 <- function() {shell("cls")}

calcular_composto_fase <- function(fase_num, idx_miri, lags, dados_miri) {
  
  # Matriz de índices (eventos x lags)
  mat_lags <- outer(idx_miri, lags, "+")
  
  # Inicializar vetores para os compostos médios
  comp_c1 <- numeric(length(lags))
  comp_c2 <- numeric(length(lags))
  
  for (i in seq_along(lags)) {
    # Posições no vetor 'miri' para o lag i
    posicoes <- mat_lags[, i]
    
    # Filtrar apenas índices válidos na tabela miri
    posicoes_validas <- posicoes[posicoes >= 1 & posicoes <= n_rows_miri]
    
    # Calcular a média dos compostos (desconsiderando valores NAs se houver)
    comp_c1[i] <- mean(dados_miri$MIRISA1c1[posicoes_validas], na.rm = TRUE)
    comp_c2[i] <- mean(dados_miri$MIRISA1c2[posicoes_validas], na.rm = TRUE)
  }
  
  # Criar dataframe para esta fase
  data.frame(
    Phase = fase_num,
    Lag = lags,
    MIRISA1c1 = round(comp_c1, 4),
    MIRISA1c2 = round(comp_c2, 4),
    Month = 1,    # Valor numérico fictício para compatibilidade
    Year = 2000,  # Valor numérico fictício para compatibilidade
    Day = 1       # Valor numérico fictício para compatibilidade
  )
}



gerar_tabela_lags_miri <- function(idx_miri, vector_lags, total_linhas_miri) {
  # Matriz onde cada linha é um evento e cada coluna é um Lag (-30 a +30)
  mat_lags <- outer(idx_miri, vector_lags, "+")
  
  # Nomeia as colunas conforme o lag (ex: lag_-30, lag_0, lag_30)
  colnames(mat_lags) <- paste0("lag_", vector_lags)
  
  # Trata limites da série temporal 'miri' (se ultrapassar o início ou fim da série total)
  mat_lags[mat_lags < 1 | mat_lags > total_linhas_miri] <- NA
  
  return(as.data.frame(mat_lags))
}