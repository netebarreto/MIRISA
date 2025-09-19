
---

# Filtro Chebyshev Tipo II

### A. Série sintética: sinal 60 dias + ruído ----

```R
set.seed(42)
n <- 3650
t <- 1:n
dt <- 1  # passo diário
signal_intra <- sin(2 * pi * t / 60) + 0.5 * sin(2 * pi * t / 45)
noise <- rnorm(n, sd = 0.5)
x <- signal_intra + noise
```

### B. Parâmetros dos filtros ----

```R
low <- 1 / 90
high <- 1 / 30
wn <- c(low, high) * 2  # normalizado para Nyquist (fs = 1)
```

### C. Filtro Chebyshev Tipo II (ordem 5, rejeição mínima = 40 dB)  

```R
cf2      <- cheby2(5, Rs = 40, wn, type = "pass")
x_cheby2 <- filtfilt(cf2, x)
```

Figura 4 – Séries Temporais:  
O Chebyshev II apresenta rejeição mais eficiente fora da banda de interesse, com bordas nítidas, mas pode introduzir ondulações na banda de rejeição.  

![](https://github.com/netebarreto/MIRISA/blob/main/E01_FILTRAGEM/ChebyshevII/Filtro_ChebyshevII.png)

---
