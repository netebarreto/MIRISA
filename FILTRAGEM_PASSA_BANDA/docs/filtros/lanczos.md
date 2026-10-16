# Lanczos

[Guia dos filtros](../02_filtros.md) · [Implementação](../../scripts/comparar_filtros.py)

**Família:** FIR simétrico com janela sigma. Usa resposta ideal passa-banda truncada e suavizada. O laboratório explicita a convenção da janela para evitar ambiguidades entre número de pesos e meia janela.

Para $L=2M+1$ e $k=-M,\ldots,M$, com $\mathrm{sinc}(u)=\sin(\pi u)/(\pi u)$:

$$h_k=\left[\frac{2f_{high}}{f_s}\mathrm{sinc}\left(\frac{2f_{high}k}{f_s}\right)-\frac{2f_{low}}{f_s}\mathrm{sinc}\left(\frac{2f_{low}k}{f_s}\right)\right]\mathrm{sinc}(k/M).$$

Os pesos são normalizados pelo ganho na frequência central geométrica $f_c=\sqrt{f_{low}f_{high}}$. Isso fixa uma referência de ganho, sem garantir resposta unitária em toda a banda.

**Não normaliza pela soma dos pesos:** essa soma representa o ganho em frequência zero, que deve ser pequeno em um passa-banda. Dividir por ela pode amplificar indevidamente o resultado. Essa operação existia no exemplo anterior e foi corrigida no script novo.

## Aplicação

O script realiza uma convolução centrada, sem `filtfilt`. As primeiras e últimas M amostras são marcadas como NaN, pois faltam vizinhos para a janela completa. A janela de referência tem 401 pesos, logo M=200 dias na amostragem diária. Não confunde esses 200 dias com uma garantia de ausência de efeito de borda nos IIR.

Aumenta ou reduz `numtaps` e examina a resposta; uma janela curta pode não separar bem períodos próximos. Uma convolução centrada exige dados futuros, portanto não está disponível integralmente no último dia de uma série operacional.

Referência clássica: Duchon (1979), listada em [Referências](../06_referencias.md). A fórmula acima documenta a convenção efetivamente implementada neste laboratório.
