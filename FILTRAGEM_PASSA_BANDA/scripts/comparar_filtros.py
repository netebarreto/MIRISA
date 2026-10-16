#!/usr/bin/env python3
"""Laboratório passa-banda. Modificado em 2026-10-16. SPDX-License-Identifier: GPL-3.0-only."""
import argparse
import csv
import json
from pathlib import Path
import platform
import numpy as np
import scipy
from scipy import signal
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]

def lanczos(numtaps, low, high, fs):
    """FIR simétrico: sinc passa-banda × janela sigma; ganho unitário no centro geométrico."""
    if numtaps < 3 or numtaps % 2 != 1:
        raise ValueError('numtaps deve ser ímpar e >= 3')
    m = (numtaps - 1) // 2
    k = np.arange(-m, m + 1)
    h = (2*high/fs*np.sinc(2*high/fs*k) - 2*low/fs*np.sinc(2*low/fs*k))
    h *= np.sinc(k / m)
    gain = np.sum(h * np.cos(2*np.pi*np.sqrt(low*high)/fs*k))
    if abs(gain) < 1e-10:
        raise ValueError('Janela insuficiente para normalizar o filtro')
    return h / gain

def projetar(c):
    dt, pmin, pmax = c['dt_dias'], c['periodo_min_dias'], c['periodo_max_dias']
    if not (np.isfinite([dt, pmin, pmax]).all() and 0 < dt and 2*dt < pmin < pmax):
        raise ValueError('Exige 0 < 2*dt < período mínimo < período máximo')
    fs = 1 / dt
    if not (0 < c['perda_passagem_db'] < c['atenuacao_rejeicao_db'] and c['margem_periodos'] >= 0):
        raise ValueError('Especificações em dB ou margem inválidas')
    nt = c['numtaps']
    if not isinstance(nt, int) or nt < 3 or nt % 2 == 0:
        raise ValueError('numtaps deve ser inteiro ímpar >= 3')
    low, high = 1/pmax, 1/pmin
    # Mesmas especificações EFETIVAS para todos os IIR; dB dobram em ida e volta.
    ws = [low * .7, high + .3*min(high, fs/2-high)]
    filters = {}
    for name, kind in [('Butterworth','butter'), ('Chebyshev I','cheby1'),
                       ('Chebyshev II','cheby2'), ('Eliptico','ellip')]:
        sos = signal.iirdesign([low,high], ws, c['perda_passagem_db']/2,
                              c['atenuacao_rejeicao_db']/2, ftype=kind, fs=fs, output='sos')
        filters[name] = ('iir', sos)
    filters['Lanczos'] = ('fir', lanczos(nt, low, high, fs))
    filters['FIR Blackman'] = ('fir', signal.firwin(nt, [low,high], pass_zero=False, window='blackman', fs=fs))
    return filters, fs, (low, high), ws

def aplicar(x, kind, coef):
    x = np.asarray(x, dtype=float)
    if x.ndim != 1 or not np.isfinite(x).all():
        raise ValueError('Fornece uma série 1D sem NaN/inf; não se interpola automaticamente')
    if kind == 'iir':
        return signal.sosfiltfilt(coef, x)
    if len(x) <= len(coef):
        raise ValueError('Série menor que a janela FIR')
    m = len(coef)//2
    y = signal.convolve(x, coef, mode='same')
    y[:m] = np.nan
    y[-m:] = np.nan
    return y

def executar(c, out):
    filters, fs, (low, high), ws = projetar(c)
    n, dt = c['n_amostras'], c['dt_dias']
    # Mesma amostra para todos: duas componentes internas, duas externas e ruído.
    t = np.arange(n)*dt
    periods = np.array([c['periodo_min_dias'], c['periodo_max_dias']])
    pa, pb = np.exp(np.log(periods[0]) + np.array([.35,.7])*np.log(periods[1]/periods[0]))
    alvo = np.sin(2*np.pi*t/pa) + .5*np.sin(2*np.pi*t/pb)
    rng = np.random.default_rng(c['seed'])
    x = alvo + .8*np.sin(2*np.pi*t/(c['periodo_min_dias']*.6)) + .8*np.sin(2*np.pi*t/(c['periodo_max_dias']*2)) + rng.normal(0,.4,n)
    margin = max(c['numtaps']//2, int(np.ceil(c['margem_periodos']*c['periodo_max_dias']/dt)))
    if n - 2*margin < 256:
        raise ValueError('Série curta: aumenta n_amostras ou reduz a margem/janela')
    core = slice(margin, n-margin)
    out.mkdir(parents=True, exist_ok=True)
    plt.rcParams.update({'svg.fonttype':'none', 'font.size':9, 'axes.spines.top':False, 'axes.spines.right':False})
    fig, axes = plt.subplots(3,2,figsize=(12,8), constrained_layout=True)
    response, axr = plt.subplots(figsize=(10,4), constrained_layout=True)
    spectra, axs = plt.subplots(figsize=(10,4), constrained_layout=True)
    f = np.linspace(0, fs/2, 32768)
    f_psd, psd = signal.welch(x[core], fs=fs, nperseg=min(1024,len(x[core])))
    axs.semilogy(f_psd, psd, color='gray', label='Entrada')
    rows, outputs = [], {}
    for ax, (name,(kind,coef)) in zip(axes.flat, filters.items()):
        y = aplicar(x,kind,coef)
        outputs[name] = y
        if kind == 'iir':
            _, h = signal.sosfreqz(coef, worN=f, fs=fs)
            gain = np.abs(h)**2
            order = 2*len(coef) # projetos passa-banda, sem seção de primeira ordem
        else:
            _, h = signal.freqz(coef, worN=f, fs=fs)
            gain = np.abs(h)
            order = len(coef)-1
        band = (f>=low)&(f<=high)
        stop = (f<=ws[0])|(f>=ws[1])
        db = 20*np.log10(np.maximum(gain,1e-12))
        rows.append({'filtro':name, 'ordem_uma_passagem':order,
                     'correlacao':float(np.corrcoef(alvo[core],y[core])[0,1]),
                     'rmse':float(np.sqrt(np.mean((y[core]-alvo[core])**2))),
                     'razao_desvio_padrao':float(np.std(y[core])/np.std(alvo[core])),
                     'perda_max_banda_db':float(-db[band].min()),
                     'atenuacao_min_rejeicao_db':float(-db[stop].max())})
        show = (t >= t[margin]) & (t <= t[margin]+5*c['periodo_max_dias'])
        ax.plot(t[show],x[show],color='.8',lw=.6,label='Entrada')
        ax.plot(t[show],alvo[show],color='black',lw=1,label='Alvo conhecido')
        ax.plot(t[show],y[show],lw=1,label='Filtrada')
        ax.set(title=name,xlabel='Tempo (dias)',ylabel='Amplitude')
        axr.plot(f,db,label=name)
        fp, sp = signal.welch(y[core],fs=fs,nperseg=min(1024,len(y[core])))
        axs.semilogy(fp,sp,label=name)
    axes.flat[0].legend(fontsize=7)
    for ax in (axr,axs):
        ax.axvspan(low,high,alpha=.1,color='green')
        ax.set_xlim(0,min(fs/2,2*high))
        ax.set_xlabel('Frequência (ciclos/dia)')
        ax.legend(fontsize=8,ncol=3)
        ax.grid(alpha=.2)
    axr.set(ylim=(-90,3),ylabel='Ganho efetivo (dB)',title='Resposta aplicada: IIR ida e volta; FIR centrado uma vez')
    axs.set(ylabel='Densidade espectral (amplitude² / ciclos por dia)', title='Welch — mesmo intervalo interior para todos os filtros')
    for figobj,name in [(fig,'series'),(response,'resposta'),(spectra,'espectros')]:
        figobj.savefig(out/f'{name}.svg',metadata={'Date':None})
        plt.close(figobj)
    edges, axe = plt.subplots(2,1,figsize=(10,6),constrained_layout=True)
    sos = filters['Butterworth'][1]
    causal = signal.sosfilt(sos, x)
    retrospective = outputs['Butterworth']
    for ax, region, title in [(axe[0], slice(0, margin*2), 'Início: valores calculados também podem conter transientes'),
                              (axe[1], slice(margin, min(n-margin, margin+int(4*c['periodo_max_dias']/dt))), 'Interior: passagem causal e ida e volta')]:
        ax.plot(t[region],alvo[region],color='black',label='Alvo')
        ax.plot(t[region],causal[region],label='Causal, uma passagem',alpha=.8)
        ax.plot(t[region],retrospective[region],label='Ida e volta',alpha=.8)
        ax.set(title=title,xlabel='Tempo (dias)',ylabel='Amplitude')
        ax.legend(fontsize=8)
    axe[0].axvspan(0,margin*dt,alpha=.1,color='red',label='Margem excluída')
    edges.savefig(out/'bordas_fase.svg',metadata={'Date':None})
    plt.close(edges)
    with (out/'metricas.csv').open('w',newline='',encoding='utf-8') as stream:
        writer = csv.DictWriter(stream,fieldnames=rows[0].keys())
        writer.writeheader(); writer.writerows(rows)
    np.savetxt(out/'series.csv',np.column_stack([t,x,alvo,*outputs.values()]),delimiter=',',
               header=','.join(['tempo_dias','entrada','alvo',*outputs]),comments='')
    meta = {'config':c,'margem_amostras':margin,'intervalo_interior_indices':[margin,n-margin],
            'periodos_alvo_dias':[pa,pb], 'wp_ciclos_dia':[low,high],'ws_ciclos_dia':ws,
            'python':platform.python_version(),'numpy':np.__version__,'scipy':scipy.__version__,
            'matplotlib':matplotlib.__version__}
    (out/'execucao.json').write_text(json.dumps(meta,indent=2),encoding='utf-8')
    print(json.dumps(rows,indent=2))
    return rows

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config',type=Path,default=ROOT/'exemplos/parametros.json')
    parser.add_argument('--saida',type=Path,default=ROOT/'resultados/local')
    args = parser.parse_args()
    executar(json.loads(args.config.read_text(encoding='utf-8')),args.saida)
