# Filtro Chebyshev Tipo I

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

B. Filtro Chebyshev Tipo I (ordem 5, ripple = 1 dB)  

```R
cf1      <- cheby1(5, Rp = 1, wn, type = "pass")
x_cheby1 <- filtfilt(cf1, x)
```

Figura 3 – Séries Temporais:  
O Chebyshev Tipo I apresenta bordas mais acentuadas em comparação ao Butterworth, permitindo maior seletividade, mas introduz pequenas ondulações (ripple) na banda de passagem.  

![](https://github.com/netebarreto/MIRISA/blob/main/E01_FILTRAGEM/ChebyshevI/Filtro_CHEBY1.png)

### Referências

- Antoniou, A. (2006). Digital Signal Processing: Signals, Systems, and Filters. McGraw-Hill.

- Ifeachor, E. C., & Jervis, B. W. (2002). Digital Signal Processing: A Practical Approach. Pearson Education.
