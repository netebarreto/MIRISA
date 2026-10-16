# 4. Aplicar a dados climáticos

[Índice](../README.md) · [Exercícios](05_exercicios.md)

1. **Define a variável e o fenômeno.** A banda vem da pergunta científica. 7–30, 10–90 e 30–90 dias não são produtos intercambiáveis.
2. **Confere o eixo temporal.** Amostragem regular, calendário, duplicatas, dias ausentes e unidades devem ser tratados antes. Não removas linhas com lacunas e depois consideres os dias restantes consecutivos.
3. **Documenta o pré-processamento.** Remoção de ciclo climatológico, tendência, padronização e filtragem são operações distintas. A ordem deve seguir a metodologia adotada e os testes de sensibilidade. O laboratório não decide automaticamente o tratamento de tendência do MPI.
4. **Filtra séries contínuas.** Para analisar DJF, em geral convém filtrar a série com contexto anterior/posterior e selecionar a estação depois. Não concatena DJFs separados como se janeiro de um ano fosse vizinho do dezembro seguinte, nem filtra cada estação curta sem contexto suficiente.
5. **Trata lacunas explicitamente.** O exemplo recusa NaN/inf e não interpola. Em observações, define limite de lacunas, eventual interpolação justificada ou filtragem por trechos contíguos, avaliando bordas em cada trecho.
6. **Inspeciona ganho, transientes e robustez.** Testa janelas, ordens/tolerâncias, margens e períodos próximos dos limites. Não basta a série parecer suave.
7. **Distingue análise retrospectiva de previsão.** `sosfiltfilt` e FIR centrado usam dados futuros. A opção causal muda fase e transientes. Em validação de previsão, não filtra toda a série antes de separar treino/teste; isso pode introduzir informação futura. O tratamento deve reproduzir os dados disponíveis em cada data de emissão.

## Relação com o MIRISA

Este módulo ensina filtragem. Não recalcula MCA, fases ou amplitudes do MIRISA e não muda a configuração dos scripts de produção. Substituir o filtro usado no índice pode alterar as séries padronizadas, os padrões ajustados e as classificações; exige reavaliação científica consistente.

Os artigos de Barreto e colaboradores e os estudos posteriores contextualizam o fenômeno. Uma comparação sintética não substitui a verificação da banda, da implementação e dos períodos efetivamente utilizados em cada artigo.

## O que registrar no método

Variável/base; passo temporal; cobertura e referência climatológica; tratamento de tendência e lacunas; banda; família e função; ordem ou número de pesos; tolerâncias; aplicação causal/centrada/ida e volta; extensão de bordas; margem descartada; versões e testes de sensibilidade.
