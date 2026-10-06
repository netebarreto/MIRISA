# Avaliação técnica — INDEX_MIRISA

Revisão em 06/10/2026 da árvore em `794f82559f982efe9b14babd0c8069c6a144747e`. Escopo principal: INDEX_MIRISA; inspeção da árvore e README da raiz para contexto.

## Parecer

O material contém etapas úteis de uma cadeia científica (pré-processamento, filtragem, MCA, projeção e diagnóstico), mas ainda é uma coleção de rotinas de trabalho. Não está pronto para reprodução integral por terceiros. Os principais riscos são diferenças entre a definição publicada e a série exportada, referências/modelos não disponíveis, inconsistências temporais e avaliação estatística sem separação entre ajuste e verificação.

Esta revisão adiciona sete READMEs e este relatório. Não altera cálculos, remove arquivos ou escolhe definitivamente uma versão científica.

## 1. Redundâncias e versões

Os caminhos abaixo são relativos a AA02-SCRIPTS.

| Grupo | Evidência | Recomendação |
| --- | --- | --- |
| `R/AA02.00-COMPOSICAO_FASES_MIRI_20211203.R` e `...20260321.R` | A comparação mostra apenas a troca do caminho/arquivo de chuva e uma chamada library adicional | Unificar com entrada configurável; preservar ambas no histórico. A versão 2026 não corrige os demais problemas |
| `PYTHON/DIAGRAM_PSPACE_MIRISA_20230501.py` e `teste_DP.py` | Mesmo núcleo de trajetória; diferenças em entrada, 40/90 dias, recorte de cores, anotações e nome da figura | Consolidar em função parametrizada; versão 20230501 como candidata, após validação |
| `PYTHON/diagram_space_phase.py` e `...20230429.py` | Diagramas anteriores com falhas e lógica semelhante | Arquivar como protótipos após extrair elementos úteis |
| Duas rotinas `R/AA01.00-MCA_TwoDatasets_20230220.R` / `...20230225.R` | Quase todo o cálculo coincide; versão 25 altera sinais de v/B e ordem dos argumentos de perfil1 | Consolidar somente após validar sinais e fases. São variantes científicas, não cópias intercambiáveis |
| `R/model_active_break_spell.r` / `Avaliação_FasesxChuva_20260321.r` / `Avaliação_Break_Active_Monsoon_20260321.r` | Repetem leitura do índice/MPI, categorias e pareamento temporal | Extrair preparação de dados compartilhada; manter análises distintas |
| `SH/AA01-PROC_R_APAD.sh` / `AA01-PROC_anom.sh` | Repetem cálculo do desvio, divisão e médias equatoriais em diferentes blocos/caminhos | Separar ajuste da referência e aplicação por período |
| `R/AA01.00-Filtro_BTW_NC.R` / `AA03.00-Filtro_BTW_NC.R` | Mesma finalidade, mas seewave::bwfilter versus signal::butter/filtfilt; variáveis/períodos distintos | Não descartar como duplicatas. Comparar resposta em frequência, fase, bordas e lacunas antes de unificar |
| `R/filtro.R` / `PYTHON/filtro_butterworph.py` | Experimentos de filtro incompletos; filtro.R contém exemplo sísmico residual | Isolar em experiments, não na cadeia principal |
| `R/AB01.01- MIRISA_FORECAST_MVAR` sem extensão | Apenas fragmento de exportação com objetos externos | Incorporar onde couber e arquivar fragmento |
| `R/AA00-Functions/Documento Sem Título 1`, `Untitled-1.r` | Rascunhos, não bibliotecas reutilizáveis | Renomear/documentar e retirar da cadeia operacional |

Não foram encontradas rotinas textualmente idênticas nesses grupos principais; a redundância é de blocos e finalidade. Os dois notebooks têm sobreposição em estatísticas de amplitude/sazonalidade, mas conteúdos e problemas diferentes: não são duplicatas integrais.

## 2. Ajustes científicos prioritários

### P0 — O índice exportado difere da definição publicada

Na seção 2 de Barreto et al. (2019), cada componente é definida pela média dos coeficientes de expansão do lado da precipitação e do lado atmosférico: `(a_i+b_i)/2`.

Na MCA 20230225, linhas 309–316, são calculados coeficientes A e B normalizados por sqrt(Lambda), mas index1/index2 recebem apenas B. A projeção também usa somente OLR/U850/U200.

Isso pode corresponder a uma variante intencional de projeção, mas sua equivalência ao índice publicado não foi demonstrada pelo conteúdo disponível. Documentar o nome da variante, normalização e justificativa; comparar ambas as séries no período comum, incluindo amplitudes, fases e composições. Não substituir o algoritmo sem essa análise.

### P0 — Filtro e disponibilidade de informação

- `AA03.00-Filtro_BTW_NC.R` usa filtfilt bilateral. Dados posteriores influenciam a estimativa de cada dia. Uma avaliação retrospectiva com lags pode ganhar informação futura por esse caminho. Reproduzir o que estaria disponível em cada data antes de alegar previsão operacional.
- `filtro_butterworph.py` usa fs=2191, lowcut=20 e highcut=100. Para séries diárias, a banda pretendida usa fs=1 e frequências 1/100–1/20 ciclos/dia. A configuração atual não representa a banda diária 20–100 dias.
- lfilter e filtfilt têm respostas de fase distintas; não atribuir toda diferença R/Python à linguagem.
- O preenchimento de OLR em índices 1375:1378 está fixo e usa uma média comum de dias vizinhos. Identificar lacunas por datas, registrar imputação e examinar seu efeito.
- Quando uma série tem NA, os filtros R podem deixar todo o ponto sem resultado. Inicializar explicitamente como NA_real_, documentar tratamento e conferir cobertura. `array(numeric(), ...)` não expressa claramente o contrato de missing.
- A remoção de tendência mencionada no artigo de 2019 não aparece explicitamente nos comandos de pré-processamento examinados. Verificar se foi feita antes das entradas, sem presumir sua ausência nos dados externos.

### P0 — Referência temporal no CDO

Nos dois Shell, há comandos do tipo `-seldate,... -timstd entrada.nc`. O desvio é calculado antes da seleção temporal, porque CDO processa da direita para a esquerda.

Para limitar a amostra do desvio, usar `-timstd -seldate,... entrada.nc`. Mesmo que a entrada já tenha exatamente o período desejado, isso precisa ser explícito e verificável. Referência técnica: [CDO](https://code.mpimet.mpg.de/boards/1/topics/4550).

Os scripts misturam referências 1981–2010, desvios 1991–2020 e períodos de MCA/diagnóstico diferentes. Essa combinação não é automaticamente inválida, mas precisa ser fixada e documentada. Nomes de arquivos não comprovam o período realmente utilizado.

### P0 — Fases e sinais

- Em perfil1, `as.integer(angl/45)+1` produz 9 se angl=360; substituir por uma operação circular validada, preservando a convenção física.
- Os gráficos antigos e novos apresentam rótulos diferentes e inversão do eixo y. Verificar centros de todos os oito setores com pontos de fase conhecida.
- A versão MCA 25 inverte v/B sem inverter u/A. Uma transformação de sinais escolhida por lado precisa ser explícita; não tratar isso como mudança pareada que mantém a reconstrução SVD de C.
- A projeção usa `L$v * -1`, mas grava v sem essa inversão no objeto reconstruído. Usar uma única matriz orientada, persistida e utilizada em todos os produtos.

### P0 — Exemplos artificiais no notebook

`Artigo1_MIRISA_Fig3a9.ipynb`, célula 18 (índice zero), implementa calcula_fase com randint(1,9). As composições e probabilidades seguintes utilizam essas fases aleatórias.

O código está marcado como placeholder, mas continua executável. Separar exemplos em notebook próprio, substituir pelas fases reais e bloquear análise científica enquanto faltarem campos/variáveis. O notebook também usa mirisa_clim, mirisa_proj, precip e olr sem definições executáveis suficientes. Há rótulos RMM sobre dados MIRISA.

## 3. Bloqueios de execução e integridade dos produtos

| Prioridade | Arquivo/trecho | Problema e ajuste |
| --- | --- | --- |
| P0 | MCA, source nas linhas 9–15 | Cinco auxiliares ausentes; cov4gappy existe em outro caminho/capitalização. Recuperar ou retirar chamadas comprovadamente dispensáveis |
| P0 | Projeção, load | Procura MCA_SA_20230226.RData; versão disponível grava 20230225. Não há RData no repositório |
| P0 | Avaliação_Break_Active, linhas 258–260 | table malformada e vírgula isolada impedem análise sintática do script |
| P1 | Mesmo arquivo, linha 338 em diante | nvalores não definido; ggplot sem importação explícita de ggplot2 |
| P1 | Composições, precipitação | Versão 2026 seleciona dias do índice até 2020, mas lê chuva até 2016; match produz NA para datas ausentes. Restringir ao período comum |
| P1 | Composições, bloco V850 | Reutiliza nt.f calculado para U200 sem refazer correspondência temporal; d.hoje não definido; dimensões de leitura inconsistentes |
| P1 | Avaliação_FasesxChuva | Declara varname=precip, depois lê rain; image.plot depende de importação não declarada |
| P1 | Forecast MVAR e comparação | Objetos mirisa/miri não definidos, exemplos GDPGrowth/TSpread residuais; não são rotinas completas de previsão |
| P1 | Untitled-1.r | Cria ptdas e usa pentadas; depende de onset/demise não versionados |
| P1 | diagram_space_phase_20230429.py | ax=plt.subplots() retorna tupla; ax.add_collection falha. Tuplas multiplicadas por -1 não negam coordenadas |
| P1 | diagram_space_phase.py | plt.text recebe séries em vez de coordenadas/texto escalares |
| P1 | Diagramas recentes | Loops usam nt fixo, mesmo se tail retorna menos linhas; cores de segmentos carecem de limites explícitos |
| P1 | MCA, reconstrução v | Índices fixos 1:360/361:504/505:648 pressupõem grades específicas. Derivar cortes das dimensões e validar coordenadas |
| P1 | NetCDF | OLR rotulado m/s ou mm/dia; ventos rotulados mm/dia; padrões/modos representados por datas fictícias. Corrigir atributos e dimensões |
| P1 | MCA/consumidores | day versus Day; TxT versus txt; INPUT_NC/AA00/AA01; caminhos Windows fixos |
| P2 | Mapas Python | Títulos RR1/SDII em padrões MCA; arquivo de figura nomeado como diagrama; revisar legendas e nomes |
| P2 | Sessão R | save(list=ls()) e load carregam ambiente completo; salvar modelo autocontido com metadados |
| P2 | Entrada/saída NetCDF | Leituras sem fechamento consistente; incluir nc_close e verificações de sucesso |

## 4. MCA, covariância e interpretação

1. No cálculo MCA, a máscara de válidos é obtida antes de substituir NA por zero, mas a máscara usada depois em A_norm/B_norm é reconstruída após essa substituição. Com lacunas, zeros passam a ser tratados como observações válidas. Preservar máscara original em todas as etapas.
2. cov4gappy calcula produto cruzado por número de pares, sem centragem interna. Isso só representa a covariância pretendida sob o contrato de dados previamente centrados; explicitar e validar.
3. Divisão por zero e Inf não são tratados de forma suficiente. Conferir n_pairs e normas, além de NA.
4. `expl_var = d/sum(d)` não deve ser apresentada como fração de variância explicada dos campos. `d²/sum(d²)` é a SCF. Fração de variância de cada campo é outro diagnóstico.
5. Lambda_err usa o mínimo do número de pontos espaciais na fórmula de separação. Essa escolha não representa o tamanho amostral temporal efetivo e requer revisão metodológica para MCA; não considerar NORTHok comprovação de significância.
6. Conferir alinhamento de datas entre chuva, OLR e ventos; número igual de linhas não garante dias iguais.
7. Validar máscara, orientação lat/lon, conversão array–matriz e pesos espaciais com um exemplo pequeno conhecido.
8. Salvar a ordem exata de variáveis, coordenadas, período, climatologias, desvios e sinais junto do modelo.

## 5. Monção e inferência estatística

### MPI e eventos

Grimm et al. (2021), seções 2.2–2.3, utiliza anomalia padronizada da chuva média em 10°–20°S, 45°–55°W, com dados pluviométricos ANA. O texto descreve suavização do ciclo diário por média móvel de 31 dias e climatologias 1999–2010 para compatibilidade com reforecasts; também apresenta resultados observados para período mais longo.

O Shell usa CHIRPS, referência 1981–2022 e ciclo diário sem essa suavização explícita. Documentar como adaptação, não reprodução exata do MPI original. Falta a ligação explícita entre teste2.nc e mpi.1981.2022.nc.

Os limiares ±1 correspondem à definição de dias ativos/inativos na fonte. A duração ≥3 dias é escolha adicional implementada na análise e não deve ser atribuída automaticamente a Grimm (2021).

monsoon_active usa rle de posições consecutivas, sem checar continuidade do calendário, NA ou tipo inválido. Tratar ausência de eventos e interromper sequências em lacunas. Definir como atribuir eventos que cruzam meses/estações. O código detecta eventos na série inteira e só depois recorta DJF; registrar essa regra.

### Frequências, odds e modelos

- As tabelas contam dias em eventos, não eventos independentes.
- Testes t pontuais e qui-quadrado diário ignoram dependência serial; avaliar incerteza com blocos temporais/eventos e corrigir multiplicidade conforme o desenho.
- OR_global divide odds do subgrupo por odds globais que incluem o próprio subgrupo. Descrever como razão relativa à amostra global, sem interpretar como efeito independente ou risco relativo.
- A correção +0,5 aparece nos subgrupos, mas não no denominador global; documentar e harmonizar a estimação.
- O código efetivamente ajusta glm, não glmer: o cabeçalho GLMM é incorreto.
- AUC, Brier, Brier Skill e seleção de cutoff são calculados com as respostas utilizadas no ajuste. Esses resultados descrevem desempenho aparente; não demonstram habilidade fora da amostra.
- Validar por anos/verões, com referência/preparação ajustadas apenas no treino e proteção contra informação futura do filtro bilateral.
- Fixar decisão sobre lags 0/1/2–28; o código cria lag 1, mas algumas avaliações começam em 2.
- Fase modal e amplitude modal são estimadas separadamente em 5–11 dias; sua combinação pode não ter ocorrido em nenhum dia. Definir empates e testar alternativa conjunta.
- O padrão grepl para selecionar lags não tem âncora final e pode selecionar colunas 10–19; tornar a seleção explícita.
- Registrar número de dias/eventos por combinação, incerteza e baseline climatológico por verão/estação.
- brglm2 ajuda em separação, mas não resolve dependência serial nem substitui validação temporal.

## 6. Organização proposta após validação

| Destino proposto | Conteúdo |
| --- | --- |
| config/ | Caminhos, períodos, referências, grades, filtros e limiares |
| scripts/preprocess/ | Anomalias, filtragem e padronização |
| scripts/index/ | Ajuste MCA e projeção |
| scripts/analysis/ | Eventos, composições, associação e validação |
| scripts/plots/ | Diagramas/mapas |
| functions/ | Conversão temporal, fases, eventos e leitura comum |
| experiments/ | Protótipos, testes manuais e notebooks de exemplo |
| data/ e outputs/ | Contratos e diretórios locais; dados volumosos fora do Git |

Configuração, ambiente com versões fixas, licença e metadados de citação são próximos passos. A raiz contém ainda uma entrada MIRISA de modo 160000 (gitlink), sem .gitmodules na árvore: verificar intenção e origem antes de alterá-la. Não se trata de uma pasta comum copiável pelo Git.

Ordem recomendada: recuperar dependências/dados → fixar definição/sinais/referências → corrigir bloqueios → validar ajuste/projeção → consolidar duplicatas → reorganizar → avaliar previsão fora da amostra.

## 7. Verificação realizada e limites

- Leitura das rotinas R, Shell, Python e GrADS e do código dos dois notebooks.
- Comparação textual das famílias de versões, incluindo composição, MCA e diagrama.
- Python: seis scripts e 21 células de código passaram na análise sintática AST.
- Shell: três scripts passaram em bash -n.
- Consulta direta aos PDFs anexados, especialmente métodos de Barreto (2019) e Grimm (2021).
- Consulta à documentação técnica de [CDO](https://code.mpimet.mpg.de/boards/1/topics/4550) e [SciPy filtfilt](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.filtfilt.html).

Não houve execução integral R/CDO/GrADS nem comparação numérica com o índice de referência: dados, funções e modelos não estão presentes; R e CDO não estão instalados no ambiente da revisão. Achados distinguem falhas observáveis no código de ajustes científicos que precisam de experimentação.
