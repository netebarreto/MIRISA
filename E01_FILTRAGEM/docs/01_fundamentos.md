# 1. O que faz um filtro passa-banda?

[Índice](../README.md) · [Próxima etapa](02_filtros.md)

Uma série pode reunir ciclo anual, oscilações intrassazonais, eventos rápidos, tendência e ruído. O filtro procura preservar uma faixa de frequências e atenuar as demais. Ele não identifica sozinho o mecanismo físico responsável pelo sinal.

## Período e frequência

$$f=1/P,\qquad f_s=1/\Delta t,\qquad f_N=f_s/2.$$

Para preservar períodos entre $P_{min}$ e $P_{max}$:

$$f_{low}=1/P_{max},\qquad f_{high}=1/P_{min}.$$

| Exemplo diário | Frequência em ciclos/dia |
| --- | --- |
| 90 dias: limite inferior em frequência | 0,01111 |
| 30 dias: limite superior em frequência | 0,03333 |
| Amostragem diária | 1 |
| Nyquist | 0,5 |

O período maior corresponde à frequência menor. Exige-se $0<f_{low}<f_{high}<f_N$. O limite de Nyquist não garante, sozinho, amostragem suficiente para caracterizar bem o fenômeno.

Sem o argumento `fs`, várias bibliotecas usam frequências normalizadas por Nyquist: $W=f/f_N=2\Delta t/P$. Com `fs=1/dt`, fornece as frequências em ciclos/dia diretamente, como no script.

## Ganho, transição e fase

- **Ganho de amplitude:** $|H(f)|$; ganho 1 preserva a amplitude daquela frequência.
- **Decibéis de amplitude:** $20\log_{10}|H|$; −6,02 dB corresponde aproximadamente à metade da amplitude.
- **Potência:** é multiplicada por $|H|^2$. Metade da amplitude significa um quarto da potência.
- **Banda de transição:** intervalo entre passagem e rejeição. Um filtro finito não produz a seleção retangular ideal.
- **Ondulação:** variação do ganho dentro de uma banda; não se confunde com oscilação atmosférica.
- **Fase:** determina como a posição temporal das componentes muda. Correlação elevada não garante ganho correto.

## FIR e IIR

FIR combina um número finito de amostras. Com pesos simétricos, sua forma causal tem fase linear e atraso $(L-1)/2$ amostras. A convolução centrada remove esse atraso de alinhamento, mas exige amostras anteriores e futuras. Um FIR simétrico pode apresentar sinal negativo da resposta real fora da passagem; fase nula não deve ser generalizada a todas as frequências.

IIR usa realimentação e possui resposta ao impulso teoricamente infinita. A aplicação causal geralmente produz fase não linear. Seções de segunda ordem (SOS) reduzem problemas de condicionamento numérico em relação a polinômios de alta ordem; não dispensam validação.

## Ida e volta não é apenas remover o atraso

No interior de uma série longa, a aplicação de ida e volta tem resposta efetiva $H(f)H^*(f)=|H(f)|^2$. Portanto, dobra a atenuação em dB e a ordem efetiva, além de cancelar a fase. As extremidades dependem da extensão e das condições iniciais.

O laboratório usa `sosfiltfilt` para IIR e convolução centrada **uma única vez** para FIR. O gráfico mostra a resposta efetivamente aplicada: $|H|^2$ para IIR e $|H|$ para FIR. A frequência nominal fornecida a um construtor não tem a mesma interpretação em todas as famílias; consulta as fichas.
