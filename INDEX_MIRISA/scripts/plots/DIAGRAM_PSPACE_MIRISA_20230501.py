# Caminhos relativos à raiz INDEX_MIRISA; cálculo científico preservado.
from pathlib import Path
import os
import sys
_mirisa_root = Path(os.environ.get("MIRISA_ROOT", Path(__file__).resolve().parents[2])).resolve()
sys.path.insert(0, str(_mirisa_root / "scripts/functions/PYTHON"))
from project_paths import setup_project
setup_project(_mirisa_root)

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from matplotlib.colors import ListedColormap, BoundaryNorm

import datetime
import time as time
import os.path
import pandas as pd
from datetime import date
import matplotlib.patches as mpatches

input_csv = pd.read_csv("outputs/tables/MIRISA_REALT_20180101_20231021_CREATE_20231021.txt",sep=";")
nt=40
nt1="40"
miri = input_csv.tail(n=nt)

mirisa1 = miri["MIRISA1c1"]
mirisa2 = miri["MIRISA1c2"]
year    = miri["Year"]
month   = miri["Month"]
day     = miri["Day"]
lim=3

# Create a set of line segments so that we can color them individually
# This creates the points as a N x 1 x 2 array so that we can stack points
# together easily to get the segments. The segments array for line collection
# needs to be (numlines) x (points per line) x 2 (for x and y)
points = np.array([mirisa1, mirisa2]).T.reshape(-1, 1, 2)
segments = np.concatenate([points[:-1], points[1:]], axis=1)
class_cor = month.astype(int)

yyyymm=np.unique(year.astype(str).str.cat(month.astype(str).str.zfill(2),sep=""))

datai=year.iloc[0].astype(str)+"-"+str(month.iloc[0]).zfill(2)+"-"+day.iloc[0].astype(str)
dataf=year.iloc[-1].astype(str)+"-"+str(month.iloc[-1]).zfill(2)+"-"+day.iloc[-1].astype(str)

# Create a continuous norm to map from data points to colors
mon   = ["Jan","Feb","Mar","Apr","May","June","Jul","Aug","Sep","Oct","Nov","Dec"]
cores = ["red","green","coral","blue","gold","darkviolet","crimson","darkgreen","orange","navy","yellowgreen","purple"]

z = np.unique(class_cor)
cmap = ListedColormap(cores[min(z)-1:max(z)])
fs = 36

limF = [0.15,0.15,0.65,0.65]
fig = plt.figure(figsize=(20, 20))
axs = fig.add_axes([limF[0], limF[1], limF[2], limF[3]])

axs.tick_params(labelsize=fs, 
	top=True, bottom=True, left=True, right=True,
	labeltop=True, labelbottom=True, labelleft=True, labelright=True)
axs.set_xlim(-lim,lim)
axs.set_ylim(lim,-lim)

axs.plot([-lim,lim],[-lim,lim],linewidth=1,linestyle='-.',color='k',zorder=1)
axs.plot([-lim,lim],[lim,-lim],linewidth=1,linestyle='-.',color='k',zorder=1)
axs.plot([-lim,lim],[0,0],linewidth=1,linestyle='-.',color='k',zorder=1)
axs.plot([0,0],[-lim,lim],linewidth=1,linestyle='-.',color='k',zorder=1)
circle = mpatches.Circle((0, 0), radius=1, fc='w', ec='k')
axs.add_patch(circle)

plt.figtext(0.5,limF[3]+0.21,"Rain: Western Amazon",ha="center",va="center",color="black",fontsize=fs)
plt.figtext(0.5,limF[3]+0.24,"MJO: Western Pacific",ha="center",va="center",color="blue",
    fontsize=fs)

plt.figtext(0.5,limF[1]-0.06,"Rain: Western Brazil - South Brazil",ha="center",va="center",color="black",fontsize=fs)
plt.figtext(0.5,limF[1]-0.09,"MJO: Maritime Continent",ha="center",va="center",color="blue",fontsize=fs)

plt.figtext(limF[2]+0.21,0.5,"Rain: Northeast Brazil - South Brazil",ha="center",va="center",color="black",fontsize=fs,rotation=-90)
plt.figtext(limF[2]+0.24,0.5,"MJO: West. Hem. and Africa",ha="center",va="center",color="blue",fontsize=fs,rotation=-90)

plt.figtext(limF[0]-0.06,0.5,"Rain: Eastern Center S.America",ha="center",va="center",color="black",fontsize=fs,rotation=90)
plt.figtext(limF[0]-0.09,0.5,"MJO: Indian Ocean",ha="center",va="center",color="blue",
             fontsize=fs,rotation=90)


plt.text(-0.95*lim,-lim/2, "Phase 8", ha="center", va="center",rotation=90,fontsize=0.95*fs)
plt.text(-lim/2,-0.95*lim, "Phase 7", ha="center", va="center",fontsize=0.95*fs)
plt.text(lim/2,-0.95*lim, "Phase 6", ha="center", va="center",fontsize=0.95*fs)
plt.text(0.95*lim,-lim/2, "Phase 5", ha="center", va="center",rotation=270,fontsize=0.95*fs)
plt.text(0.95*lim,lim/2, "Phase 4", ha="center", va="center",rotation=270,fontsize=0.95*fs)
plt.text(-lim/2,0.95*lim, "Phase 2", ha="center", va="center",fontsize=0.95*fs)
plt.text(lim/2,0.95*lim, "Phase 3", ha="center", va="center",fontsize=0.95*fs)
plt.text(-0.95*lim,lim/2, "Phase 1", ha="center", va="center",rotation=90,fontsize=0.95*fs)

print(z)

lc = LineCollection(segments, cmap=cmap, array=z)
lc.set_array(class_cor)
lc.set_linewidth(4)
line = axs.add_collection(lc)



for i in np.arange(0,nt,1):
	axs.scatter(mirisa1.iloc[i],mirisa2.iloc[i], c=cores[month.iloc[i]-1],s=2*fs)

axs.scatter(mirisa1.iloc[0],mirisa2.iloc[0], c="dimgray",s=20*fs,marker="8")
axs.scatter(mirisa1.iloc[-1],mirisa2.iloc[-1], c="dimgray",s=20*fs,marker="X")

for i in np.arange(1,nt,5):
	axs.annotate(day.iloc[i],(mirisa1.iloc[i],mirisa2.iloc[i]),
		fontsize=0.7*fs,va='center', ha='center',bbox=dict(fc="w",ec="w", alpha=0.55))


plt.figtext(0.34,0.92, "MIRI.SA Phases: ", ha="center", va="center",color="k",
             fontsize=1.1*fs,weight='bold')
plt.figtext(0.65,0.92, datai+" to "+dataf, ha="center", va="center",color="k",
             fontsize=fs)


for j in np.arange(0,len(yyyymm)):
	plt.figtext(0.35+0.1*j,0.025, mon[int(yyyymm[j][4:6])-1]+"-"+yyyymm[j][2:4], color=cores[int(yyyymm[j][4:6])-1],ha="center", va="center",
              fontsize=0.8*fs,weight='bold')

f = lambda m,c: plt.plot([],[],marker=m, color="dimgray", ls="none",markersize=0.8*fs)[0]
handles = [f("8", "k"),f("X", "k")]
labels = ["Start", "End"]

plt.legend(handles, labels, bbox_to_anchor=(0.25, -0.15),ncol=3,fontsize=0.8*fs,frameon=False)

today = date.today().strftime("%Y%m%d")

plt.savefig("outputs/figures/MIRISA_DIAGPS_NT_"+nt1+"_"+datai.replace("-","")+"_"+dataf.replace("-","")+"_C"+today+".png",bbox_inches = "tight")
