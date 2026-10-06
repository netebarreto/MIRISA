# Pré-processamento Shell / CDO

Os arquivos são listas de comandos CDO com caminhos e datas fixos. Não há configuração central, criação automática de diretórios ou tratamento consistente de falhas.

| Arquivo | Conteúdo |
| --- | --- |
| `AA01-PROC_anom.sh` | Anomalias de OLR/U200/U850, concatenação temporal e padronização |
| `AA01-PROC_R_APAD.sh` | Desvio de referência, padronização, média equatorial e blocos históricos/recentes |
| `processamento_chuva_20260312.sh` | Recortes CHIRPS, montagem parcial de 2026 e anomalia padronizada regional |

## Contratos de dados

- `ydaysub`: campo diário e climatologia diária com calendário/grade compatíveis.
- `sellevel,200` / `sellevel,850`: conferir unidade do nível; os números pressupõem a convenção dos arquivos.
- `div`: anomalias filtradas e desvio de referência na mesma grade, com proteção para desvio zero.
- `mermean` após recorte 15°S–15°N: média meridional dos campos atmosféricos.
- CHIRPS: área sul-americana de 75°W–34°W e 40°S–10°N; região central de 55°W–45°W e 20°S–10°S para a série chamada MPI.

Entradas climatológicas, NetCDF brutos e filtrados não estão versionadas aqui. As saídas têm caminhos `INPUT_NC` / `AA00-NC_INPUT` / `AA01-NC_INPUT` ou nomes locais como `teste2.nc`.

## Correção prioritária: ordem dos operadores

CDO processa cadeias da direita para a esquerda. O padrão atual:

```bash
cdo -seldate,1991-03-01,2020-02-28 -timstd entrada.nc desvio.nc
```

calcula primeiro o desvio de toda a entrada e só depois seleciona a data do resultado agregado. Para limitar os dados usados no cálculo:

```bash
cdo -timstd -seldate,1991-03-01,2020-02-28 entrada.nc desvio.nc
```

Exemplo ilustrativo; os scripts originais não foram alterados. Aplicar essa correção e verificar o produto antes de refazer a padronização.

## Outros ajustes

1. Separar ajuste histórico e aplicação recente; usar a mesma referência fixa.
2. Harmonizar caminhos e datas (há blocos até 2025 e 2026 em arquivos compartilhados).
3. Validar ordenação, duplicatas e lacunas após mergetime; globs não garantem o período anunciado no nome.
4. Revisar sobreposição entre chuva preliminar e consolidada.
5. Criar diretórios antes de escrever e adicionar tratamento de erro, com logs por etapa.
6. Documentar a série CHIRPS como adaptação do MPI: referência 1981–2022 e ciclo diário sem a suavização descrita por Grimm et al. (2021).
7. Explicitar a ligação entre o resultado `teste2.nc` e a entrada `mpi.1981.2022.nc` usada em R.

Validação realizada: os três arquivos passaram em bash -n. Não houve execução CDO nem validação de NetCDF.

Referência técnica: [CDO — ordem dos operadores](https://code.mpimet.mpg.de/boards/1/topics/4550).
