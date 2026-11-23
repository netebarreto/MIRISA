#!/usr/bin/env python3
"""Figura 1 de Barreto et al. (2019), DOI: 10.1002/met.1780.

Plota padrões espaciais já calculados da MCA: precipitação sobre a América
 do Sul e perfis longitudinais tropicais de OLR, U850 e U200. Não calcula
anomalias, filtragem, MCA, médias tropicais ou normalização.

ATENÇÃO: nos arquivos fornecidos, 'Time' tem 4 registros e datas artificiais
em outubro/2026. Assume-se que os registros sejam MCA1...MCA4, na ordem.
Essa interpretação deve ser confirmada na rotina que gerou os NetCDF.
Os arquivos indicam 1981-2010 no nome, enquanto o artigo usa mar/1982-nov/2016.
SCF não está nos arquivos; só é desenhada quando explicitamente informada.

Instalação:
    python -m pip install numpy scipy matplotlib cartopy
Execução (os três NetCDF na pasta indicada):
    python figura1_mirisa.py --dados ./dados --saida ./figuras
O Cartopy baixa os limites Natural Earth 110m na primeira execução.
Para trabalhar offline, prepara previamente o cache do Cartopy.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import warnings

import numpy as np
from scipy.io import netcdf_file
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm, ListedColormap
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from cartopy.mpl.ticker import LatitudeFormatter, LongitudeFormatter


# python scripts\plots\mca_pattern_plot_20261116.py --dados outputs\netcdf\mca_pattern\1991-2020 --saida outputs\figures\

ARQUIVOS = {
    'prec': 'prec.mirisa.mca.cpc.19910101.20201231_20261111.nc',
    'vento': 'uwnd.mirisa.mca.ncep-r1.19910101.20201231_20261111.nc',
    'olr': 'olr.mirisa.mca.v01r02.19910101.20201231_20261111.nc',
}
period = "1981-2010"

def ler_campo(caminho, variavel, modo, sinal=1):
    """Lê NetCDF clássico; trata missing, escala e coordenadas sem decodificar Time."""
    with netcdf_file(caminho, 'r', mmap=False) as ds:
        if variavel not in ds.variables:
            raise ValueError(f'{caminho}: variável {variavel!r} ausente.')
        v = ds.variables[variavel]
        dims = tuple(v.dimensions)
        if dims != ('Time', 'lat', 'lon'):
            raise ValueError(f'{variavel}: esperado (Time, lat, lon); recebido {dims}.')
        if not 1 <= modo <= v.shape[0]:
            raise ValueError(f'{variavel}: modo {modo} fora de 1..{v.shape[0]}.')
        a = np.array(v[modo - 1], dtype=float)
        for attr in ('_FillValue', 'missing_value'):
            for missing in np.atleast_1d(getattr(v, attr, [])):
                a[a == missing] = np.nan
        a = a * float(getattr(v, 'scale_factor', 1)) + float(getattr(v, 'add_offset', 0))
        lon = np.array(ds.variables['lon'][:], dtype=float)
        lat = np.array(ds.variables['lat'][:], dtype=float)
    if not np.isfinite(a).any():
        raise ValueError(f'{variavel}: campo inteiro ausente no modo {modo}.')
    return lon, lat, a * sinal


def perfil(caminho, variavel, modo, sinal):
    lon, lat, a = ler_campo(caminho, variavel, modo, sinal)
    if len(lat) != 1:
        raise ValueError(f'{variavel}: esperado perfil já promediado entre 15S e 15N.')
    lon = lon % 360
    ordem = np.argsort(lon)
    return lon[ordem], a[0, ordem]


def gerar(args):
    caminhos = {k: getattr(args, k) or args.dados / nome for k, nome in ARQUIVOS.items()}
    for p in caminhos.values():
        if not p.is_file():
            raise FileNotFoundError(f'Arquivo ausente: {p}')
    warnings.warn('Time é interpretado como índice de modo MCA, não como data. '
                  'Confirma essa convenção na rotina de origem.', stacklevel=2)
    args.saida.mkdir(parents=True, exist_ok=True)
    plt.rcParams.update({'font.size': 11, 'axes.linewidth': 1.0, 'font.family': 'DejaVu Sans'})
    proj = ccrs.PlateCarree()
    fig = plt.figure(figsize=(12, 9))
    gs = fig.add_gridspec(2, 2, width_ratios=[1, 1.58], hspace=.3, wspace=.1,
                          left=.05, right=.95, top=.95, bottom=.15)
    
    # # 11 cores: 5 vermelhas, branco e 5 azuis
    # 11 cores: 5 vermelhas, branco e 5 azuis
    cores = plt.get_cmap('RdBu')(np.linspace(0, 1, 11))
    cores[5] = [1, 1, 1, 1]  # branco puro no intervalo central

    limites = np.array([
    -.030, -.025, -.020, -.015, -.010, -.005,
     .005,  .010,  .015,  .020,  .025,  .030
    ])
    cmap = ListedColormap(cores)
    cmap.set_bad('white')
    norm = BoundaryNorm(limites, cmap.N)
    linhas = [('u20', 'U200', 'blue', '--'), ('u85', 'U850', 'black', '-'),
              ('olr', 'OLR', 'red', '-')]
    ydados = []
    perfis = {}
    for modo, sinal in zip(args.modos, args.sinais):
        for var, *_ in linhas:
            caminho = caminhos['olr' if var == 'olr' else 'vento']
            perfis[modo, var] = perfil(caminho, var, modo, sinal)
            ydados.append(perfis[modo, var][1])
    ymax = max(.15, np.ceil(max(np.nanmax(np.abs(y)) for y in ydados) / .05) * .05)
    for i, (modo, sinal) in enumerate(zip(args.modos, args.sinais)):
        ax = fig.add_subplot(gs[i, 0], projection=proj)
        lon, lat, a = ler_campo(caminhos['prec'], 'prp', modo, sinal)
        lon = (lon + 180) % 360 - 180
        ix, iy = np.argsort(lon), np.argsort(lat)
        lon, lat, a = lon[ix], lat[iy], a[np.ix_(iy, ix)]
        if lon.min() > -80 or lon.max() < -35 or lat.min() > -40 or lat.max() < 10:
            warnings.warn('A grade não cobre integralmente a área continental da figura.')
        # Recorte visual do artigo: a grade original não é interpolada.
        mapa = ax.pcolormesh(lon, lat, np.ma.masked_invalid(a), cmap=cmap,
                              norm=norm, shading='auto', transform=proj, rasterized=True)
        ax.set_extent([-82, -32, -40, 10], crs=proj)
        ax.coastlines(resolution='110m', linewidth=.6)
        ax.add_feature(cfeature.BORDERS.with_scale('110m'), linewidth=.5)
        ax.set_xticks([-80, -60, -40], crs=proj)
        ax.set_yticks([-40, -30, -20, -10, 0, 10], crs=proj)
        ax.xaxis.set_major_formatter(LongitudeFormatter())
        ax.yaxis.set_major_formatter(LatitudeFormatter())
        ax.set_title(f'({"ac"[i]})  MCA{modo} — Precipitação', loc='left', fontsize=12, pad=10)
        if args.scf is not None:
            ax.text(.02, .98, f'SCF = {args.scf[i]:.2f}', transform=ax.transAxes,
                    va='top', bbox={'facecolor': 'white', 'edgecolor': 'none', 'alpha': .85})
        ax2 = fig.add_subplot(gs[i, 1])
        for var, nome, cor, estilo in linhas:
            x, y = perfis[modo, var]
            ax2.plot(x, y, label=nome, color=cor, linestyle=estilo, linewidth=2)
        ax2.axhline(0, color='black', linewidth=.6)
        ax2.set_xlim(0, 360)
        ax2.set_ylim(-ymax, ymax)
        ax2.set_xticks([60, 120, 180, 240, 300])
        ax2.set_xticklabels(['60°E', '120°E', '180°', '120°W', '60°W'])
        ax2.set_yticks([-.1, 0, .1])
        ax2.set_ylabel('Coeficiente espacial da MCA')
        ax2.set_title(f'({"bd"[i]})  MCA{modo} — OLR, U850 e U200 (15°S–15°N)',
                      loc='left', fontsize=12, pad=10)
        ax2.legend(loc='lower left', frameon=False, fontsize=10)
    cax = fig.add_axes([.08, .075, .30, .023])
    cb = fig.colorbar(mapa, cax=cax, orientation='horizontal', extend='both',
                      ticks=[-.03,-.02, -.01, .01,.02,.03], spacing='uniform')
    cb.set_label('Coeficiente espacial da MCA — precipitação', fontsize=10)
    rodape = ('Padrões fornecidos: 1981–2010 (nomes dos arquivos). '
              'Composição baseada em Barreto et al. (2019).')
    fig.text(.47, .075, rodape.replace(' Composição', '\nComposição'), fontsize=9,
              color='#444444', va='center')
    arquivos_saida = []
    for ext in args.formatos:
        destino = args.saida / f'mca_pattern_{period}.{ext}'
        fig.savefig(destino, dpi=args.dpi, facecolor='white')
        arquivos_saida.append(str(destino.resolve()))
        print(f'Gerado: {destino}')
    plt.close(fig)
    registro = {'referencia': 'Barreto et al. (2019), doi:10.1002/met.1780',
                'entradas': {k: str(p.resolve()) for k, p in caminhos.items()},
                'modos_base_1': args.modos, 'sinais_por_modo': args.sinais,
                'scf_informada': args.scf, 'limites_cores': limites.tolist(),
                'saidas': arquivos_saida,
                'observacoes': ['Registros Time interpretados como modos; confirmar na origem.',
                                'Sem filtragem, renormalização ou interpolação.',
                                'Faixa -0.005 a 0.005 branca; missing também branco.',
                                'Perfis mantidos nas respectivas grades longitudinais.',
                                'Período dos nomes difere do período do artigo.']}
    (args.saida / 'parametros_figura1.json').write_text(
        json.dumps(registro, ensure_ascii=False, indent=2), encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--dados', type=Path, default=Path('.'), help='Pasta dos três NetCDF.')
    for chave in ARQUIVOS:
        parser.add_argument(f'--{chave}', type=Path, help=f'Caminho explícito para {chave}.')
    parser.add_argument('--saida', type=Path, default=Path('figuras'))
    parser.add_argument('--modos', type=int, nargs=2, default=[1, 2], metavar=('M1', 'M2'))
    parser.add_argument('--sinais', type=int, choices=[-1, 1], nargs=2, default=[1, 1],
                        help='Multiplica TODOS os campos do modo pelo mesmo sinal.')
    parser.add_argument('--scf', type=float, nargs=2, default=None,
                        help='Frações SCF da SUA análise, entre 0 e 1. Não inferidas dos padrões.')
    parser.add_argument('--formatos', nargs='+', choices=['png', 'svg'], default=['png'])
    parser.add_argument('--dpi', type=int, default=300)
    args = parser.parse_args()
    if args.modos[0] == args.modos[1]:
        parser.error('Escolhe dois modos diferentes.')
    if args.scf is not None and (any(not 0 <= x <= 1 for x in args.scf) or sum(args.scf) > 1.000001):
        parser.error('SCF deve conter frações entre 0 e 1 com soma <= 1.')
    if args.dpi <= 0:
        parser.error('--dpi deve ser positivo.')
    gerar(args)


if __name__ == '__main__':
    main()
