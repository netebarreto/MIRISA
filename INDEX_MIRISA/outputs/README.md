# Produtos locais

| Pasta | Conteúdo |
| --- | --- |
| models | Modelos/atributos RData |
| tables | Tabelas texto/CSV do índice e diagnósticos |
| netcdf | Padrões MCA, composições e séries regionais |
| figures | Figuras produzidas em novas execuções |
| examples | Três PNG anteriormente versionados, movidos sem alteração |

Novos resultados são ignorados no Git. Os três exemplos existentes permanecem versionados para rastreabilidade; não representam validação da versão reorganizada. RData deve ir em models, mesmo quando ficava junto dos arquivos texto na estrutura anterior.

Os auxiliares de configuração criam os quatro diretórios principais de produto. Rotinas que só geram objetos em memória não receberam exportações novas nesta mudança.
