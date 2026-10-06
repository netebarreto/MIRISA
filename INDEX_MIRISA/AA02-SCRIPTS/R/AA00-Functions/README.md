# Funções auxiliares R

| Arquivo | Conteúdo |
| --- | --- |
| `anomaly.R` | Função anomaly(y, x, level): remove médias por dia do ano ou mês; x deve ser POSIXlt |
| `semanas.i.R` | iden.weekly e n.semana: associação de datas e numeração semanal própria |
| `Documento Sem Título 1` | Rascunho de análise logística sobre objetos externos; não é biblioteca de funções |

## Funções ausentes

As duas rotinas MCA chamam arquivos não presentes nesta pasta: `val2col.R`, `lon.lat.filter.R`, `image.scale.R`, `eof.mca.R` e `color.palette.R`. Elas também procuram `AA00-Functions/cov4gappy.R`; a implementação disponível está em `../cov4gappy.r`, com outro caminho e outra capitalização.

Verificar quais funções são realmente utilizadas; remover chamadas desnecessárias ou recuperar a implementação com procedência e licença. Não criar substitutos silenciosos para funções científicas.

## Ajustes recomendados

- Separar funções puras de análises que dependem de objetos da sessão.
- Em anomaly, definir tratamento de anos bissextos: agrupar por yday pode misturar datas a partir de março entre anos bissextos e comuns.
- Receber período climatológico explicitamente, sem recalcular a referência sobre novos dados.
- Documentar que a numeração semanal existente não está demonstrada como ISO 8601.
- Colocar a conversão temporal e identificação de eventos nesta pasta após resolver nomes, validações e consumidores.

As funções de datas/eventos adicionais estão atualmente um nível acima; consulte o [inventário R](../README.md).
