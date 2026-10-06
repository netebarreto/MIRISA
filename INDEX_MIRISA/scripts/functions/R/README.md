# Auxiliares R

| Arquivo | Funções/contrato |
| --- | --- |
| anomaly.R | anomaly(y,x,level); x em POSIXlt; atenção a dias do ano bissextos |
| semanas.i.R | iden.weekly/n.semana; numeração semanal própria |
| Function_Data_nc_convert_20260320.R | data_nc_convert; eixo time com unidade reconhecida |
| Function_monsoon_atividade_20260322.r | monsoon_active/fase_in_monsoon; sequências de posições e contagem por fase |
| cov4gappy.r | Produto cruzado dividido por número de pares; requer centragem prévia |

Os arquivos val2col.R, lon.lat.filter.R, image.scale.R, eof.mca.R e color.palette.R continuam ausentes. MCA ainda os chama; recuperar sua procedência ou comprovar que as chamadas são dispensáveis antes de removê-las.

O source de cov4gappy foi ajustado ao nome minúsculo existente. Funções científicas não foram alteradas. Tratamento de NA, calendário, ausência de eventos, continuidade diária e normalização ainda exige revisão.
