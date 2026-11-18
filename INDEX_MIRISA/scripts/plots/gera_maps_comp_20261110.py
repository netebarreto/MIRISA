#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Composição MIRISA: tradução de mapas_comp.gs para Python.

Oito fases nas linhas; OLR e vento em 850 hPa à esquerda, chuva à direita.
O eixo Time dos arquivos fornecidos representa F01...F08, não datas.
Nenhuma fase é renumerada, rotacionada ou recalculada.

Exemplo, a partir da raiz do projeto:
    python scripts/plots/gera_maps_comp_20261110.py --dados outputs/netcdf/phases_compostos --saida outputs/figures/composicao_mirisa_1991-2020.png

Ou, com os caminhos dos dois arquivos explícitos:
    python mapas_comp.py --olr caminho/olr.nc --prec caminho/prec.nc \
        --u85 caminho/u85.nc --v85 caminho/v85.nc

Dependências: numpy, matplotlib, xarray, netCDF4, cartopy e certifi.
Na primeira execução, Cartopy baixa os contornos Natural Earth, se ainda
não estiverem no cache. Usa --cartopy-data-dir para escolher esse cache.
O download usa certificados do certifi para evitar falhas ao carregar o
repositório de certificados do Windows, mantendo a validação HTTPS.
Se necessário, --ca-bundle permite indicar outro arquivo PEM de CAs.
"""

from __future__ import annotations

import argparse
import os
import ssl
from pathlib import Path
from urllib.request import urlopen
import warnings

import numpy as np
import matplotlib

matplotlib.use("Agg")  # Salva a figura mesmo sem interface gráfica.
import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm, ListedColormap
from matplotlib.ticker import FuncFormatter
import xarray as xr
import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from cartopy.io import DownloadWarning
from cartopy.io.shapereader import NEShpDownloader


# ---------------------------------------------------------------------
# AJUSTES DA FIGURA: mesmos limites e cores do script GrADS.
# ---------------------------------------------------------------------
ARQUIVO_OLR = "olr.mirisa.phases.noaa.v2.1991-2020_20261111.nc"
ARQUIVO_PREC = "prec.mirisa.phases.cpc.1991-2020_20261111.nc"
ARQUIVO_U85 = "u85.mirisa.phases.ncep.r1.1991-2020_20261111.nc"
ARQUIVO_V85 = "v85.mirisa.phases.ncep.r1.1991-2020_20261111.nc"

NIVEIS_OLR = [-25, -20, -15, -10, -5, 5, 10, 15, 20, 25]
NIVEIS_PREC = [-4, -3,-2, -1, -0.5, 0.5, 1, 2,3, 4]
FASES = [7 , 8, 1, 2, 3, 4, 5, 6]
# Equivalentes aos índices GrADS 16...20, 0, 21...25.
CORES_OLR = [
    "#0000ff", "#3737ff", "#6e6eff", "#a5a5ff", "#dcdcff",
    "#ffffff",
    "#ffdcdc", "#ffa5a5", "#ff6e6e", "#ff3737", "#ff0000",
]
CORES_PREC = CORES_OLR[::-1]

LON_OLR = (20.0, 380.0)  # 20°E até 20°E na volta seguinte.
LAT_OLR = (-45.0, 45.0)
LON_PREC = (-83.0, -33.5)  # Equivalente a 277...325°E.
LAT_PREC = (-40.0, 12.0)


class _NaturalEarthHTTPS(NEShpDownloader):
    """Usa um contexto HTTPS explícito somente nos downloads Natural Earth."""

    def __init__(self, original, contexto):
        super().__init__(
            url_template=original.url_template,
            target_path_template=original.target_path_template,
            pre_downloaded_path_template=original.pre_downloaded_path_template,
        )
        self._contexto = contexto

    def _urlopen(self, url):
        warnings.warn(f"Downloading: {url}", DownloadWarning, stacklevel=2)
        return urlopen(url, context=self._contexto, timeout=60)


def configurar_https_cartopy(ca_bundle=None):
    """Evita load_default_certs() do Windows sem desativar certificados.

    Passar cafile explicitamente dispensa a leitura do repositório de CAs
    do Windows, onde ocorre o erro ASN1: NOT_ENOUGH_DATA deste ambiente.
    A verificação da cadeia de certificados e do nome do servidor continua
    habilitada. O cache e as URLs já configurados no Cartopy são mantidos.
    """
    if ca_bundle is None:
        try:
            import certifi
        except ImportError as exc:
            raise RuntimeError(
                "Falta certifi. Instala no mesmo ambiente com: "
                "python -m pip install --upgrade certifi"
            ) from exc
        # Respeita uma CA já configurada pelo ambiente (por exemplo, rede
        # institucional). Ainda passa cafile explicitamente, sem ler o
        # repositório de certificados do Windows.
        ca_bundle = Path(os.environ.get("SSL_CERT_FILE") or certifi.where())
    if not ca_bundle.is_file():
        raise FileNotFoundError(f"Arquivo PEM de certificados não encontrado: {ca_bundle}")
    contexto = ssl.create_default_context(cafile=str(ca_bundle))
    chave = ("shapefiles", "natural_earth")
    original = NEShpDownloader.from_config(chave)
    cartopy.config["downloaders"][chave] = _NaturalEarthHTTPS(original, contexto)


def ler_campo(caminho: Path, nomes: tuple[str, ...], variavel: str | None):
    """Lê, mascara _FillValue e organiza as dimensões como fase/lat/lon."""
    if not caminho.is_file():
        raise FileNotFoundError(f"Arquivo não encontrado: {caminho}")

    # Evita que Time=1...8 seja convertido em datas artificiais.
    with xr.open_dataset(caminho, decode_times=False, mask_and_scale=True) as ds:
        if variavel is None:
            variavel = next((nome for nome in nomes if nome in ds.data_vars), None)
        if variavel is None or variavel not in ds.data_vars:
            raise ValueError(
                f"Variável não encontrada em {caminho.name}. "
                f"Disponíveis: {list(ds.data_vars)}. "
                "Informa --var-olr ou --var-prec."
            )

        campo = ds[variavel]
        lat = next((n for n in ("lat", "latitude", "LAT") if n in campo.dims), None)
        lon = next((n for n in ("lon", "longitude", "LON") if n in campo.dims), None)
        if lat is None or lon is None:
            raise ValueError(f"Dimensões latitude/longitude não reconhecidas: {campo.dims}")

        # Permite, por exemplo, uma dimensão vertical extra de tamanho 1.
        extras = [d for d in campo.dims if d not in (lat, lon)]
        for dim in extras:
            if campo.sizes[dim] == 1:
                campo = campo.isel({dim: 0}, drop=True)
        fases = [d for d in campo.dims if d not in (lat, lon)]
        if len(fases) != 1 or campo.sizes[fases[0]] != 8:
            raise ValueError(
                f"Esperadas exatamente 8 fases e duas dimensões espaciais; "
                f"encontradas {dict(campo.sizes)} em {caminho.name}."
            )
        dim_fase = fases[0]
        campo = campo.transpose(dim_fase, lat, lon).sortby(lat).load()
        unidade = str(campo.attrs.get("units", "não informada"))
        valores_fase = np.asarray(campo[dim_fase].values)

        valores = np.ma.masked_invalid(np.asarray(campo.values, dtype=float))
        return (
            np.asarray(campo[lon].values, dtype=float),
            np.asarray(campo[lat].values, dtype=float),
            valores,
            valores_fase,
            unidade,
        )


def preparar_longitudes(lon, campo, centro=0.0, ciclico=False):
    """Centraliza e ordena longitudes, mantendo cada coluna com seus dados.

    Para o mapa global, centro=200 transforma a janela 20...380 em
    coordenadas -180...180 na projeção. A borda cíclica evita uma faixa
    vazia na junção das longitudes, sem interpolar os valores originais.
    """
    ajustadas = (lon - centro + 180.0) % 360.0 - 180.0
    ordem = np.argsort(ajustadas)
    ajustadas = ajustadas[ordem]
    campo = np.ma.take(campo, ordem, axis=-1)

    # Remove uma eventual coluna duplicada, como 0° e 360°.
    manter = np.r_[True, np.diff(ajustadas) > 1e-8]
    ajustadas, campo = ajustadas[manter], campo[..., manter]
    if ciclico:
        gaps = np.diff(ajustadas)
        if len(gaps) < 2 or not np.allclose(gaps, gaps[0]):
            raise ValueError("A grade global de OLR precisa ter espaçamento regular em longitude.")
        if not np.isclose(ajustadas[-1] - ajustadas[0] + gaps[0], 360.0):
            raise ValueError("O campo de OLR precisa cobrir os 360° de longitude.")
        ajustadas = np.r_[ajustadas[-1] - 360, ajustadas, ajustadas[0] + 360]
        campo = np.ma.concatenate([campo[..., -1:], campo, campo[..., :1]], axis=-1)
    return ajustadas, campo


def criar_paleta(cores, niveis, nome):
    """Dez limites, nove classes internas e duas classes de extensão."""
    cmap = ListedColormap(cores[1:-1], name=nome)
    cmap.set_under(cores[0])
    cmap.set_over(cores[-1])
    cmap.set_bad("white")
    return cmap, BoundaryNorm(niveis, cmap.N)


def configurar_mapa(ax, costas, fronteiras, ticks_lat):
    ax.set_facecolor("white")
    # GrADS preenche cada parea; aspect='auto' mantém o formato dos painéis.
    ax.set_aspect("auto")
    ax.set_xticks([])
    ax.set_yticks(ticks_lat, crs=ccrs.PlateCarree())
    ax.yaxis.set_major_formatter(FuncFormatter(
        lambda valor, _: "EQ" if np.isclose(valor, 0)
        else f"{abs(valor):g}{'N' if valor > 0 else 'S'}"
    ))
    ax.tick_params(axis="y", labelsize=7, length=2, width=0.5, pad=2)
    ax.add_feature(costas, edgecolor="black", facecolor="none", linewidth=0.45, zorder=5)
    ax.add_feature(fronteiras, edgecolor="black", facecolor="none", linewidth=0.35, zorder=5)
    ax.spines["geo"].set_linewidth(0.75)


def gerar(args):
    arquivo_olr = args.olr if args.olr is not None else args.dados / ARQUIVO_OLR
    arquivo_prec = args.prec if args.prec is not None else args.dados / ARQUIVO_PREC
    lon_o, lat_o, olr, fases_o, unidade_o = ler_campo(
        arquivo_olr, ("olr", "miriolr"), args.var_olr
    )
    lon_p, lat_p, prec, fases_p, _ = ler_campo(
        arquivo_prec, ("prp", "miripr", "prec", "precip"), args.var_prec
    )
    arquivo_u = args.u85 if args.u85 is not None else args.dados / ARQUIVO_U85
    arquivo_v = args.v85 if args.v85 is not None else args.dados / ARQUIVO_V85
    lon_u, lat_u, u85, fases_u, unidade_u = ler_campo(
        arquivo_u, ("u85", "u", "uwnd"), args.var_u85
    )
    lon_v, lat_v, v85, fases_v, unidade_v = ler_campo(
        arquivo_v, ("v85", "v", "vwnd"), args.var_v85
    )
    if not all(np.array_equal(fases_o, f) for f in (fases_p, fases_u, fases_v)):
        raise ValueError("As coordenadas de fase dos quatro NetCDF não coincidem.")
    if not (np.array_equal(lon_u, lon_v) and np.array_equal(lat_u, lat_v)):
        raise ValueError("As grades de u85 e v85 precisam coincidir para formar os vetores.")

    if "mm" in unidade_o.lower():
        warnings.warn(
            f"OLR: a unidade gravada no NetCDF é {unidade_o!r}, incompatível com OLR. "
            "A legenda usa W m^-2, unidade física esperada; os valores não são convertidos "
            "e o arquivo original não é alterado.",
            stacklevel=2,
        )
    if any("mm" in unidade.lower() for unidade in (unidade_u, unidade_v)):
        warnings.warn(
            "Vento: u85/v85 têm unidade de chuva nos metadados. A referência dos "
            "vetores usa m s^-1, unidade esperada das componentes; não há conversão "
            "numérica nem alteração dos NetCDF.",
            stacklevel=2,
        )

    if args.cartopy_data_dir is not None:
        args.cartopy_data_dir.mkdir(parents=True, exist_ok=True)
        cartopy.config["data_dir"] = str(args.cartopy_data_dir)
    configurar_https_cartopy(args.ca_bundle)

    proj_global = ccrs.PlateCarree(central_longitude=np.mean(LON_OLR))
    proj_regional = ccrs.PlateCarree()
    x_o, olr = preparar_longitudes(lon_o, olr, centro=np.mean(LON_OLR), ciclico=True)
    x_p, prec = preparar_longitudes(lon_p, prec)
    x_u, u85 = preparar_longitudes(lon_u, u85, centro=np.mean(LON_OLR))
    x_v, v85 = preparar_longitudes(lon_v, v85, centro=np.mean(LON_OLR))
    if not np.array_equal(x_u, x_v):
        raise ValueError("As longitudes reorganizadas de u85 e v85 não coincidem.")
    # Recorta antes de rarefazer os vetores. Não interpola U/V na grade de OLR.
    dentro = (lat_u >= LAT_OLR[0]) & (lat_u <= LAT_OLR[1])
    indices_lat = np.flatnonzero(dentro)[::args.passo_vento]
    indices_lon = np.arange(0, x_u.size, args.passo_vento)
    vento_u = u85[:, indices_lat][:, :, indices_lon]
    vento_v = v85[:, indices_lat][:, :, indices_lon]
    mascara = np.ma.getmaskarray(vento_u) | np.ma.getmaskarray(vento_v)
    vento_u = np.ma.array(vento_u, mask=mascara)
    vento_v = np.ma.array(vento_v, mask=mascara)

    cmap_o, norm_o = criar_paleta(CORES_OLR, NIVEIS_OLR, "olr_grads")
    cmap_p, norm_p = criar_paleta(CORES_PREC, NIVEIS_PREC, "prec_grads")
    costas = cfeature.NaturalEarthFeature("physical", "coastline", args.resolucao)
    fronteiras = cfeature.NaturalEarthFeature("cultural", "admin_0_boundary_lines_land", args.resolucao)

    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9})
    fig = plt.figure(figsize=(8.5, 11.5), facecolor="white")

    # Posições em frações da figura. Ajusta aqui o tamanho dos dois grupos.
    esquerda_olr, largura_olr = 0.085, 0.660
    esquerda_prec, largura_prec = 0.810, 0.130
    topo, base, intervalo = 0.963, 0.105, 0.009
    altura = (topo - base - 7 * intervalo) / 8

    try:
        for i in range(8):
            y = topo - (i + 1) * altura - i * intervalo
            ax_o = fig.add_axes([esquerda_olr, y, largura_olr, altura], projection=proj_global)
            ax_p = fig.add_axes([esquerda_prec, y, largura_prec, altura], projection=proj_regional)
            ax_o.set_xlim(-180, 180)
            ax_o.set_ylim(*LAT_OLR)
            ax_p.set_extent([*LON_PREC, *LAT_PREC], crs=proj_regional)

            plot_o = ax_o.contourf(
                x_o, lat_o, olr[i], levels=NIVEIS_OLR, cmap=cmap_o, norm=norm_o,
                extend="both", transform=proj_global, corner_mask=False,
            )
            plot_p = ax_p.contourf(
                x_p, lat_p, prec[i], levels=NIVEIS_PREC, cmap=cmap_p, norm=norm_p,
                extend="both", transform=proj_regional, corner_mask=False,
            )
            configurar_mapa(ax_o, costas, fronteiras, [-20, 0, 20])
            configurar_mapa(ax_p, costas, fronteiras, [-20, 0])
            # U positivo = leste; V positivo = norte. A centralização em 200°
            # desloca apenas longitudes, sem inverter os sinais dos vetores.
            # vetores = ax_o.quiver(
            #     x_u[indices_lon], lat_u[indices_lat], vento_u[i], vento_v[i],
            #     transform=proj_global, color="#202020", zorder=6,
            #     angles="uv", scale_units="inches", scale=args.escala_vento,
            #     width=0.0011, headwidth=3.2, headlength=4.2,
            #     headaxislength=3.8, pivot="middle", minlength=0,
            # )
            linhas = ax_o.streamplot(
                x_u, lat_u,
                u85[i], v85[i],
                transform=proj_global,
                density=(1, 1),
                color="#8A8585",
                linewidth=0.75,
                arrowsize=0.5,
                zorder=4,
            )
            ax_o.text(
                0.985, 0.965, f"Phase {i + 1}", transform=ax_o.transAxes,
                ha="right", va="top", fontsize=8, fontweight="bold", zorder=20,
                bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.9, "pad": 1.5},
            )

        fig.text(esquerda_olr + largura_olr / 2, 0.981, "OLR + vento em 850 hPa", ha="center", va="center", fontsize=11)
        fig.text(esquerda_prec + largura_prec / 2, 0.981, "Precipitação", ha="center", va="center", fontsize=10)

        # Barras independentes: cores de sinal oposto nas duas variáveis.
        # ax_o.quiverkey(
        #     vetores, X=esquerda_olr + largura_olr - 0.11, Y=0.090,
        #     U=args.referencia_vento, label=rf"{args.referencia_vento:g} m s$^{{-1}}$",
        #     coordinates="figure", labelpos="E", fontproperties={"size": 7},
        # )
        cax_o = fig.add_axes([esquerda_olr, 0.067, largura_olr, 0.010])
        cax_p = fig.add_axes([esquerda_prec, 0.067, largura_prec, 0.010])
        for plot, cax, niveis, unidade in [
            (plot_o, cax_o, NIVEIS_OLR, r"OLR (W m$^{-2}$)"),
            (plot_p, cax_p, NIVEIS_PREC, r"Precipitação (mm dia$^{-1}$)"),
        ]:
            barra = fig.colorbar(
                plot, cax=cax, orientation="horizontal", ticks=niveis,
                spacing="uniform", extendfrac=0.055,
            )
            if cax is cax_p:
                # Mantém os dez limites legíveis na largura da coluna de chuva.
                barra.ax.tick_params(labelsize=6, length=2, pad=2, labelrotation=90)
                barra.ax.set_xticklabels([f"{valor:g}" for valor in niveis])
                barra.set_label(r"mm dia$^{-1}$", fontsize=8, labelpad=4)
            else:
                barra.ax.tick_params(labelsize=7, length=2, pad=1.5)
                barra.set_label(unidade, fontsize=8, labelpad=4)
            barra.outline.set_linewidth(0.6)

        args.saida.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(args.saida, dpi=args.dpi, facecolor="white")
    finally:
        plt.close(fig)
    print(f"Figura salva: {args.saida.resolve()}")
    print("Phase 1...Phase 8 correspondem às posições 1...8 dos arquivos, sem renumeração.")


def argumentos():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dados", type=Path, default=Path("outputs/netcdf"),
                        help="Pasta dos NetCDF. Padrão: outputs/netcdf.")
    parser.add_argument("--olr", type=Path, help="Caminho explícito do NetCDF de OLR.")
    parser.add_argument("--prec", type=Path, help="Caminho explícito do NetCDF de precipitação.")
    parser.add_argument("--u85", type=Path, help="Caminho explícito da componente zonal em 850 hPa.")
    parser.add_argument("--v85", type=Path, help="Caminho explícito da componente meridional em 850 hPa.")
    parser.add_argument("--var-olr", help="Nome da variável OLR; detecta olr/miriolr por padrão.")
    parser.add_argument("--var-prec", help="Nome da variável de chuva; detecta prp/miripr/prec/precip.")
    parser.add_argument("--var-u85", help="Nome da componente zonal; detecta u85/u/uwnd.")
    parser.add_argument("--var-v85", help="Nome da componente meridional; detecta v85/v/vwnd.")
    parser.add_argument("--passo-vento", type=int, default=4,
                        help="Plota uma seta a cada N pontos da grade em lat/lon; padrão: 4.")
    parser.add_argument("--escala-vento", type=float, default=25,
                        help="Escala em (m/s) por polegada; valores maiores encurtam as setas. Padrão: 25.")
    parser.add_argument("--referencia-vento", type=float, default=2,
                        help="Velocidade indicada na seta de referência (m/s); padrão: 2.")
    parser.add_argument("--saida", type=Path,
                        default=Path("outputs/figures/COMPOSICAO_MIRISA_python.png"),
                        help="Caminho e nome da figura de saída.")
    parser.add_argument("--dpi", type=int, default=300, help="Resolução da figura; padrão: 300.")
    parser.add_argument("--resolucao", choices=("110m", "50m", "10m"), default="50m",
                        help="Detalhe dos contornos Natural Earth; padrão: 50m.")
    parser.add_argument("--cartopy-data-dir", type=Path, help="Pasta do cache de mapas do Cartopy.")
    parser.add_argument("--ca-bundle", type=Path,
                        help="Arquivo PEM de CAs para HTTPS; padrão: SSL_CERT_FILE ou certifi.")
    args = parser.parse_args()
    if args.dpi <= 0:
        parser.error("--dpi precisa ser positivo.")
    if args.passo_vento <= 0:
        parser.error("--passo-vento precisa ser positivo.")
    if not np.isfinite(args.escala_vento) or args.escala_vento <= 0:
        parser.error("--escala-vento precisa ser finita e positiva.")
    if not np.isfinite(args.referencia_vento) or args.referencia_vento <= 0:
        parser.error("--referencia-vento precisa ser finita e positiva.")
    return parser, args


if __name__ == "__main__":
    parser, args = argumentos()
    try:
        gerar(args)
    except (ValueError, FileNotFoundError, RuntimeError) as exc:
        parser.error(str(exc))
