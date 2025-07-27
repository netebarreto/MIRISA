# Filtro de Lanczos

1. Série sintética: sinal 60 dias + ruído

```R
set.seed(42)
n <- 3650
t <- 1:n
dt <- 1  # passo diário
signal_intra <- sin(2 * pi * t / 60) + 0.5 * sin(2 * pi * t / 45)
noise <- rnorm(n, sd = 0.5)
x <- signal_intra + noise
```

2. Parâmetros dos filtros

```R
low <- 1 / 90
high <- 1 / 30
wn <- c(low, high) * 2  # normalizado para Nyquist (fs = 1)

```

3. Filtro Lanczos
   
``` R
lanczos_filter <- function(x, low, high, n=101, dt=1)
{
  w <- rep(0, n)
  mid <- (n - 1) / 2
  for (i in 0:(n - 1)) {
    k <- i - mid
    if (k == 0)
    {
      w[i + 1] <- 2*(high - low)/dt
    } else 
    {
      w[i + 1] <- (sin(2*pi*high*k*dt) - sin(2*pi*low*k*dt))/(pi*k*dt)
      w[i + 1] <- w[i + 1]*(sin(pi*k/n)/(pi*k/n))
    }
  }
  w <- w / sum(w)
  stats::filter(x, w, sides=2)
}
x_lanczos <- lanczos_filter(x, low, high, n = 101)
```
Figura 1 – Séries Temporais:
Comparação entre o sinal original, o sinal ideal (componente simulada de 30–90 dias) e a série filtrada por Lanczos. A figura destaca a capacidade do filtro em recuperar a componente intrassazonal com fidelidade, mantendo a fase e reduzindo o ruído de alta frequência.

![](https://github.com/netebarreto/MIRISA/blob/main/E01_FILTRAGEM/FLanczos/Filtro_LCZ.png)


6. grafico Espectro
 ``` R   

# exemplo_filtros_simulados.R
# ---- 10. Função para espectro normalizado ----
get_spectrum <- function(x, dt = 1) {
  n <- length(x)
  x <- x - mean(x, na.rm = TRUE)
  fft_result <- abs(fft(x))^2 / n
  freq <- (0:(n - 1)) / (n * dt)
  list(freq = freq[1:(n/2)], spectrum = fft_result[1:(n/2)])
}

# ---- 11. Calcular espectros ----
spec_orig     <- get_spectrum(x)
spec_lanczos  <- get_spectrum(na.exclude(x_lanczos))

png("Espectros_FLanczos.png",height=400, width=700,pointsize=12)

# ---- 12. Plotagem dos espectros ----
plot(spec_orig$freq, spec_orig$spectrum, type = 'l', col = "darkgray", log = "y",
     xlim = c(0.002, 0.1), ylim = c(1e-5, 2*max(spec_orig$spectrum)),
     main = "Espectros de Potência (FFT)", xlab = "Frequência (ciclos/dia)",
     ylab = "Potência (log)", lwd = 1)
lines(spec_lanczos$freq,  spec_lanczos$spectrum, col = "red",   lwd = 1.5)

legend("topright", legend = c("Original", "Lanczos"),
       col = c("gray", "red"), lwd = 2)
abline(v = c(1/90, 1/30), lty = 2, col = "black")  # Marcar banda 30–90 dias
dev.off()


################################
```
Figura 2 – Espectro de Potência (FFT):
O gráfico mostra os espectros do sinal original e do filtrado por Lanczos. Observa-se que o filtro atenua eficientemente as frequências fora da banda de 30–90 dias (demarcada por linhas tracejadas), mantendo a energia na banda de interesse com preservação espectral

![](https://github.com/netebarreto/MIRISA/blob/main/E01_FILTRAGEM/FLanczos/Espectros_FLanczos.png)


