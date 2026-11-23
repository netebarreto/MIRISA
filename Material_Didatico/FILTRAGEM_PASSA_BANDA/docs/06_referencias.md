# 6. Referências e documentação

[Índice](../README.md)

## Implementação utilizada

- SciPy: [iirdesign](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.iirdesign.html) — projeto IIR por especificações e saída SOS.
- SciPy: [sosfiltfilt](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.sosfiltfilt.html) e [filtfilt](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.filtfilt.html) — aplicação de ida e volta e tratamento de extremidades.
- SciPy: [firwin](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.firwin.html) — método das janelas; convenção de meia amplitude nos limites.
- SciPy: [cheby2](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.cheby2.html) — interpretação específica das frequências críticas na construção direta.
- SciPy: [Welch](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.welch.html) — estimativa de densidade espectral.

A documentação online pode acompanhar uma versão mais recente. As versões efetivamente executadas constam em `requirements.txt` e `resultados/referencia/execucao.json`.

## Fundamentação

- Duchon, C. E. (1979). Lanczos filtering in one and two dimensions. *Journal of Applied Meteorology*, 18, 1016–1022.
- Oppenheim, A. V.; Schafer, R. W. (2010). *Discrete-Time Signal Processing*. 3ª ed. Pearson.

## Contexto climático do repositório

- Barreto et al. (2019). *Multivariate intraseasonal rainfall index applied to South America*. Meteorological Applications. [doi:10.1002/met.1780](https://doi.org/10.1002/met.1780).

O contexto MIRISA não implica que os seis filtros, a banda 30–90 ou as tolerâncias deste exercício tenham sido usados no artigo. A referência bibliográfica inconsistente a Selesnick/Burrus do material anterior permanece apenas na cópia histórica, sem ser reproduzida como fonte validada do laboratório.
