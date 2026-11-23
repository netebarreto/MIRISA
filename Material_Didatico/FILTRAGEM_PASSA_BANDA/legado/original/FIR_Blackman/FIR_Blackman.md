
# Filtro FIR com janela Blackman

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

2. Filtro FIR (ordem 100) com janela Blackman  

```R
fir_blackman <- fir1(100, wn, type = "pass", window = blackman(101))
x_fir_black  <- filtfilt(fir_blackman, x)
```

Figura 6 – Séries Temporais:  
O FIR Blackman reduz ondulações laterais (ripples) em relação ao Lanczos, suaviza os efeitos de borda e mantém a estabilidade na captura da variabilidade intrassazonal.  

![](https://github.com/netebarreto/MIRISA/blob/main/E01_FILTRAGEM/FIR_Blackman/Filtro_FIRB.png)

---

# Referências

- Oppenheim, A. V., & Schafer, R. W. (2010). *Discrete-Time Signal Processing*. Pearson.  
- Antoniou, A. (2006). *Digital Signal Processing: Signals, Systems, and Filters*. McGraw-Hill.  
- Harris, F. J. (1978). On the use of windows for harmonic analysis with the discrete Fourier transform. *Proceedings of the IEEE*, 66(1), 51–83.  
- Ifeachor, E. C., & Jervis, B. W. (2002). *Digital Signal Processing: A Practical Approach*. Pearson Education.  
