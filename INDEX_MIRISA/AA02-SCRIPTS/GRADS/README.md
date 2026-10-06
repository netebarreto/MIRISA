# Mapas de composições em GrADS

| Arquivo | Uso |
| --- | --- |
| `mapas_comp.gs` | Abre composições de OLR/precipitação e organiza oito fases em painéis |
| `cbarn.gs` | Barra de cores com tamanho, orientação e posição configuráveis |

## Entradas e saídas

mapas_comp.gs espera dois NetCDF em caminhos Windows fixos: composições OLR e chuva com variáveis `miriolr` e `miripr`, respectivamente, e oito posições no eixo t. Escreve `COMPOSICAO_MIRISA_20230226.png` em outro caminho fixo.

As saídas atuais das rotinas R têm nomes diferentes. Os dados precisam ser fornecidos e os caminhos/nomes ajustados. Não executar antes de validar ordem das fases e unidades.

Exemplo de uso, após configurar entradas e saída:

```text
grads -l
run mapas_comp.gs
```

A barra de cores aceita `run cbarn.gs sf vert xmid ymid`; vert=0 horizontal e vert=1 vertical, conforme os comentários do arquivo.

## Ajustes recomendados

- Tornar caminhos relativos/configuráveis e harmonizar os nomes com os produtos R.
- Confirmar que t=1…8 representa fases; a dimensão científica deveria se chamar phase, com adaptação da leitura GrADS.
- Registrar unidades nas legendas.
- Preservar atribuição ao código auxiliar cbarn.gs, cujos comentários registram modificações de Mike Fiorino em 1994; verificar licença de redistribuição.

Não houve execução GrADS nesta revisão.
