

monsoon_active <- function(dataset,varname="vname",lim,type="active") {


index <- dataset[[varname]]

if(type == "active") { is_events <- index >= lim }
if(type == "break") { is_events <- index <= lim }
if(type == "neutral") { is_events <- index > -abs(lim) & index < abs(lim) }


r <- rle(is_events)
ends   <- cumsum(r$lengths)
starts <- ends - r$lengths + 1

evt_idx <- which(r$values)  # só sequências de dias chuvosos
len_run <- r$lengths[evt_idx]
st_run  <- starts[evt_idx]
en_run  <- ends[evt_idx]
md_run  <- (st_run + as.integer((en_run - st_run)/2))


tot_run <- mapply(function(s, e) mean(index[s:e]), st_run, en_run)
max_run <- mapply(function(s, e) max(index[s:e]), st_run, en_run)
min_run <- mapply(function(s, e) min(index[s:e]), st_run, en_run)

# Se quiser as janelas identificadas:
result <- data.frame(data=dataset$data[md_run],
                     ano=dataset$Year[md_run],
                     seas=dataset$seas[md_run],
                     month=dataset$Month[md_run],
                     data_start=dataset$data[st_run],
                     data_end=dataset$data[en_run],
                     start=st_run, end=en_run, 
                     length=len_run, mean=tot_run,
                     max=max_run,min=min_run)
return(result) 
}

fase_in_monsoon <- function(phase,starts,ends) { 
    
    fases_list <- mapply(function(s, e) {
      tab <- table(factor(phase[s:e], levels = 1:8))  
            setNames(as.integer(tab), paste0("f", 1:8))},
            starts, ends, SIMPLIFY = FALSE)

    fases_df <- do.call(rbind, fases_list) |> as.data.frame()

    fases_df$index <- seq_len(nrow(fases_df))
    
    fases_df <- fases_df[, c("index", paste0("f", 1:8))]
    
    return(fases_df)}

