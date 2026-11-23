# FIR com janela Blackman

[Guia dos filtros](../02_filtros.md) · [Implementação](../../scripts/comparar_filtros.py)

**Família:** FIR simétrico projetado pelo método das janelas.

A janela Blackman suaviza o truncamento da resposta ideal. Essa suavização troca supressão dos lóbulos laterais por largura da transição. Não há garantia geral de superar Lanczos em todas as medidas.

```python
h = signal.firwin(numtaps, [1/pmax, 1/pmin],
                  pass_zero=False, window="blackman", fs=1/dt)
```

Em `firwin`, os limites fornecidos correspondem aproximadamente à meia amplitude (−6 dB), e não à meia potência (−3 dB). O script aplica os pesos uma única vez, de forma centrada, preservando essa resposta de amplitude. Usar `filtfilt` novamente elevaria o módulo ao quadrado e mudaria a comparação.

O comprimento é igual ao Lanczos (401 pesos no exemplo). A ordem é comprimento menos um. As primeiras/últimas 200 amostras ficam sem estimativa na convolução centrada de referência.

## O que observar

Consulta o ganho perto dos limites nominais e a atenuação nos limites de rejeição usados pelos IIR. O número de pesos foi fixado para estudo; não se fez otimização para atender às mesmas tolerâncias dos IIR. Aumentar a janela pode melhorar a separação espectral, mas amplia a necessidade de vizinhos temporais.
