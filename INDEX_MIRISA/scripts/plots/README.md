# Diagramas e mapas

| Arquivo | Uso |
| --- | --- |
| DIAGRAM_PSPACE_MIRISA_20230501.py | Trajetória de componentes nos últimos 40 dias |
| MCA_PLOT.py | Mapas de padrões de precipitação MCA |
| mapas_comp.gs | Oito fases de composições OLR/chuva |

Python lê outputs/tables ou outputs/netcdf; mapas também usam data/static/shapes. Escreve outputs/figures. A configuração Python detecta a raiz pela localização do script ou MIRISA_ROOT. Dependências: NumPy, pandas, Matplotlib; mapas também netCDF4/Basemap/GeoPandas/contextily.

Os diagramas antigos/teste_DP estão em experiments/legacy/PYTHON. Consolidar somente após validar fases, limites de cores e janelas curtas. Títulos RR1/SDII do mapa MCA e o nome da figura continuam pendentes; esta reorganização não muda a interpretação científica.

Inicia GrADS em INDEX_MIRISA e usa run scripts/plots/mapas_comp.gs. O caminho da barra de cores agora aponta para scripts/functions/GRADS/cbarn.gs. Os NetCDF esperados estão em outputs/netcdf; nomes/datas preexistentes ainda precisam ser compatibilizados com a produção R.
