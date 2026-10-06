# Infraestrutura de caminhos; não define parâmetros científicos.
mirisa_root <- normalizePath(Sys.getenv("MIRISA_ROOT", unset = getwd()), mustWork = TRUE)
if (!file.exists(file.path(mirisa_root, "config", "paths.R"))) {
  stop("Executa a partir de INDEX_MIRISA ou define MIRISA_ROOT com seu caminho absoluto.")
}
setwd(mirisa_root)
for (d in c("outputs/models", "outputs/tables", "outputs/netcdf", "outputs/figures")) {
  dir.create(file.path(mirisa_root, d), recursive = TRUE, showWarnings = FALSE)
}
