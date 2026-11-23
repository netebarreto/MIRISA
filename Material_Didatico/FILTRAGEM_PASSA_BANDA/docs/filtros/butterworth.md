# Butterworth

[Guia dos filtros](../02_filtros.md) · [Implementação](../../scripts/comparar_filtros.py)

**Família:** IIR sem ondulação.

A resposta de amplitude é monotônica em cada transição. Para as mesmas tolerâncias, pode exigir ordem maior que Chebyshev ou Elíptico. Não é automaticamente superior para séries climáticas.

## Parâmetros e interpretação

Na construção direta com `butter`, Wn marca o ponto de meia potência (aproximadamente −3 dB) de uma passagem. Após ida e volta, esse ponto fica próximo de −6 dB.

O exemplo usa projeto automático de ordem mínima a partir das mesmas bandas e tolerâncias:

```python
sos = signal.iirdesign(wp, ws, gpass=perda_db/2,
                      gstop=rejeicao_db/2, ftype="butter",
                      fs=1/dt, output="sos")
y = signal.sosfiltfilt(sos, x)
```

Esse trecho é conceitual; as variáveis são definidas pelo [script completo](../../scripts/comparar_filtros.py). A execução exige série regular e sem valores ausentes.

## O que observar

Compara o ganho dentro da banda, as transições e o RMSE; inspeciona as extremidades. Para estudar fase, compara uma passagem causal (`sosfilt`) com ida e volta, sem assumir que suas amplitudes serão iguais. O gráfico [bordas/fase](../../resultados/referencia/bordas_fase.svg) exemplifica essa distinção com Butterworth.
