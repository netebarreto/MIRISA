# 5. Exercícios e pistas de interpretação

[Índice](../README.md)

| Exercício | Alteração | O que verificar |
| --- | --- | --- |
| Banda | Troca 30–90 por 7–30 dias | Os limites em frequência se invertem em relação aos períodos; a série sintética também adapta seu alvo |
| Janela FIR | Compara 101, 201, 401 e 801 pesos | Transições e ganho nas bordas; quantidade de amostras sem estimativa |
| Tolerâncias IIR | Testa perdas de 0,5 e 2 dB, mantendo rejeição de 40 dB | Ordens necessárias e amplitude recuperada |
| Bordas | Compara `margem_periodos` = 2, 3 e 5 | Mudança das métricas e estabilidade no interior |
| Ruído | Altera o desvio do ruído no script e registra a modificação | Correlação e RMSE dependem do cenário, não só da família |
| Próximo ao limite | Coloca uma senoide a 31 ou 88 dias no exemplo 30–90 | Alta correlação pode coexistir com atenuação da amplitude |
| Fase | Inspeciona `bordas_fase.svg` | Uma passagem causal pode deslocar componentes; ida e volta também muda o ganho |
| Lacuna | Introduz NaN antes de chamar `aplicar` | O programa deve rejeitar a série, sem alterar silenciosamente o calendário |

## Perguntas para discutir

- Por que dividir os pesos de um passa-banda pela sua soma é problemático? **Pista:** essa soma mede a resposta à componente constante.
- Por que dois filtros com a mesma ordem nominal podem ser incomparáveis? **Pista:** famílias, transformação passa-banda e aplicação simples/dupla.
- Por que FIR de fase linear não significa disponibilidade no último dia? **Pista:** centralização exige vizinhos futuros.
- Correlação de 0,99 garante amplitude correta? **Não.** Uma simples multiplicação por uma constante positiva preserva a correlação.
- Qual filtro venceu? **A pergunta está incompleta:** define cenário, critério, tolerâncias e restrições temporais antes.

Para comparação quantitativa entre configurações, mantém o mesmo alvo, a mesma realização de ruído e o mesmo intervalo interior. Trocar banda no arquivo JSON também troca os períodos simulados, portanto caracteriza um novo cenário.
