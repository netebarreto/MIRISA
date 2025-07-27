# Avaliação Comparativa de Filtros Digitais para Isolamento da Variabilidade Intrassazonal em Séries Temporais Climáticas

## Resumo

A variabilidade intrassazonal (VISA), associada a oscilações atmosféricas com períodos entre 30 e 90 dias, desempenha papel fundamental na modulação da convecção tropical e na ocorrência de eventos extremos em escala subestacional, como evidenciado pela Oscilação Madden–Julian (MJO). A adequada extração dessa faixa de variabilidade requer a aplicação criteriosa de filtros digitais, cuja escolha influencia a preservação do sinal, a resposta espectral e os efeitos de borda. Este estudo realiza uma avaliação comparativa entre diferentes filtros — Butterworth, Lanczos, Chebyshev Tipo I e II, Elliptic e FIR com janela de Blackman — aplicados a séries sintéticas, simulando condições climáticas realistas. A análise considera a preservação de fase, a energia na banda 30–90 dias e a fidelidade espectral. Os resultados destacam vantagens e limitações específicas de cada abordagem, oferecendo subsídios metodológicos para a escolha de filtros em estudos climatológicos e aplicações operacionais.

## Documentação Teórico-Metodológica dos Filtros Digitais

Este documento descreve, em termos técnicos e aplicados, os principais filtros digitais utilizados para isolar a variabilidade intrassazonal (30–90 dias) em séries temporais climáticas.

---

### 🔹 [Filtro de Lanczos](FLanczos/Filtro_lanczos.md)


**Tipo:** FIR (Resposta finita ao impulso)  
**Características:**
- Utiliza uma janela de suavização (janela de Lanczos) aplicada a um filtro ideal passa-banda.
- Reduz oscilações laterais (“ripples”) em comparação ao filtro retangular.
- Simétrico: preserva a fase (zero-phase) quando aplicado de forma centrada.

**Vantagens:**
- Boa resposta espectral.
- Preserva fase quando aplicado de forma bidirecional (sides = 2).

**Limitações:**
- Perda de dados nas extremidades (efeito de borda).
- Não ideal para aplicações em tempo real.

---

### 🔹 [Filtro de Butterworth](Butterworth/Filtro_BTW.md)

**Tipo:** IIR (Resposta infinita ao impulso)  
**Características:**
- Resposta em frequência suave e monotônica.
- Controlado por ordem (n) e frequência de corte.

**Vantagens:**
- Transição suave entre banda de passagem e rejeição.
- Pode ser aplicado com `filtfilt()` (zero-phase).

**Limitações:**
- Bordas menos abruptas comparado a filtros de Chebyshev ou Elliptic.
- Pode ter resposta temporal mais longa.

---

### 🔹 Filtro de Chebyshev Tipo I

**Tipo:** IIR  
**Características:**
- Ondulação (ripple) na **banda de passagem**, rejeição acentuada fora da banda.
- Controlado por ordem e ripple permitido.

**Vantagens:**
- Transição mais abrupta que Butterworth.
- Menor ordem necessária para alcançar mesma seletividade.

**Limitações:**
- Pode distorcer a amplitude do sinal na banda de interesse.
- Aplicação direta pode induzir defasagem.

---

### 🔹 Filtro de Chebyshev Tipo II

**Tipo:** IIR  
**Características:**
- Ondulação (ripple) **na banda de rejeição**, passagem mais suave.
- Mais raro que Tipo I, mas útil em algumas aplicações climáticas.

**Vantagens:**
- Alta rejeição fora da banda com menor ondulação na banda de passagem.
- Maior controle da rejeição de frequência.

**Limitações:**
- Pode ser mais instável numericamente.
- Dificuldade de interpretar a resposta de fase.

---

### 🔹 Filtro Elliptic (Cauer)

**Tipo:** IIR  
**Características:**
- Ondulações em ambas bandas (passagem e rejeição).
- Maior eficiência espectral (maior rejeição com menor ordem).

**Vantagens:**
- Melhor desempenho em largura de banda limitada.
- Mais seletivo com menor ordem.

**Limitações:**
- Introduz distorções na amplitude (ripple em ambas bandas).
- Potencialmente mais instável e difícil de interpretar.

---

### 🔹 Filtro FIR com janela de Blackman

**Tipo:** FIR  
**Características:**
- Aplicação de uma janela de Blackman sobre a resposta ideal.
- Suaviza ripples e melhora a atenuação fora da banda.

**Vantagens:**
- Preserva fase (simétrico).
- Melhor supressão de frequências indesejadas do que janelas retangulares ou Hamming.

**Limitações:**
- Requer mais coeficientes (maior ordem) para uma transição nítida.
- Perda nas extremidades.

---

### Referências

- Oppenheim, A. V., & Schafer, R. W. (2010). *Discrete-Time Signal Processing*. Pearson.
- Smith, S. W. (1997). *The Scientist and Engineer’s Guide to Digital Signal Processing*. California Technical Pub.
- von Storch, H., & Zwiers, F. W. (1999). *Statistical Analysis in Climate Research*. Cambridge University Press.
