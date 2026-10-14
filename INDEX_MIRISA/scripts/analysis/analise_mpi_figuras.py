#!/usr/bin/env python3
"""Caracterização do MPI em DJF. Requer xarray, numpy, pandas, matplotlib e netCDF4.
Uso: python gerar_figuras_mpi.py arquivo.nc --var precip --out resultados_mpi
MPI >= 1: Active spell; MPI <= -1: Break spell; demais: intermediário.
Inclui eventos de um dia. Conta segmentos DJF por temporada; estatísticas de
persistência usam apenas segmentos completos dentro de DJF. Eventos que se
estendem além de DJF ou tocam lacunas/bordas desconhecidas são sinalizados.
O MPI é adimensional, independentemente dos atributos herdados do NetCDF.
"""
import argparse, json
from pathlib import Path
import numpy as np
import pandas as pd
import xarray as xr
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator

COLORS = {
    'Break spell': '#b66a32',
    'Intermediário': '#909aa2',
    'Active spell': '#247d9b',
}
REGIMES = list(COLORS)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('arquivo'); p.add_argument('--var',default='precip'); p.add_argument('--out',default='resultados_mpi')
    a=p.parse_args(); out=Path(a.out); out.mkdir(parents=True,exist_ok=True)
    with xr.open_dataset(a.arquivo) as ds:
        v=ds[a.var].squeeze(drop=True).load()
        if v.dims != ('time',): raise ValueError('A variável deve ser uma série temporal; dimensões espaciais só podem ter tamanho 1.')
        s=pd.Series(v.values,index=pd.DatetimeIndex(v.time.values),name='MPI').sort_index()
    if s.index.has_duplicates: raise ValueError('Datas duplicadas.')
    if not (s.index==s.index.normalize()).all(): raise ValueError('Esperadas datas diárias à meia-noite.')
    s=s.reindex(pd.date_range(s.index.min(),s.index.max(),freq='D')).replace([np.inf,-np.inf],np.nan)
    def regime(x):
        if pd.isna(x): return 'Ausente'
        return 'Active spell' if x>=1 else 'Break spell' if x<=-1 else 'Intermediário'
    r=s.map(regime)
    daily=pd.DataFrame({'MPI':s,'regime':r})
    daily=daily[daily.index.month.isin([12,1,2])].copy()
    daily['ano_inicio']=daily.index.year-(daily.index.month!=12).astype(int)
    daily['temporada']=daily.ano_inicio.map(lambda y:f'{y}/{y+1}')
    daily.index.name='data'
    # Só temporadas com cobertura temporal integral de dezembro a fevereiro.
    years=[int(y) for y in daily.ano_inicio.unique() if pd.Timestamp(int(y),12,1)>=s.index.min() and pd.Timestamp(int(y)+1,3,1)-pd.Timedelta(days=1)<=s.index.max()]
    daily=daily[daily.ano_inicio.isin(years)]
    if not years: raise ValueError('Nenhuma temporada DJF integral no período do arquivo.')
    events=[]; seasons=[]
    for y,g in daily.groupby('ano_inicio'):
        valid=g.MPI.notna().sum(); row={'temporada':f'{y}/{y+1}','dias_esperados':len(g),'dias_validos':int(valid),'dias_ausentes':int(len(g)-valid)}
        groups=(g.regime!=g.regime.shift()).cumsum()
        for _,q in g.groupby(groups):
            reg=q.regime.iloc[0]
            if reg not in ['Active spell','Break spell']: continue
                # Considera somente sequências com pelo menos 3 dias consecutivos.
            if len(q) < 3:
                continue
            start,end=q.index[0],q.index[-1]
            before,after=start-pd.Timedelta(days=1),end+pd.Timedelta(days=1)
            left=r.get(before,'Ausente'); right=r.get(after,'Ausente')
            reasons=[]
            if left=='Ausente': reasons.append('lacuna_ou_borda_esquerda')
            elif left==reg: reasons.append('continua_antes_DJF')
            if right=='Ausente': reasons.append('lacuna_ou_borda_direita')
            elif right==reg: reasons.append('continua_apos_DJF')
            vals=q.MPI.to_numpy()
            events.append({'temporada':row['temporada'],'regime':reg,'inicio_DJF':start,'fim_DJF':end,'duracao_DJF_dias':len(q),'MPI_medio':vals.mean(),'pico_MPI':vals.max() if reg=='Active spell' else vals.min(),'magnitude_media':np.abs(vals).mean(),'magnitude_integrada':np.abs(vals).sum(),'completo_DJF':not reasons,'motivo':';'.join(reasons)})
        for reg in REGIMES:
            if reg == 'Intermediário':
                row['dias_' + reg] = int((g.regime == reg).sum())
            else:
                row['dias_' + reg] = sum(
                    e['duracao_DJF_dias']
                    for e in events
                    if e['temporada'] == row['temporada']
                    and e['regime'] == reg
                )

            row['percentual_' + reg] = (
                100 * row['dias_' + reg] / valid
                if valid else np.nan
            )

            if reg != 'Intermediário':
                row['eventos_' + reg] = sum(
                    e['temporada'] == row['temporada']
                    and e['regime'] == reg
                    for e in events
                )

        seasons.append(row)
    ev=pd.DataFrame(events); ev.insert(0,'evento_id',range(1,len(ev)+1)); ss=pd.DataFrame(seasons)
    daily.to_csv(out/'MPI_DJF_diario.csv'); ev.to_csv(out/'MPI_DJF_catalogo_eventos.csv',index=False); ss.to_csv(out/'MPI_DJF_por_temporada.csv',index=False)
    vals=daily.MPI.dropna(); n=len(vals)
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'axes.spines.top':False,'axes.spines.right':False,'axes.titleweight':'bold','savefig.dpi':300})
    period=f'DJF {years[0]}/{years[0]+1}–{years[-1]}/{years[-1]+1}'
    def save(fig,name):
        fig.savefig(out/(name+'.png'),bbox_inches='tight'); fig.savefig(out/(name+'.pdf'),bbox_inches='tight'); plt.close(fig)
    fig,ax=plt.subplots(1,2,figsize=(12,4.6),layout='constrained')
    fig.suptitle('MPI · Distribuição e frequência dos regimes\n'+period,fontsize=15)
    bins=np.arange(np.floor(vals.min()*4)/4,np.ceil(vals.max()*4)/4+.25,.25)
    counts,edges=np.histogram(vals,bins=bins); centers=(edges[:-1]+edges[1:])/2
    ax[0].bar(centers,100*counts/n,width=.24,color=[COLORS[regime(x)] for x in centers])
    for t in [-1,1]: ax[0].axvline(t,color='#333333',ls='--',lw=1)
    ax[0].set(title='a) Distribuição diária',xlabel='MPI (adimensional)',ylabel='Percentual de dias (%)')
    freq=[100*(daily.regime==reg).sum()/n for reg in REGIMES]
    bars=ax[1].bar(REGIMES,freq,color=list(COLORS.values()),width=.65)
    for b,reg,f in zip(bars,REGIMES,freq): ax[1].text(b.get_x()+b.get_width()/2,f+.9,f'{f:.1f}%\nn = {(daily.regime==reg).sum():,}'.replace(',','.'),ha='center',fontsize=10)
    ax[1].set(title='b) Dias por regime',ylabel='Percentual de dias válidos (%)',ylim=(0,max(freq)*1.23))
    for x in ax: x.grid(axis='y',alpha=.2); x.set_axisbelow(True)
    save(fig,'MPI_figura_1_distribuicao_regimes_DJF')
    fig,ax=plt.subplots(2,1,figsize=(14,7),sharex=True,layout='constrained'); fig.suptitle('MPI · Ocorrência por temporada\n'+period,fontsize=15)
    xx=np.arange(len(ss)); w=.36
    for i,reg in enumerate(['Active spell','Break spell']):
        ax[0].bar(xx+(i-.5)*w,ss['eventos_'+reg],w,label=reg,color=COLORS[reg]); ax[1].bar(xx+(i-.5)*w,ss['percentual_'+reg],w,color=COLORS[reg])
    ax[0].set(title='a) Sequências observadas dentro de DJF',ylabel='Número de eventos'); ax[0].yaxis.set_major_locator(MaxNLocator(integer=True)); ax[0].legend(frameon=False)
    ax[1].set(title='b) Frequência de dias',ylabel='Dias válidos (%)',xlabel='Temporada'); ax[1].set_xticks(xx,ss.temporada,rotation=65,ha='right',fontsize=8)
    for x in ax: x.grid(axis='y',alpha=.2); x.set_axisbelow(True)
    save(fig,'MPI_figura_2_ocorrencia_temporadas_DJF')
    complete=ev[ev.completo_DJF].copy(); summary={}
    fig,ax=plt.subplots(1,3,figsize=(15,4.9),layout='constrained'); fig.suptitle('MPI · Persistência e magnitude dos eventos completos em DJF\n'+period,fontsize=15)
    maxd=int(complete.duracao_DJF_dias.max()); classes=['3–5','6–9','≥10']; xx=np.arange(3)
    for i,reg in enumerate(['Active spell','Break spell']):
        q=complete[complete.regime==reg]; d=q.duracao_DJF_dias; color=COLORS[reg]
        if len(q)==0: continue
        dc=d.value_counts().reindex(range(1,maxd+1),fill_value=0).sort_index()
        ax[0].plot(dc.index,dc.values/len(q)*100,'o-',color=color,label=f'{reg} (n = {len(q)})',ms=4)
        cl=pd.cut(d,[2,5,9,np.inf],labels=classes).value_counts(sort=False)
        ax[1].bar(xx+(i-.5)*.36,cl.values/len(q)*100,.36,color=color)
        ax[2].scatter(d,q.magnitude_media,color=color,alpha=.5,s=24,edgecolors='none',label=reg)
        summary[reg]={'eventos_completos':len(q),'eventos_total':int((ev.regime==reg).sum()),'duracao_mediana':float(d.median()),'duracao_q25':float(d.quantile(.25)),'duracao_q75':float(d.quantile(.75)),'duracao_maxima':int(d.max()),'magnitude_media_mediana':float(q.magnitude_media.median())}
    ax[0].set(title='a) Distribuição das durações',xlabel='Duração (dias)',ylabel='Eventos do regime (%)'); ax[0].legend(frameon=False,fontsize=9); ax[0].xaxis.set_major_locator(MaxNLocator(integer=True))
    ax[1].set(title='b) Classes de duração',xlabel='Duração (dias)',ylabel='Eventos do regime (%)'); ax[1].set_xticks(xx,classes)
    ax[2].set(title='c) Duração × magnitude média',xlabel='Duração (dias)',ylabel='Média de |MPI| (adimensional)'); ax[2].xaxis.set_major_locator(MaxNLocator(integer=True))
    for x in ax: x.grid(alpha=.2); x.set_axisbelow(True)
    save(fig,'MPI_figura_3_persistencia_magnitude_DJF')
    summary.update({'temporadas':len(years),'dias_DJF':len(daily),'dias_validos_DJF':n,'dias_ausentes_DJF':int(daily.MPI.isna().sum()),'datas_ausentes_arquivo':[str(x.date()) for x in s[s.isna()].index],'percentuais_regimes':dict(zip(REGIMES,freq)),'eventos_excluidos_duracao':int((~ev.completo_DJF).sum())})
    (out/'resumo_MPI_DJF.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2))
    print(json.dumps(summary,ensure_ascii=False,indent=2))
if __name__=='__main__': main()
