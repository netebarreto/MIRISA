# Reorganização de 16/10/2026

Todos os arquivos anteriores foram preservados integralmente sob `legado/original/`, com os mesmos conteúdos e nomes. Os caminhos antigos na raiz desta pasta foram substituídos pela sequência didática.

| Caminho anterior | Cópia histórica | Material didático atual |
| --- | --- | --- |
| `README.md` | `legado/original/README.md` | `README.md` e `docs/` |
| `Butterworth/` | `legado/original/Butterworth/` | `docs/filtros/butterworth.md` |
| `ChebyshevI/` | `legado/original/ChebyshevI/` | `docs/filtros/chebyshev_i.md` |
| `ChebyshevII/` | `legado/original/ChebyshevII/` | `docs/filtros/chebyshev_ii.md` |
| `EllipticC/` | `legado/original/EllipticC/` | `docs/filtros/eliptico.md` |
| `FIR_Blackman/` | `legado/original/FIR_Blackman/` | `docs/filtros/blackman.md` |
| `FLanczos/` | `legado/original/FLanczos/` | `docs/filtros/lanczos.md` |

## Correções

- Retirada a normalização Lanczos pela soma dos pesos; agora o ganho é referenciado no centro da banda.
- Explicitadas as unidades e a relação entre período, frequência e Nyquist.
- Separados FIR centrado e IIR aplicado em ida e volta; a resposta exibida corresponde à aplicação efetiva.
- Substituídos trechos isolados por um programa único, com semente, parâmetros e saídas registradas.
- Comparação IIR por tolerâncias comuns, sem confundir os limites críticos das diferentes famílias.
- Corrigidas afirmações gerais sobre estabilidade, fase e superioridade dos métodos.
- Imagens antigas não foram usadas como evidência numérica. Chebyshev II e Elíptico tinham imagens com o mesmo SHA de conteúdo; os gráficos novos são gerados pelo código.
- O README anterior apresentava resultados como estudo concluído sem uma rotina comparativa completa nesta pasta; agora a evidência está ligada a uma execução sintética identificada.

Os links absolutos dentro da cópia histórica apontam para os caminhos antigos e podem deixar de funcionar. Essa cópia é documental; usa os links da sequência nova para estudar/executar.
