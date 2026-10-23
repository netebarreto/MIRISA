# Chebyshev I

[Guia dos filtros](../02_filtros.md) · [Implementação](../../scripts/comparar_filtros.py)

**Família:** IIR com ondulação na passagem.

Troca uniformidade de amplitude na banda por maior seletividade para determinada ordem. A ondulação deve ser avaliada especialmente quando amplitudes ou limiares de eventos são relevantes.

## Parâmetros e interpretação

`rp` limita a perda/ondulação em dB na passagem. O laboratório projeta com metade da perda desejada, porque a aplicação de ida e volta dobra os dB.

O exemplo usa projeto automático de ordem mínima a partir das mesmas bandas e tolerâncias:

```python
sos = signal.iirdesign(wp, ws, gpass=perda_db/2,
                      gstop=rejeicao_db/2, ftype="cheby1",
                      fs=1/dt, output="sos")
y = signal.sosfiltfilt(sos, x)
```

Esse trecho é conceitual; as variáveis são definidas pelo [script completo](../../scripts/comparar_filtros.py). A execução exige série regular e sem valores ausentes.

## O que observar

Compara o ganho dentro da banda, as transições e o RMSE; inspeciona as extremidades. Para estudar fase, compara uma passagem causal (`sosfilt`) com ida e volta, sem assumir que suas amplitudes serão iguais. O gráfico [bordas/fase](../../resultados/referencia/bordas_fase.svg) exemplifica essa distinção com Butterworth.
