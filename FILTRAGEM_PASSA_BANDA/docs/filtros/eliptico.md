# Elíptico (Cauer)

[Guia dos filtros](../02_filtros.md) · [Implementação](../../scripts/comparar_filtros.py)

**Família:** IIR com ondulação nas duas bandas.

Pode atender às mesmas exigências com menor ordem, ao custo de ondulações e uma resposta temporal que merece inspeção. Menor ordem não implica menor erro na variável climática de interesse.

## Parâmetros e interpretação

Passagem e rejeição são especificadas separadamente: `gpass` e `gstop`. O script usa metade dos valores finais em dB antes de aplicar ida e volta.

O exemplo usa projeto automático de ordem mínima a partir das mesmas bandas e tolerâncias:

```python
sos = signal.iirdesign(wp, ws, gpass=perda_db/2,
                      gstop=rejeicao_db/2, ftype="ellip",
                      fs=1/dt, output="sos")
y = signal.sosfiltfilt(sos, x)
```

Esse trecho é conceitual; as variáveis são definidas pelo [script completo](../../scripts/comparar_filtros.py). A execução exige série regular e sem valores ausentes.

## O que observar

Compara o ganho dentro da banda, as transições e o RMSE; inspeciona as extremidades. Para estudar fase, compara uma passagem causal (`sosfilt`) com ida e volta, sem assumir que suas amplitudes serão iguais. O gráfico [bordas/fase](../../resultados/referencia/bordas_fase.svg) exemplifica essa distinção com Butterworth.
