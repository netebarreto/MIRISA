# 2. Os seis filtros

[Índice](../README.md) · [Experimento](03_experimento.md)

| Filtro | Família | Característica principal | Parâmetro/compromisso |
| --- | --- | --- | --- |
| [Butterworth](filtros/butterworth.md) | IIR | Sem ondulação nas bandas | Transição mais larga para determinada ordem |
| [Chebyshev I](filtros/chebyshev_i.md) | IIR | Ondulação na passagem | Controlar a perda máxima permitida |
| [Chebyshev II](filtros/chebyshev_ii.md) | IIR | Ondulação na rejeição | Controlar a atenuação mínima fora da banda |
| [Elíptico](filtros/eliptico.md) | IIR | Ondulação nas duas bandas | Transição estreita com menor ordem para certas exigências |
| [Lanczos](filtros/lanczos.md) | FIR | Sinc passa-banda com janela sigma | Janela maior melhora a resolução, mas exige mais dados |
| [FIR Blackman](filtros/blackman.md) | FIR | Sinc passa-banda com janela Blackman | Supressão lateral e largura de transição dependem da janela |

Não compares apenas a ordem: um FIR de ordem 400 tem 401 pesos; a ordem informada para um protótipo IIR passa-baixa pode dobrar na transformação passa-banda. A tabela de resultados registra a ordem do filtro passa-banda de **uma passagem**, anterior à aplicação de ida e volta.

O projeto por especificações (`iirdesign`) evita tratar como equivalentes as frequências críticas de `butter`, `cheby1`, `cheby2` e `ellip`. Para os FIR, o comprimento é fixado e a resposta obtida deve ser medida, sem presumir que atenda às tolerâncias dos IIR.
