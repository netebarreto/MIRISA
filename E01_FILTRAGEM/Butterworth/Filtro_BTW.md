# Filtro Butterworth

A. Série sintética: sinal 60 dias + ruído 

```R
library(signal)
set.seed(42)
n <- 3650
t <- 1:n
dt <- 1  # passo diário
signal_intra <- sin(2 * pi * t / 60) + 0.5 * sin(2 * pi * t / 45)
noise <- rnorm(n, sd = 0.5)
x <- signal_intra + noise
```

B. Parâmetros dos filtros
```R
low <- 1 / 90
high <- 1 / 30
wn <- c(low, high) * 2  # normalizado para Nyquist (fs = 1)
```
2. Filtro Butterworth (ordem 5)

```R
bf       <- butter(5, wn, type = "pass")
x_butter <- filtfilt(bf, x)
```
Figura 1 – Séries Temporais:
Comparação entre o sinal original, o sinal ideal (componente simulada de 30–90 dias) e a série filtrada por Butterworth. A figura destaca a capacidade do filtro em recuperar a componente intrassazonal com fidelidade, mantendo a fase e reduzindo o ruído de alta frequência.

![](https://github.com/netebarreto/MIRISA/blob/main/E01_FILTRAGEM/Butterworth/Filtro_BTW.png)

