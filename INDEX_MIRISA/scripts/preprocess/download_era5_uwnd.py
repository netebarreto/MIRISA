#!/usr/bin/env python3

import os
import xarray as xr
import gcsfs

def main():
    # Parâmetros solicitados pelo usuário
    ano_inicial = 2021
    ano_final = 2021
    niveis = [200, 850]

    # Mapeamento: Chave do Google Cloud -> Sua Sigla de saída
    mapeamento_vars = {
#        "geopotential": "hgt",
#        "specific_humidity": "shum",
        "u_component_of_wind": "uwnd",
#        "v_component_of_wind": "vwnd"
    }

    print("[+] Conectando ao repositório ARCO-ERA5 do Google Cloud...")
    # Conexão segura e anônima com o bucket público do Google
    fs = gcsfs.GCSFileSystem(token='anon')
    path_zarr = 'gcp-public-data-arco-era5/ar/full_37-1h-0p25deg-chunk-1.zarr-v3'
    mapper = fs.get_mapper(path_zarr)
    
    # Abre o dataset de forma "lazy" (não consome memória da máquina remota)
    ds_completo = xr.open_zarr(mapper, consolidated=True)

    # Executa a varredura e download por Ano, por Variável e por Nível
    for ano in range(ano_inicial, ano_final + 1):
        print(f"\n--- Verificando o ano de {ano} ---")
        
        for var_google, sigla in mapeamento_vars.items():
            # Cria a pasta de saída da sigla (ex: shum/, hgt/) se não existir
            os.makedirs(sigla, exist_ok=True)
            
            for lev in niveis:
                # Formato exato solicitado: ex: shum/era5_shum_200_20000101-20001231.nc
                arquivo_saida = f"{sigla}/era5_{sigla}_{lev}_{ano}0101-{ano}1231.nc"
                
                # Checagem inteligente de existência de arquivo
                if os.path.exists(arquivo_saida):
                    print(f"  [-] {arquivo_saida} já existe em disco. Pulando...")
                    continue
                
                print(f"  [+] {arquivo_saida} ausente. Baixando fatia do Google Cloud...")
                
                try:
                    # Isola apenas a variável, o ano e o nível de pressão específico
                    # Nota: O nome da dimensão vertical no Zarr do Google é "level"
                    ds_fatia = ds_completo[[var_google]].sel(
                        time=slice(f"{ano}-01-01", f"{ano}-12-31"),
                        level=lev
                    )
                    
                    # Calcula a média diária diretamente nos servidores do Google (24h -> 1 dia)
                    print(f"      -> Calculando média diária na nuvem...")
                    ds_diario = ds_fatia.resample(time="1D").mean()
                    
                    # Faz o download real salvando diretamente no formato NetCDF desejado
                    print(f"      -> Gravando arquivo NetCDF final...")
                    ds_diario.to_netcdf(arquivo_saida)
                    print(f"      [✓] Download concluído com sucesso!")
                    
                except Exception as e:
                    print(f"      [X] Erro ao extrair {var_google} no nível {lev} para o ano {ano}: {e}")
                    # Remove o arquivo NetCDF se ele foi gerado parcialmente corrompido devido ao erro
                    if os.path.exists(arquivo_saida):
                        os.remove(arquivo_saida)

    print("\n=========================================================")
    print(" Processo finalizado! Banco de dados ERA5 atualizado. ")
    print("=========================================================")

if __name__ == "__main__":
    main()
