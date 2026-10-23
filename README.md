# MIRISA · Índice Multivariado Intrassazonal de Precipitação da América do Sul

Rotinas científicas para preparar dados, ajustar a **análise de máxima covariância (MCA)**, calcular e projetar o índice MIRISA e analisar suas fases e amplitudes na América do Sul.

O repositório reúne processamento de precipitação, radiação de onda longa emergente (OLR) e circulação atmosférica, além de composições, diagramas de fase e análises de períodos ativos e inativos da monção sul-americana.

**Branch principal:** `main`  
**Estado:** estrutura organizada; implementação científica e execução completa ainda em validação.

[Documentação do índice](INDEX_MIRISA/README.md) · [Organização dos dados](INDEX_MIRISA/data/README.md) · [Migração de arquivos](INDEX_MIRISA/MIGRACAO.md) · [Avaliação técnica](INDEX_MIRISA/AVALIACAO_TECNICA.md)

## O que encontras aqui

| Diretório | Conteúdo |
| --- | --- |
| [INDEX_MIRISA](INDEX_MIRISA/README.md) | Cálculo, projeção e análise do MIRISA |
| [INDEX_MIRISA/config](INDEX_MIRISA/config/README.md) | Caminhos de execução e períodos climatológicos |
| [INDEX_MIRISA/scripts/preprocess](INDEX_MIRISA/scripts/preprocess/README.md) | Climatologias, anomalias, filtros e padronização |
| [INDEX_MIRISA/scripts/index](INDEX_MIRISA/scripts/index/README.md) | Ajuste MCA e projeção nos padrões de referência |
| [INDEX_MIRISA/scripts/analysis](INDEX_MIRISA/scripts/analysis/README.md) | Composições, diagnósticos e análise da monção |
| [INDEX_MIRISA/scripts/plots](INDEX_MIRISA/scripts/plots/README.md) | Mapas e diagramas de fase |
| [INDEX_MIRISA/scripts/functions](INDEX_MIRISA/scripts/functions/README.md) | Funções compartilhadas em R, Python e GrADS |
| [INDEX_MIRISA/experiments](INDEX_MIRISA/experiments/README.md) | Versões históricas e protótipos |
| [INDEX_MIRISA/data](INDEX_MIRISA/data/README.md) | Estrutura para dados locais por variável e tratamento |
| [INDEX_MIRISA/outputs](INDEX_MIRISA/outputs/README.md) | Destinos de modelos, tabelas, NetCDF e figuras |
| [FILTRAGEM_PASSA_BANDA](FILTRAGEM_PASSA_BANDA/README.md) | Documentação e exemplos de filtros digitais |

## Começar

Clona a branch principal em uma pasta nova:

```bash
git clone --branch main --single-branch https://github.com/netebarreto/MIRISA.git
cd MIRISA/INDEX_MIRISA
```

As rotinas devem ser executadas a partir de `INDEX_MIRISA`. Para indicar outra localização, define `MIRISA_ROOT` com o caminho absoluto dessa pasta.

Antes de executar, consulta o README da etapa, instala as dependências e fornece os arquivos de entrada. **O clone não inclui os NetCDF volumosos, os modelos ajustados nem as séries do índice disponíveis apenas na máquina local.** O [mapa de migração](INDEX_MIRISA/MIGRACAO.md) indica os destinos dos arquivos anteriores.

## Download das variáveis

Links de referência para localizar os dados usados nas rotinas:

| Variável | Fonte | Endereço |
| --- | --- | --- |
| Vento zonal — U-wind (`uwnd`) | NCEP/NCAR Reanalysis — dados diários em níveis de pressão | [Diretório de download](https://downloads.psl.noaa.gov/Datasets/ncep.reanalysis/Dailies/pressure/) |
| Vento meridional — V-wind (`vwnd`) | NCEP/NCAR Reanalysis — dados diários em níveis de pressão | [Diretório de download](https://downloads.psl.noaa.gov/Datasets/ncep.reanalysis/Dailies/pressure/) |
| Precipitação — Rain CPC (`prec`), opção 1 | Página da base CPC Global Precipitation | [Descrição e acesso aos dados](https://psl.noaa.gov/data/gridded/data.cpc.globalprecip.html) |
| Precipitação — Rain CPC (`prec`), opção 2 | Diretório FTP CPC — GAUGE_GLB/RT | [Diretório de download via FTP](ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/RT/) |
| Radiação de onda longa emergente — OLR (`olr`) | NOAA/NCEI — dados diários | [Diretório de download](https://www.ncei.noaa.gov/data/outgoing-longwave-radiation-daily/access/) |

Após o download, organiza os arquivos conforme [data/README.md](INDEX_MIRISA/data/README.md).

## Organização dos dados

A hierarquia identifica variável, tratamento, fonte, versão/variante, nível, referência e método, quando aplicáveis:

```text
data/prec/anomalias/chirps/v3_final_rnl/1991_2020/
data/uwnd/climatologia/ncep/200hpa/1981_2010/
data/olr/filtrados/v01r02/1981_2020/butterworth_signal/
data/static/masks/
data/static/shapes/
```

As variáveis são `prec`, `uwnd`, `vwnd` e `olr`. Os tratamentos incluem `brutos`, `recortados`, `climatologia`, `anomalias`, `filtrados`, `desvio_padrao` e `padronizados`. Produtos antigos com referência mista ou pendente de confirmação ficam identificados como `historico`.

Pastas vazias são mantidas no Git por arquivos `.gitkeep`; sua existência não indica que os dados estejam disponíveis.

## Referências climatológicas

A configuração [climatology_periods.json](INDEX_MIRISA/config/climatology_periods.json) oferece:

| Identificador | Período inclusivo |
| --- | --- |
| `1981_2010` | 01/01/1981 a 31/12/2010 |
| `1991_2020` | 01/01/1991 a 31/12/2020 |
| `1981_2020` | 01/01/1981 a 31/12/2020 |

A rotina `scripts/preprocess/gerar_climatologias.sh` prepara médias diárias e anomalias para as referências selecionadas. O modo `standardize` recebe anomalias previamente filtradas e calcula o desvio de referência e a padronização. Consulta os [comandos e requisitos](INDEX_MIRISA/scripts/preprocess/README.md).

**Período climatológico, cobertura da série e período de ajuste MCA são escolhas distintas.** Preparar essas referências não reestima automaticamente os modelos MCA nem altera as datas dos scripts históricos.

## Fluxo de trabalho e dependências

Preparação dos dados → anomalias → filtragem intrassazonal → padronização → ajuste MCA → projeção → fases, amplitudes e diagnósticos.

- **Bash e CDO:** processamento NetCDF.
- **R:** ajuste MCA, filtragem e análises; pacotes como `ncdf4`, `fields`, `signal` e `seewave`, conforme a rotina.
- **Python:** climatologias, gráficos e notebooks; dependências específicas constam nos READMEs das etapas.
- **GrADS:** rotinas de mapas que utilizam essa ferramenta.

O projeto ainda não possui um ambiente único com todas as versões fixadas.

## Estado da implementação

A organização dos arquivos e as verificações de sintaxe/caminhos não equivalem à validação numérica do índice. Permanecem funções auxiliares ausentes, diferenças entre nomes de modelos salvos e carregados e questões de normalização, sinais e definição das componentes.

Filtros bilaterais usam informação posterior ao dia estimado; sua aplicação retrospectiva exige cuidados adicionais quando o objetivo é previsão. As pendências estão documentadas na [avaliação técnica](INDEX_MIRISA/AVALIACAO_TECNICA.md).

## Referência científica

Barreto et al. (2019). **Multivariate intraseasonal rainfall index applied to South America**. *Meteorological Applications*. [https://doi.org/10.1002/met.1780](https://doi.org/10.1002/met.1780).

Ao utilizar o método, cita o artigo e identifica a versão do código, as bases, os filtros e os períodos empregados. A correspondência entre cada rotina e a formulação publicada deve ser verificada.

## Licença

O código original deste projeto é disponibilizado sob a **GNU General Public License, versão 3 (GPLv3)** — identificador SPDX: `GPL-3.0-only`. Consulta o texto integral em [LICENSE](LICENSE).

A licença permite uso, modificação e redistribuição, inclusive comercial, sob suas condições. A distribuição de versões modificadas deve cumprir as obrigações de disponibilização do código-fonte e manutenção da licença. O software é fornecido sem garantia, nos termos da GPLv3.

Códigos de terceiros, bases de dados e publicações mantêm suas próprias licenças e avisos de autoria. O financiamento não substitui a identificação dos autores e titulares dos direitos.

## Agradecimentos

Parte do desenvolvimento deste projeto contou com apoio do **Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq)**, por meio do **processo nº 153540/2016-8**.
