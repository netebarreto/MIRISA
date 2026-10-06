# Rotinas do INDEX_MIRISA

Mapa dos scripts existentes. Nomes datados representam versões de trabalho; a numeração dos arquivos não fornece, sozinha, uma sequência executável.

## Etapas e candidatos à consolidação

| Etapa | Arquivos | Situação |
| --- | --- | --- |
| Anomalias e padronização | `SH/AA01-PROC_anom.sh`, `SH/AA01-PROC_R_APAD.sh` | Comandos sobrepostos; corrigir ordem de seleção temporal |
| Filtragem | `R/AA01.00-Filtro_BTW_NC.R`, `R/AA03.00-Filtro_BTW_NC.R` | Métodos distintos: seewave e signal/filtfilt; comparar antes de unificar |
| MCA histórica | `R/AA01.00-MCA_TwoDatasets_20230220.R`, `...20230225.R` | Grande sobreposição; diferenças em sinais e fases |
| Projeção | `R/AA03.00-MIRISA_PROJECAO_20230223.R` | Etapa própria; precisa do modelo e metadados fixos |
| Composições | `R/AA02.00-COMPOSICAO_FASES_MIRI_20211203.R`, `...20260321.R` | Quase duplicatas; versão 2026 troca a entrada de chuva |
| Série regional de chuva | `SH/processamento_chuva_20260312.sh` | CHIRPS; recorte, média regional e anomalia padronizada |
| Monção | `R/Avaliação_Break_Active_Monsoon_20260321.r` | Exploratória; contém bloqueios de execução e avaliação na amostra |
| Diagnósticos de chuva/fase | `R/Avaliação_FasesxChuva_20260321.r` | Parcial e dependente de ajustes |
| Figuras | `PYTHON/`, `GRADS/` | Ver detalhes nos READMEs específicos |
| Onset/demise | `Untitled-1.r` | Rascunho com objetos inconsistentes e entradas ausentes |

## Como preparar uma execução

1. Ler o [README principal](../README.md) e a [avaliação técnica](../AVALIACAO_TECNICA.md).
2. Selecionar explicitamente uma versão por etapa.
3. Fornecer dados, referências, máscara e modelo; conferir unidades/dimensões.
4. Corrigir caminhos e recuperar as funções chamadas por `source()`.
5. Validar datas entre todas as variáveis e entre ajuste/projeção.
6. Executar etapas separadamente e verificar suas saídas antes de continuar.

Não há um lançador único ou ambiente com versões fixadas. Scripts de diagnóstico não substituem etapas de cálculo. O arquivo `Untitled-1.r` e os protótipos devem ficar fora de uma futura execução automática.

As recomendações de consolidação não significam autorização para apagar histórico. A revisão adiciona documentação, sem modificar scripts.
