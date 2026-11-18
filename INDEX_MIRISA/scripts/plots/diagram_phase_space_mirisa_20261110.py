import os
import sys
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# ==============================================================================
# CONFIGURAÇÃO DE LAGS DESEJADOS
# ==============================================================================
# Escolha os lags que você deseja plotar no gráfico.
lags_desejados = list(range(-30, 0)) #[-30, -20, -10, -5, 0]

# ==============================================================================
# CARREGAMENTO E FILTRAGEM DOS DADOS
# ==============================================================================
input_csv = pd.read_csv("outputs/tables/composicao_mirisa_phases_1991-2020_lags.txt", sep=";")

# Filtra a tabela mantendo apenas os lags definidos pelo usuário
input_csv = input_csv[input_csv['Lag'].isin(lags_desejados)]

# ==============================================================================
# CONFIGURAÇÃO DA FIGURA E EIXOS
# ==============================================================================
lim = 5
fs = 24

limF = [0.15, 0.15, 0.65, 0.65]
fig = plt.figure(figsize=(16, 16))
axs = fig.add_axes([limF[0], limF[1], limF[2], limF[3]])

# Configuração dos limites e eixos do diagrama
axs.tick_params(labelsize=fs, top=True, bottom=True, left=True, right=True,
                labeltop=True, labelbottom=True, labelleft=True, labelright=True)
axs.set_xlim(-lim, lim)
axs.set_ylim(lim,-lim)  # Eixo Y invertido conforme a convenção MJO/MIRISA

# Linhas diagonais, eixos centrais e círculo de amplitude < 1
axs.plot([-lim, lim], [-lim, lim], linewidth=1, linestyle='-.', color='k', zorder=1)
axs.plot([-lim, lim], [lim, -lim], linewidth=1, linestyle='-.', color='k', zorder=1)
axs.plot([-lim, lim], [0, 0], linewidth=1, linestyle='--', color='k', zorder=1)
axs.plot([0, 0], [-lim, lim], linewidth=1, linestyle='--', color='k', zorder=1)

circle = mpatches.Circle((0, 0), radius=1.2, fc='w', ec='k', zorder=2)
axs.add_patch(circle)

# Textos explicativos dos quadrantes (MJO e Chuva)
plt.figtext(0.5, limF[3] + 0.20, "MJO: Western Pacific", ha="center", va="center", color="black", fontsize=fs)
plt.figtext(0.5, limF[3] + 0.23, "Rain: Western Amazon", ha="center", va="center", color="blue", fontsize=fs+4)

plt.figtext(0.5, limF[1] - 0.075, "Rain: Northeast Brazil", ha="center", va="center", color="blue", fontsize=fs+4)
plt.figtext(0.5, limF[1] - 0.05, "MJO: Indian Ocean", ha="center", va="center", color="black", fontsize=fs)

plt.figtext(limF[2] + 0.20, 0.5, "MJO: Maritime Continent", ha="center", va="center", color="black", fontsize=fs, rotation=-90)
plt.figtext(limF[2] + 0.23, 0.5, "Rain: Western Brazil - South Brazil", ha="center", va="center", color="blue", fontsize=fs+4, rotation=-90)

plt.figtext(limF[0] - 0.05, 0.5, "MJO: Western Hemisphere, and Africa", ha="center", va="center", color="black", fontsize=fs, rotation=90)
plt.figtext(limF[0] - 0.075, 0.5, "Rain: Eastern Center South America", ha="center", va="center", color="blue", fontsize=fs+4, rotation=90)

# Rótulos das Fases
plt.text(-0.95*lim, lim/2, "Phase 1", ha="center", va="center", rotation=90, fontsize=0.85*fs)
plt.text(-lim/2, 0.95*lim, "Phase 2", ha="center", va="center", fontsize=0.85*fs)
plt.text(lim/2, 0.95*lim, "Phase 3", ha="center", va="center", fontsize=0.85*fs)
plt.text(0.95*lim, lim/2, "Phase 4", ha="center", va="center", rotation=270, fontsize=0.85*fs)
plt.text(0.95*lim, -lim/2, "Phase 5", ha="center", va="center", rotation=270, fontsize=0.85*fs)
plt.text(lim/2, -0.95*lim, "Phase 6", ha="center", va="center", fontsize=0.85*fs)
plt.text(-lim/2, -0.95*lim, "Phase 7", ha="center", va="center", fontsize=0.85*fs)
plt.text(-0.95*lim, -lim/2, "Phase 8", ha="center", va="center", rotation=90, fontsize=0.85*fs)


# ==============================================================================
# PLOTAGEM DAS TRAJETÓRIAS POR FASE
# ==============================================================================
fase_colors = {1: 'blue', 2: 'red', 3: 'green', 4: 'orange', 
               5: 'purple', 6: 'crimson', 7: 'dodgerblue', 8: 'black'}

for fase in input_csv['Phase'].unique():
    df_fase = input_csv[input_csv['Phase'] == fase].sort_values('Lag')
    
    if df_fase.empty:
        continue
        
    x = df_fase['MIRISA1c1'].values
    y = df_fase['MIRISA1c2'].values
    lags = df_fase['Lag'].values
    
    cor = fase_colors.get(fase, 'blue')
    
    # Linha da trajetória
    axs.plot(x, y, color=cor, linewidth=2, zorder=3,
             label=f"Phase {int(fase)}")
    
    # Pontos intermediários
    axs.scatter(x, y, color=cor, s=25, zorder=4)
    
    # Marcador do Lag INICIAL selecionado (Estrela)
    axs.scatter(x[0], y[0], color='gray', edgecolor='black', marker='*', s=200, zorder=5)
    
    # Marcador do Lag FINAL selecionado (Círculo Preto)
    axs.scatter(x[-1], y[-1], color='darkred', marker='o', s=105, zorder=5)
    
    # Rótulo com o número do lag ao lado de cada ponto
    for i, lag_val in enumerate(lags):
        if -25 <= lag_val <= 0 and lag_val % 5 == 0:
            axs.annotate(
            f"{lag_val:d}", (x[i], y[i]), fontsize=13,
            ha='left', va='top', color="black",
            bbox=dict(fc="w", ec="none", pad=1, alpha=0.7)
        )
        

# Legenda das cores das trajetórias, ordenada por fase
handles, labels = axs.get_legend_handles_labels()
ordem = sorted(range(len(labels)), key=lambda i: int(labels[i].split()[-1]))
fig.legend(
    [handles[i] for i in ordem],
    [labels[i] for i in ordem],
    title="Trajectory origin phase",
    loc="upper center",
    bbox_to_anchor=(0.5, 0.045),
    ncol=4,
    frameon=False,
    fontsize=0.75*fs,
    title_fontsize=0.8*fs,
    handlelength=2.5,
    columnspacing=1.5
)

# Salvar a figura com indicação da quantidade de lags no nome
n_lags = len(lags_desejados)
os.makedirs("outputs/figures", exist_ok=True)
plt.savefig(f"outputs/figures/mirisa_phase_lags_1991-2020.png", bbox_inches="tight", dpi=300)
#plt.show()