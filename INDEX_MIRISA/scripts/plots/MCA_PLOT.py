# Caminhos relativos à raiz INDEX_MIRISA; cálculo científico preservado.
from pathlib import Path
import os
import sys
_mirisa_root = Path(os.environ.get("MIRISA_ROOT", Path(__file__).resolve().parents[2])).resolve()
sys.path.insert(0, str(_mirisa_root / "scripts/functions/PYTHON"))
from project_paths import setup_project
setup_project(_mirisa_root)

#!/usr/bin/env python
# coding: utf-8

import os
import numpy as np
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.io.img_tiles as cimgt

from mpl_toolkits.basemap import Basemap
from matplotlib.patches import Polygon
from netCDF4 import Dataset as netcdf_dataset
import pyproj
import matplotlib.gridspec as gridspec
from matplotlib.colors import from_levels_and_colors

import contextily as ctx
import geopandas as gpd

##


dataset = netcdf_dataset("outputs/netcdf/PRP.MIRISA.20230222.nc")
coef_rain = dataset.variables['prp']


lats1 = dataset.variables['lat'][:]
lons1 = dataset.variables['lon'][:]-360


lon_1 = lons1.mean()
lat_1 = lats1.mean()

lon1, lat1 = np.meshgrid(lons1, lats1)

df = gpd.read_file("data/static/shapes/gadm36_BRA_1.shp")


gs0 = gridspec.GridSpec(2, 2,wspace=0.2)



fig = plt.figure(figsize=(25,12)) 

levels1a =[-0.045,-0.035,-0.025,-0.015,-0.005,0.005,0.015,0.025,0.035,0.045] 


n_colors1 = len(levels1a)+1
cmap1a = plt.get_cmap('seismic', n_colors1)
cmap1a = cmap1a.reversed()

for i in [0,1]:
    ax1 = plt.subplot(gs0[i,0]) 
    RegM = [-82,-32,-40,10]
    m = Basemap(projection='mill',lat_ts=10,llcrnrlon=RegM[0],urcrnrlon=RegM[1],llcrnrlat=RegM[2],urcrnrlat=RegM[3],ax=ax1,epsg="4326")
    xi, yi = m(lon1, lat1)
    c3 = m.contourf(xi,yi,coef_rain[i,::],cmap=cmap1a,levels=levels1a)
    m.drawparallels(np.arange(RegM[2],RegM[3],10),labels=[1,0,0,0], fontsize=12,                        linewidth=0.25, color='0.5')
    m.drawmeridians(np.arange(RegM[0]+2,RegM[1],15),labels=[1,1,0,1], fontsize=12,                        linewidth=0.25, color='0.5')
    df.plot(ax=ax1,edgecolor = "black",facecolor="none")
    m.drawcoastlines()
    m.drawcountries()
    plt.title("Total de Dias Chuvosos (RR1)",fontsize=20) 
    
    ax1 = plt.subplot(gs0[i,1]) 
    m = Basemap(projection='mill',lat_ts=10,llcrnrlon=-58.,urcrnrlon=-34,llcrnrlat=-20,urcrnrlat=4,ax=ax1,epsg="4326")
    xi, yi = m(lon1, lat1)
    c3 = m.contourf(xi,yi,coef_rain[i,::],cmap=cmap1a,levels=levels1a)
    m.drawparallels(np.arange(RegM[2],RegM[3],3),labels=[1,0,0,0], fontsize=12,                        linewidth=0.25, color='0.5')
    m.drawmeridians(np.arange(RegM[0],RegM[1],5),labels=[1,1,0,1], fontsize=12,                        linewidth=0.25, color='0.5')
    df.plot(ax=ax1,edgecolor = "black",facecolor="none")
    plt.title("Indice de Chuva Simples (SDII)",fontsize=20) 

    # ax2 = plt.subplot(gs0[i,1])
    # RegM = [-51.5,-43,-7.3,-2]

    # m = Basemap(projection='mill',llcrnrlon=RegM[0],urcrnrlon=RegM[1],llcrnrlat=RegM[2],urcrnrlat=RegM[3], ax=ax2,epsg="4326")
    # xi, yi = m(lon1a, lat1a)
    # m.contourf(xi,yi,rr1[i,::],cmap=cmap1a,levels=levels1a)
    # m.drawparallels(np.arange(-12,3,2),labels=[1,0,0,0], fontsize=16,linewidth=0.25, color='0.5')
    # m.drawmeridians(np.arange(RegM[0],RegM[1],2),labels=[1,1,0,1], fontsize=14,linewidth=0.25, color='0.5')
    # #dmask.plot(ax=ax1,edgecolor = "black",facecolor="white")
    # df.plot(ax=ax2,edgecolor = "black",facecolor="none")
    # dferro.plot(ax=ax2,edgecolor = "darkred",facecolor="none",lw=2)
    # defc.plot(ax=ax2,edgecolor = "black",facecolor="none",lw=4)
    # d_itaca.plot(ax=ax2,edgecolor = "darkgreen",facecolor="none",lw=4)
    # plt.title("Total de Dias Chuvosos (RR1)",fontsize=20) 

# # # # # # # # # # 

# # # # # # # # # # 


cax1 = plt.axes([0.2, 0.03, 0.18, 0.02])
cbar1 = plt.colorbar(c3,cax=cax1,orientation="horizontal")
for t in cbar1.ax.get_xticklabels():
    t.set_fontsize(11)     

   

#plt.tight_layout()    

plt.savefig("outputs/figures/DIAGRAM_PHASE-SPACE_20230226.png")




