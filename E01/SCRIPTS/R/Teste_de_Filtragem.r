
library(signal)

# ---- 1. Série sintética: sinal 60 dias + ruído ----
set.seed(42)
n <- 3650
t <- 1:n
dt <- 1  # passo diário
signal_intra <- sin(2 * pi * t / 60) + 0.5 * sin(2 * pi * t / 45)
noise <- rnorm(n, sd = 0.5)
x <- signal_intra + noise

# ---- 2. Parâmetros dos filtros ----
low <- 1 / 90
high <- 1 / 30
wn <- c(low, high) * 2  # normalizado para Nyquist (fs = 1)

# ---- 3. Filtro Butterworth (ordem 5) ----
bf       <- butter(5, wn, type = "pass")
x_butter <- filtfilt(bf, x)

# ---- 4. Filtro Lanczos ----
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

# ---- 5. Filtro Chebyshev Tipo I (ordem 5, ripple 1dB) ----
cf1      <- cheby1(5, Rp = 1, wn, type = "pass")
x_cheby1 <- filtfilt(cf1, x)

# ---- 6. Filtro Chebyshev Tipo II (ordem 5, 40dB rejeição) ----
cf2      <- cheby2(5, Rp = 40,W= wn, type = "pass")
x_cheby2 <- filtfilt(cf2, x)

# ---- 7. Filtro Elliptic (Cauer) (ordem 5, ripple 1dB, stopband 40dB) ----
ef         <- ellip(5, Rp = 1, Rs = 40, wn, type = "pass")
x_elliptic <- filtfilt(ef, x)

# ---- 8. Filtro FIR com janela Blackman ----
fir_n    <- 101
filt_fir <- fir1(fir_n - 1, wn, type = "pass", window = blackman(fir_n))
x_fir    <- stats::filter(x, filt_fir, sides = 2)

# ---- 9. Plotagem comparativa ----
par(mfrow = c(4, 2), mar = c(2, 4, 1.5, 1))

plot(t, x, xlim=c(100,600), type = 'l', col = "gray", main = "Sinal original", ylab = "x(t)")
plot(t, x_butter, xlim=c(100,600), type = 'l', col = "blue", main = "Filtro Butterworth", ylab = "x_filt")

plot(t, x_lanczos, xlim=c(100,600), type = 'l', col = "darkred", main = "Filtro Lanczos", ylab = "x_filt")
plot(t, x_cheby1, xlim=c(100,600), type = 'l', col = "darkgreen", main = "Chebyshev Tipo I", ylab = "x_filt")

plot(t, x_cheby2, xlim=c(100,600), type = 'l', col = "darkorange", main = "Chebyshev Tipo II", ylab = "x_filt")
plot(t, x_elliptic, xlim=c(100,600), type = 'l', col = "purple4", main = "Elliptic (Cauer)", ylab = "x_filt")

plot(t, x_fir, xlim=c(100,600), type = 'l', col = "brown", main = "FIR (Blackman)", ylab = "x_filt")
plot(t, signal_intra, xlim=c(100,600), type = 'l', col = "black", main = "Sinal gerador (ideal)", ylab = "Sinal puro")


round(cor(na.exclude(cbind(signal_intra,x_fir,x_elliptic,x_cheby2,x_cheby1,x_butter,x_lanczos))),3) 


