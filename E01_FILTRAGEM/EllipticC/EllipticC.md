
# Filtro Elliptic (Cauer)


### ---- A. Série sintética: sinal 60 dias + ruído ----
```R
# pacote utilizado
library(signal)

set.seed(42)
n <- 3650
t <- 1:n
dt <- 1  # passo diário
signal_intra <- sin(2 * pi * t / 60) + 0.5 * sin(2 * pi * t / 45)
noise <- rnorm(n, sd = 0.5)
x <- signal_intra + noise
```

### ---- B. Parâmetros dos filtros ----
```R
low <- 1 / 90
high <- 1 / 30
wn <- c(low, high) * 2  # normalizado para Nyquist (fs = 1)
```

### ---- 7. Filtro Elliptic (Cauer) (ordem 5, ripple 1dB, stopband 40dB) ----

```R
ef         <- ellip(5, Rp = 1, Rs = 40, wn, type = "pass")
x_elliptic <- filtfilt(ef, x)
```


Figura 5 – Séries Temporais:  
O Elliptic combina alta eficiência na rejeição de frequências e bordas muito acentuadas, mas introduz ondulações tanto na banda de passagem quanto na de rejeição.  

![](https://github.com/netebarreto/MIRISA/blob/main/E01_FILTRAGEM/Elliptic/Filtro_ELLP.png)

---

