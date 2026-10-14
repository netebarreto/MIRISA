#!/usr/bin/env Rscript
# Avaliacao do MPI em DJF: tendencia e sensibilidade dos spells >= 3 dias.
# Referencia do MPI: Grimm, Hakoyama & Scheibe (2021), Climate Dynamics,
# DOI: 10.1007/s00382-021-05658-3. Detrending abaixo e uma escolha adicional,
# nao um procedimento atribuido ao artigo. O MPI original nao e sobrescrito.
# Dependencias: install.packages(c('ncdf4', 'sandwich'))
# Terminal:
# Rscript scripts/analysis/avaliar_tendencia_MPI_DJF.R arquivo.nc precip outputs/mpi_tendencia
# Opcional: acrescentar caminho_precipitacao_regional.nc e nome_variavel_precipitacao.
# No RStudio: editar CONFIG abaixo, abrir o script e clicar Source.

CONFIG <- list(
  arquivo_mpi = 'data/monsson_index/mpi_anomalia.nc',
  variavel_mpi = 'precip', saida = 'outputs/anom_tendencia',
  arquivo_chuva = NULL, variavel_chuva = 'precip',
  duracao_minima = 3L,
  cobertura_minima = 0.95, # Temporadas abaixo disso ficam fora do ajuste de tendencia.
  lag_HAC = 2L          # Autocorrelacao entre temporadas; nao entre dias concatenados.
)

ler_nc <- function(arquivo, variavel) {
  nc <- ncdf4::nc_open(arquivo); on.exit(ncdf4::nc_close(nc))
  if (is.null(nc$var[[variavel]])) stop('Variavel ausente: ', variavel)
  dims <- nc$var[[variavel]]$dim
  if (!any(vapply(dims, function(d) d$name == 'time', logical(1))))
    stop('Esperada dimensao time.')
  if (any(vapply(dims, function(d) d$name != 'time' && d$len != 1, logical(1))))
    stop('Fornece uma serie regional: dimensoes espaciais precisam ter tamanho 1.')
  val <- as.numeric(ncdf4::ncvar_get(nc, variavel))
  tt <- as.numeric(ncdf4::ncvar_get(nc, 'time'))
  un <- ncdf4::ncatt_get(nc, 'time', 'units')$value
  cal <- ncdf4::ncatt_get(nc, 'time', 'calendar')
  if (cal$hasatt && !cal$value %in% c('standard','gregorian','proleptic_gregorian'))
    stop('Calendario nao suportado: ', cal$value)
  m <- regexec('^(days?|hours?|minutes?|seconds?) since (.+)$', un)
  tok <- regmatches(un, m)[[1]]
  if (length(tok) != 3) stop('Unidade temporal nao suportada: ', un)
  mult <- if (grepl('^day',tok[2])) 86400 else if (grepl('^hour',tok[2])) 3600 else if (grepl('^minute',tok[2])) 60 else 1
  origin <- gsub('T',' ',tok[3],fixed=TRUE)
  origin <- sub('Z$','',origin)
  origin <- sub(' UTC$','',origin)
  origin <- sub(' [+]00:00$','',origin)
  ref <- as.POSIXct(origin, tz='UTC', tryFormats=c('%Y-%m-%d %H:%M:%OS','%Y-%m-%d %H:%M','%Y-%m-%d'))
  if (is.na(ref)) stop('Origem temporal nao reconhecida: ',origin)
  stamps <- ref + tt*mult
  if (length(val)!=length(tt)) stop('Tamanho da variavel difere de time.')
  ord <- order(stamps); stamps <- stamps[ord]; val <- val[ord]
  dates <- as.Date(stamps,tz='UTC')
  if (anyDuplicated(dates)) stop('Mais de um registro por dia.')
  if (length(stamps)>1 && any(abs(diff(as.numeric(stamps))/86400-round(diff(as.numeric(stamps))/86400))>1e-7))
    stop('Intervalos temporais nao sao numeros inteiros de dias.')
  val[!is.finite(val)] <- NA_real_
  all_dates <- seq(min(dates),max(dates),by='day')
  data.frame(data=all_dates, valor=val[match(all_dates,dates)])
}

regime <- function(x) {
  out <- rep('Intermediario',length(x)); out[is.na(x)] <- 'Ausente'
  out[which(x>=1)] <- 'Active'; out[which(x<=-1)] <- 'Break'; out
}

catalogo <- function(full, valor, years, minimo, versao) {
  r <- regime(valor); z <- list(); k <- 0L
  for (y in years) {
    ii <- which(full$data>=as.Date(sprintf('%d-12-01',y)) & full$data<as.Date(sprintf('%d-03-01',y+1)))
    runs <- rle(r[ii]); fim <- cumsum(runs$lengths); inicio <- fim-runs$lengths+1L
    for (j in seq_along(fim)) {
      if (!runs$values[j] %in% c('Active','Break') || runs$lengths[j]<minimo) next
      ix <- ii[inicio[j]:fim[j]]; left <- min(ix)-1L; right <- max(ix)+1L
      motivo <- character()
      if (left<1 || r[left]=='Ausente') motivo <- c(motivo,'borda_ou_lacuna_esquerda')
      else if (r[left]==runs$values[j]) motivo <- c(motivo,'continua_antes_DJF')
      if (right>length(r) || r[right]=='Ausente') motivo <- c(motivo,'borda_ou_lacuna_direita')
      else if (r[right]==runs$values[j]) motivo <- c(motivo,'continua_apos_DJF')
      k <- k+1L
      z[[k]] <- data.frame(versao=versao,temporada=sprintf('%d/%d',y,y+1),
        regime=runs$values[j],inicio=full$data[min(ix)],fim=full$data[max(ix)],
        duracao_DJF=length(ix),MPI_medio=mean(valor[ix]),
        magnitude_media=mean(abs(valor[ix])),completo_DJF=length(motivo)==0,
        motivo=paste(motivo,collapse=';'))
    }
  }
  if (!length(z)) return(data.frame(versao=character(),temporada=character(),regime=character(),inicio=as.Date(character()),fim=as.Date(character()),duracao_DJF=integer(),MPI_medio=numeric(),magnitude_media=numeric(),completo_DJF=logical(),motivo=character()))
  do.call(rbind,z)
}

main <- function(cfg) {
  for (pkg in c('ncdf4','sandwich')) if (!requireNamespace(pkg,quietly=TRUE))
    stop('Instala o pacote: install.packages("',pkg,'")')
  args <- commandArgs(trailingOnly=TRUE)
  if (length(args)>=1) cfg$arquivo_mpi <- args[1]
  if (length(args)>=2) cfg$variavel_mpi <- args[2]
  if (length(args)>=3) cfg$saida <- args[3]
  if (length(args)>=4) cfg$arquivo_chuva <- args[4]
  if (length(args)>=5) cfg$variavel_chuva <- args[5]
  dir.create(cfg$saida,recursive=TRUE,showWarnings=FALSE)
  csv <- function(x,nome) write.csv(x,file.path(cfg$saida,paste0(nome,'.csv')),row.names=FALSE,na='')
  full <- ler_nc(cfg$arquivo_mpi,cfg$variavel_mpi)
  mes <- as.integer(format(full$data,'%m')); ano <- as.integer(format(full$data,'%Y'))
  inicio_ano <- ano-as.integer(mes!=12)
  years <- sort(unique(inicio_ano[mes %in% c(12,1,2)]))
  years <- years[vapply(years,function(y) as.Date(sprintf('%d-12-01',y))>=min(full$data) &&
    as.Date(sprintf('%d-03-01',y+1))-1<=max(full$data),logical(1))]
  if (length(years)<8) stop('Necessarias pelo menos 8 temporadas integralmente cobertas pelas datas.')
  djf <- mes %in% c(12,1,2) & inicio_ano %in% years
  d <- full[djf,]; names(d)[2] <- 'MPI_original'
  d$ano_inicio <- inicio_ano[djf]; d$temporada <- sprintf('%d/%d',d$ano_inicio,d$ano_inicio+1)
  ss <- do.call(rbind,lapply(years,function(y) {
    q <- d[d$ano_inicio==y,]; ok <- is.finite(q$MPI_original)
    data.frame(ano_inicio=y,temporada=q$temporada[1],esperados=nrow(q),validos=sum(ok),
      cobertura=mean(ok),MPI_media=if(any(ok)) mean(q$MPI_original[ok]) else NA_real_)
  }))
  ss$usada_ajuste <- ss$cobertura>=cfg$cobertura_minima & is.finite(ss$MPI_media)
  if (sum(ss$usada_ajuste)<8) stop('Menos de 8 temporadas com cobertura suficiente.')
  # Diagnostico da tendencia na media por temporada: uma unidade por verao.
  a <- ss[ss$usada_ajuste,]; a$tempo <- a$ano_inicio-mean(a$ano_inicio)
  if (any(diff(a$ano_inicio)!=1)) stop('Ha temporadas excluidas no meio da serie. Revise cobertura_minima/dados antes do teste HAC.')
  fm <- lm(MPI_media~tempo,data=a)
  tendencias <- list()
  trend_row <- function(modelo,nome,lag) {
    b <- coef(modelo)[2]; V <- sandwich::NeweyWest(modelo,lag=min(lag,nobs(modelo)-3L),prewhite=FALSE,adjust=TRUE)
    se <- sqrt(V[2,2]); crit <- qt(.975,df=df.residual(modelo))
    data.frame(serie=nome,n_temporadas=nobs(modelo),inclinacao_por_decada=10*b,
      IC95_inferior=10*(b-crit*se),IC95_superior=10*(b+crit*se),
      p_HAC_aproximado=2*pt(-abs(b/se),df=df.residual(modelo)),lag_HAC=lag)
  }
  for (lag in unique(c(0L,1L,cfg$lag_HAC,3L))) tendencias[[length(tendencias)+1L]] <- trend_row(fm,'MPI_media_DJF',lag)
  # Ajuste da serie diaria em DJF; calendario real, nao indices de vetor concatenado.
  fit_idx <- is.finite(d$MPI_original) & d$ano_inicio %in% a$ano_inicio
  t0 <- mean(as.numeric(d$data[fit_idx])); d$tempo_anos <- (as.numeric(d$data)-t0)/365.2425
  fit_d <- lm(MPI_original~tempo_anos,data=d[fit_idx,])
  beta <- unname(coef(fit_d)[2])
  d$tendencia_removida <- beta*d$tempo_anos
  d$MPI_ajustado <- d$MPI_original-d$tendencia_removida
  # Apenas inclinacao removida: preserva media da amostra usada no ajuste.
  # Nao reescala pela variancia residual e nao modifica os limiares +/-1.
  # Ajuste extrapolado aos dias adjacentes somente para detectar truncamento.
  adj_full <- full$valor-beta*((as.numeric(full$data)-t0)/365.2425)
  ev <- rbind(catalogo(full,full$valor,years,cfg$duracao_minima,'Original'),
              catalogo(full,adj_full,years,cfg$duracao_minima,'Ajustado'))
  d$regime_original <- regime(d$MPI_original); d$regime_ajustado <- regime(d$MPI_ajustado)
  valid <- is.finite(d$MPI_original)
  d$classificacao_mudou <- ifelse(valid,d$regime_original!=d$regime_ajustado,NA)
  ss$MPI_media_ajustado <- vapply(years,function(y) mean(d$MPI_ajustado[d$ano_inicio==y],na.rm=TRUE),numeric(1))
  for (v in c('Original','Ajustado')) for (r in c('Active','Break')) {
    cont <- dias <- numeric(length(years))
    for (i in seq_along(years)) {
      e <- ev[ev$versao==v & ev$temporada==ss$temporada[i] & ev$regime==r,]
      cont[i] <- nrow(e); dias[i] <- sum(e$duracao_DJF)
    }
    ss[[paste('eventos',v,r,sep='_')]] <- cont
    ss[[paste('dias_spells',v,r,sep='_')]] <- dias
    ss[[paste('pct_dias_spells',v,r,sep='_')]] <- ifelse(ss$validos>0,100*dias/ss$validos,NA_real_)
  }
  chuva <- NULL
  if (!is.null(cfg$arquivo_chuva) && nzchar(cfg$arquivo_chuva)) {
    p <- ler_nc(cfg$arquivo_chuva,cfg$variavel_chuva)
    d$chuva_regional <- p$valor[match(d$data,p$data)]
    ss$chuva_media <- vapply(years,function(y) mean(d$chuva_regional[d$ano_inicio==y],na.rm=TRUE),numeric(1))
    ss$cobertura_chuva <- vapply(years,function(y) mean(is.finite(d$chuva_regional[d$ano_inicio==y])),numeric(1))
    chuva <- ss[ss$usada_ajuste & ss$cobertura_chuva>=cfg$cobertura_minima & is.finite(ss$chuva_media),]
    if(nrow(chuva)>=8 && all(diff(chuva$ano_inicio)==1)) {
      chuva$tempo <- chuva$ano_inicio-mean(chuva$ano_inicio)
      fp <- lm(chuva_media~tempo,data=chuva)
      tendencias[[length(tendencias)+1L]] <- trend_row(fp,'Precipitacao_regional_media_DJF',cfg$lag_HAC)
    } else warning('Chuva sem temporadas consecutivas suficientes para inferencia HAC.')
  }
  resumo <- do.call(rbind,lapply(c('Original','Ajustado'),function(v) do.call(rbind,lapply(c('Active','Break'),function(r) {
    e <- ev[ev$versao==v & ev$regime==r,]; ec <- e[e$completo_DJF,]
    data.frame(versao=v,regime=r,eventos=nrow(e),dias_spells=sum(e$duracao_DJF),
      eventos_completos=nrow(ec),mediana_duracao=if(nrow(ec)) median(ec$duracao_DJF) else NA,
      maxima_duracao=if(nrow(ec)) max(ec$duracao_DJF) else NA)
  }))))
  csv(d,'MPI_DJF_diario_original_ajustado'); csv(ss,'MPI_DJF_temporadas')
  csv(ev,'MPI_DJF_eventos_3dias'); csv(resumo,'MPI_DJF_resumo_eventos')
  csv(do.call(rbind,tendencias),'MPI_DJF_tendencias_HAC')
  csv(as.data.frame(table(Original=d$regime_original[valid],Ajustado=d$regime_ajustado[valid])),'MPI_DJF_matriz_reclassificacao')
  fig <- function(nome,fun,width=12,height=8) {
    pdf(file.path(cfg$saida,paste0(nome,'.pdf')),width=width,height=height); fun(); dev.off()
    png(file.path(cfg$saida,paste0(nome,'.png')),width=width,height=height,units='in',res=200); fun(); dev.off()
  }
  # Nao liga pontos diarios entre fevereiro e dezembro: evita falsa continuidade.
  fig('01_diagnostico_tendencia',function() {
    par(mfrow=c(2,1),mar=c(4,4,3,1))
    plot(d$data,d$MPI_original,pch=16,cex=.2,col='#77777755',xlab='Data (dias DJF)',ylab='MPI',main='MPI diario original e componente linear removida')
    lines(d$data,d$tendencia_removida,col='#aa3333',lwd=2); abline(h=c(-1,1),lty=3)
    plot(ss$ano_inicio,ss$MPI_media,type='b',pch=16,xlab='Ano de inicio da temporada DJF',ylab='MPI medio',main='Media por temporada: original e ajustado')
    lines(ss$ano_inicio,ss$MPI_media_ajustado,type='b',pch=1,col='#247d9b')
    lines(a$ano_inicio,fitted(fm),col='#aa3333',lwd=2)
    legend('topright',c('Original','Ajustado','Tendencia da media DJF'),col=c('black','#247d9b','#aa3333'),lty=1,bty='n',cex=.8)
  })
  fig('02_frequencia_spells_por_temporada',function() {
    par(mfrow=c(2,1),mar=c(4,4,3,1))
    for (r in c('Active','Break')) {
      orig <- ss[[paste('pct_dias_spells','Original',r,sep='_')]]
      aj <- ss[[paste('pct_dias_spells','Ajustado',r,sep='_')]]
      plot(ss$ano_inicio,orig,type='b',pch=16,ylim=range(c(0,orig,aj),na.rm=TRUE),xlab='Ano de inicio DJF',ylab='Dias validos (%)',main=paste(r,'spells >=',cfg$duracao_minima,'dias'))
      lines(ss$ano_inicio,aj,type='b',pch=1,col='#247d9b'); legend('topright',c('Original','Ajustado'),col=c('black','#247d9b'),lty=1,bty='n')
    }
  })
  fig('03_distribuicao_e_persistencia',function() {
    par(mfrow=c(1,2),mar=c(4,4,3,1))
    boxplot(d$MPI_original,d$MPI_ajustado,names=c('Original','Ajustado'),col=c('grey80','#8fc3d5'),ylab='MPI',main='Distribuicao dos dias DJF'); abline(h=c(-1,1),lty=3)
    ec <- ev[ev$completo_DJF,]
    if(nrow(ec)) boxplot(duracao_DJF~interaction(regime,versao,sep=' / '),data=ec,las=2,col='grey80',ylab='Duracao (dias)',main='Spells completos dentro de DJF') else plot.new()
  },width=12,height=6)
  if(!is.null(chuva)) fig('04_comparacao_precipitacao',function() {
    par(mfrow=c(2,1),mar=c(4,4,3,1))
    plot(ss$ano_inicio,ss$chuva_media,type='b',pch=16,xlab='Ano de inicio DJF',ylab='Chuva media (unidade da entrada)',main='Precipitacao regional original em DJF')
    plot(ss$chuva_media,ss$MPI_media,pch=16,xlab='Chuva media DJF',ylab='MPI medio DJF',main='Mudanca do MPI tambem aparece na precipitacao?')
  })
  notas <- c('AVALIACAO DO MPI EM DJF',
    paste('Entrada:',cfg$arquivo_mpi),paste('Variavel:',cfg$variavel_mpi),
    paste('Temporadas:',length(years)),paste('Dias validos:',sum(valid)),
    paste('Dias ausentes DJF:',sum(!valid)),
    paste('Inclinacao diaria ajustada (MPI/decada):',signif(10*beta,5)),
    paste('Referencia temporal do ajuste:',as.character(as.Date(t0,origin='1970-01-01'))),
    paste('Dias reclassificados (%):',round(100*mean(d$classificacao_mudou[valid]),2)),
    'A inferencia HAC e aproximada, usa medias por temporada; conferir sensibilidade aos lags 0-3.',
    'O ajuste diario e descritivo: nao utiliza p-valor OLS tratando dias autocorrelacionados como independentes.',
    'A tendencia removida e beta*(t-t0). Nao remove o intercepto nem reescala a variancia.',
    'Ajustado e uma analise de sensibilidade; nao e o MPI recalculado da chuva sem tendencia.',
    'Uma tendencia linear nao diagnostica nem corrige quebras de homogeneidade da base.',
    'Inspecionar quebras visualmente; esta rotina nao executa teste formal de ponto de mudanca.',
    'Temporadas com datas parciais excluidas. Cobertura de valores controlada por CONFIG.',
    'Spells >=3 dias dentro de DJF; lacunas encerram sequencias.',
    'Catalogo inclui segmentos truncados, sinalizados; duracoes resumidas apenas para completos.',
    'Dias em sequencias de 1-2 dias continuam classificados no diagnostico diario, mas nao contam nos spells.',
    'Ajuste extrapolado a dias adjacentes apenas para marcar eventos nas bordas de DJF.',
    'Calendarios suportados: gregoriano/standard/proleptic_gregorian (dados contemporaneos).',
    'Precipitacao opcional deve ser media regional diaria, nao campo espacial nem indice padronizado.',
    'As associacoes com MIRISA ainda precisam ser calculadas nas duas versoes; MIRISA nao e entrada aqui.')
  writeLines(notas,file.path(cfg$saida,'LEIA_ME_resultados.txt'))
  capture.output(sessionInfo(),file=file.path(cfg$saida,'sessionInfo.txt'))
  print(do.call(rbind,tendencias)); print(resumo)
  message('Saidas em: ',normalizePath(cfg$saida,winslash='/'))
}
main(CONFIG)
