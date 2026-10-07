import numpy as np
import datetime
import time as time
import os.path
import pandas as pd
#import DART as dart
#import experiment_settings as es
#from calendar import monthrange
#from netCDF4 import Dataset
#import WACCM as waccm
#import DART_state_space as DSS
#import pyclimate.LanczosFilter as LF
#from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
#from scipy.stats import nanmean
import matplotlib.cm as cm
from matplotlib.collections import LineCollection
from matplotlib.lines import Line2D

DF = pd.read_csv("AA03-RData_TxT/MIRISA_REALT_20180101_20230220_CREATE_20230226.txt",sep=";")
#DF.columns=['Year','Month','Day','MIRI.SA1','MIRI.SA2','phase','amplitude']
miri = DF.tail(n=70)

fig = plt.figure(figsize=(20,20)) 
lim=10
fs = 40
ax = plt.subplots()
plt.rc('xtick', labelsize=fs)
plt.rc('ytick', labelsize=fs)
plt.rcParams['xtick.bottom'] = plt.rcParams['xtick.labelbottom'] = True
plt.rcParams['xtick.top'] = plt.rcParams['xtick.labeltop'] = True

plt.rcParams['ytick.right'] = plt.rcParams['ytick.labelright'] = True
plt.rcParams['ytick.left'] = plt.rcParams['ytick.labelleft'] = True

plt.plot([-lim,lim],[-lim,lim],linewidth=1,linestyle='-.',color='k')
plt.plot([-lim,lim],[lim,-lim],linewidth=1,linestyle='-.',color='k')
plt.plot([-lim,lim],[0,0],linewidth=1,linestyle='-.',color='k')
plt.plot([0,0],[-lim,lim],linewidth=1,linestyle='-.',color='k')
#circle = plt.Circle((0, 0), radius=1, fc='w', ec='k')
circle = plt.Circle((0, 0), radius=1, fc='w', ec='k')
plt.gca().add_patch(circle)
plt.xlim([-lim,lim])
plt.ylim([-lim,lim])

plt.figtext(0.5,0.94, "Rain: Western Amazon", ha="center", va="center",color="black",
             fontsize=1.2*fs)
plt.figtext(0.5,0.98, "MJO: Western Pacific", ha="center", va="center",color="blue",
             fontsize=1.2*fs)

plt.figtext(0.5,0.08, "Rain: Western Brazil - South Brazil", ha="center", va="center",color="black",
             fontsize=1.2*fs)
plt.figtext(0.5,0.04, "MJO: Maritime Continent", ha="center", va="center",color="blue",
             fontsize=1.2*fs)

plt.figtext(0.94,0.5, "Rain: Northeast Brazil - South Brazil", ha="center", va="center",color="black",
             fontsize=1.2*fs,rotation=-90)
plt.figtext(0.98,0.5, "MJO: West. Hem. and Africa", ha="center", va="center",color="blue",
             fontsize=1.2*fs,rotation=-90)


plt.figtext(0.08,0.5, "Rain: Eastern Center S.America", ha="center", va="center",color="black",
             fontsize=1.2*fs,rotation=90)
plt.figtext(0.04,0.5, "MJO: Indian Ocean", ha="center", va="center",color="blue",
             fontsize=1.2*fs,rotation=90)

plt.text(-0.95*lim,-lim/2, "Phase 1", ha="center", va="center",rotation=90,fontsize=0.95*fs)
plt.text(-lim/2,-0.95*lim, "Phase 2", ha="center", va="center",fontsize=0.95*fs)
plt.text(lim/2,-0.95*lim, "Phase 3", ha="center", va="center",fontsize=0.95*fs)
plt.text(0.95*lim,-lim/2, "Phase 4", ha="center", va="center",rotation=270,fontsize=0.95*fs)
plt.text(0.95*lim,lim/2, "Phase 5", ha="center", va="center",rotation=270,fontsize=0.95*fs)
plt.text(-lim/2,0.95*lim, "Phase 6", ha="center", va="center",fontsize=0.95*fs)
plt.text(lim/2,0.95*lim, "Phase 7", ha="center", va="center",fontsize=0.95*fs)
plt.text(-0.95*lim,lim/2, "Phase 8", ha="center", va="center",rotation=90,fontsize=0.95*fs)

#plt.plot(miri["MIRISA1c1"],miri["MIRISA1c2"],linewidth=4.6,color=["#000000","#FFEBCD","#0000FF"],marker = '*')


# colormes=["red","blue","green","purple","yellow","orange","red","blue","green","purple","yellow","orange"]
# mon=["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"]
# mes1 = miri["Month"].astype(str).str.zfill(2)
# v3=miri["Year"].astype(str).str.cat(mes1,sep="")
# z1 = np.unique(v3)
# z2 = np.arange(0,len(z1))
# print(z2)
# for x in z2:
#   miri1=miri[v3 == z1[x]]
#   i=np.unique(miri1["Month"].astype(int)).squeeze()-1
#   plt.plot(miri1["MIRISA1c1"],miri1["MIRISA1c2"],linewidth=1.6,color=colormes[i],marker = 'o')
#   plt.text((-lim+0.25)+(x+1),-0.8*lim, mon[i], color=colormes[i],ha="center", va="center",fontsize=0.85*fs,weight='bold')


#plt.text(miri1["MIRISA1c1"],miri1["MIRISA1c2"], miri1["Phase"], ha="center", va="center",rotation=90,fontsize=0.95*fs)


lines = [[(0, 1, 2, 3, 4)*-1, (4, 5, 6, 7, 8)],
         [(0, 1, 2, 3, 4), (0, 1, 2, 3, 4)],
         [(0, 1, 2, 3, 4), (8, 7, 6, 5, 4)*-1],
         [(4, 5, 6, 7, 8), (0, 1, 2, 3, 4)]]

z = np.array([0.1, .4, 3.8, 2.0])

lines = [tuple(zip(x, y)) for x, y in lines]

lines = LineCollection(lines, array=z, linewidths=5,
                       cmap=plt.cm.rainbow, norm=plt.Normalize(z.min(), z.max()))
ax.add_collection(lines)

plt.tight_layout(rect=(0.1,0.1,0.9,0.9))

plt.savefig("AA04-FIG/DIAGRAM_PHASE_SPACE_20230226.png")

#plt.show()
