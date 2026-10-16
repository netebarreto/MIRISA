# 3. Experimento reproduzível

[Índice](../README.md) · [Aplicação climática](04_aplicacao_climatica.md)

## Série de entrada

O script gera 3650 amostras diárias com semente 42: duas senoides dentro da banda, uma componente de período menor, outra de período maior e ruído branco gaussiano (desvio 0,4). O alvo conhecido é a soma das duas senoides internas. Seus períodos são escolhidos no interior logarítmico da banda e registrados em `execucao.json`.

A série é deliberadamente simples. Não reproduz a distribuição, a intermitência ou a dependência temporal completa da precipitação observada.

## Projeto dos filtros

Para a banda 30–90 dias, wp = [1/90, 1/30] ciclos/dia. Os limites de rejeição são ws = [0,7 × wp[0], wp[1] + 0,3 × min(wp[1], Nyquist − wp[1])]. No exemplo diário, o limite superior equivale a 1,3 × wp[1]. Esses intervalos são escolhas didáticas, não limites físicos universais.

Os quatro IIR são projetados por `iirdesign`, com ordem mínima para cada família. Exige-se, na resposta efetiva de ida e volta, perda máxima de 1 dB na passagem e atenuação mínima de 40 dB na rejeição. O projeto de uma passagem usa 0,5 e 20 dB, respectivamente. Todos usam SOS.

Os dois FIR usam 401 pesos e aplicação centrada única. Os limites nominais da sinc não são limites de passagem com tolerância de 1 dB. Por isso, **a comparação IIR × FIR não iguala tolerâncias**. A comparação entre os IIR controla bandas e tolerâncias; a comparação FIR controla o número de pesos.

## Intervalo comum

Exclui-se de cada extremidade o maior valor entre meia janela FIR e três períodos máximos. No exemplo, são 270 amostras por lado. A escolha de três períodos é uma heurística para o exercício, não uma garantia matemática para todo IIR. Varia essa margem e avalia a estabilidade dos resultados.

As métricas e os espectros usam exatamente o mesmo trecho interior. Os FIR deixam NaN nas bordas sem janela completa; os IIR retornam valores até as extremidades, mas isso não os torna igualmente confiáveis.

## Saídas

| Arquivo | Leitura |
| --- | --- |
| `series.svg` | Entrada, alvo e recuperação pelos seis filtros |
| `resposta.svg` | Ganho efetivo em dB; faixa verde indica banda nominal |
| `espectros.svg` | Densidade espectral por Welch, com mesmo trecho e parâmetros |
| `bordas_fase.svg` | Butterworth causal e retrospectivo; transientes e deslocamentos |
| `metricas.csv` | Ordem, correlação, RMSE, razão de desvios e resposta espectral |
| `series.csv` | Tempo, entrada, alvo e seis séries filtradas |
| `execucao.json` | Configuração, período interior e versões |

RMSE é a raiz do erro quadrático médio em relação ao alvo. A razão de desvios indica recuperação da variabilidade total, sem medir sozinha o ganho de cada componente. As atenuações são medidas numa malha finita de frequências, portanto são aproximações numéricas.

Welch não é a função de transferência do filtro. A densidade espectral de uma única realização depende da duração, da janela e do ruído. Não se aplica teste de significância neste exercício.

## Resultados da configuração de referência

Consulta [metricas.csv](../resultados/referencia/metricas.csv). As diferenças pequenas entre correlações não justificam uma escolha universal. Os filtros FIR atenuam mais perto das bordas nominais; um alvo que inclua componentes próximas desses limites pode produzir um resultado bastante diferente.
