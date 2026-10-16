# Chebyshev II

[Guia dos filtros](../02_filtros.md) · [Implementação](../../scripts/comparar_filtros.py)

**Família:** IIR com ondulação na rejeição.

A passagem é monotônica e a rejeição apresenta ondulações. A família não deve ser classificada como inerentemente instável; a realização numérica e a ordem importam.

## Parâmetros e interpretação

Na construção direta com `cheby2`, Wn delimita a região onde a atenuação atinge `rs`; não é o mesmo limite de passagem fornecido a `cheby1`. Usa especificações wp/ws para uma comparação consistente.

O exemplo usa projeto automático de ordem mínima a partir das mesmas bandas e tolerâncias:

```python
sos = signal.iirdesign(wp, ws, gpass=perda_db/2,
                      gstop=rejeicao_db/2, ftype="cheby2",
                      fs=1/dt, output="sos")
y = signal.sosfiltfilt(sos, x)
```

Esse trecho é conceitual; as variáveis são definidas pelo [script completo](../../scripts/comparar_filtros.py). A execução exige série regular e sem valores ausentes.

## O que observar

Compara o ganho dentro da banda, as transições e o RMSE; inspeciona as extremidades. Para estudar fase, compara uma passagem causal (`sosfilt`) com ida e volta, sem assumir que suas amplitudes serão iguais. O gráfico [bordas/fase](../../resultados/referencia/bordas_fase.svg) exemplifica essa distinção com Butterworth.
