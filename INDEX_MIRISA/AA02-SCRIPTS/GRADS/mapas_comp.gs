'reinit'
'set display color white'
'c'
'sdfopen C:/Users/Nete/Documents/NETE_PROJETOS/TESTE_MIRISA/AA03-NC_OUTPUT/PHASES/MIRISA.PHASES.OLR.20230226.nc'
'sdfopen C:/Users/Nete/Documents/NETE_PROJETOS/TESTE_MIRISA/AA03-NC_OUTPUT/PHASES/MIRISA.PHASES.PRP.20230226.nc'


* These are the BLUE shades
'set rgb  16    0    0  255'
'set rgb  17   55   55  255'
'set rgb  18  110  110  255'
'set rgb  19  165  165  255'
'set rgb  20  220  220  255'
* These are the RED shades
'set rgb  21  255  220  220'
'set rgb  22  255  165  165'
'set rgb  23  255  110  110'
'set rgb  24  255   55   55'
'set rgb  25  255    0    0'



px1 = 9.7 
px2 = 10.9
tt=1
while(tt<=8)
'set parea 0.5 7.1 'px1' 'px2''
'set mpdset hires'; 'set grid off'; 'set grads off'
'set lon 20 380';'set xlint 30'
'set lat -35 35' ; 'set ylint 20'
'set xlab off'
'set strsiz 0.2 0.2' ; 'set string 1 c 2 1'
'set gxout shaded'
*'set cmin -30' ; 'set cmax 30' ; 'set cint 10'
'set clevs -25 -20 -15 -10 -5 5 10 15 20 25'
'set ccols 16 17 18 19 20 0 21 22 23 24 25 '
'd miriolr.1(t = 'tt')'
'draw string 0.5 'px2-0.5' F0'tt''

px2 = px1-0.1
px1 = px2 - 1.2

tt = tt+1 
endwhile

'C:/Users/Nete/Documents/NETE_PROJETOS/TESTE_MIRISA/AA02-SCRIPTS/GRADS/cbarn.gs 0.7 0 2.5 0.3' 
px1 = 9.7 
px2 = 10.9
tt=1
while(tt<=8)

'set parea 6.5 8.4 'px1' 'px2''
'set mpdset hires'
'set lon 277 325'
'set lat -35 10' ; 'set ylint 20' ; 'set xlint 20'
'set strsiz 0.2 0.2' ; 'set string 1 c 2 1'
'set gxout shaded'
'set clevs -3.5 -2 -1.5 -1 -0.5 0.5 1 1.5 2 3.5'
'set ccols 25 24 23 22 21 0 20 19 18 17 16'
'd miripr.2(t = 'tt')'

px2 = px1-0.1
px1 = px2 - 1.2

tt = tt+1 
endwhile
'C:/Users/Nete/Documents/NETE_PROJETOS/TESTE_MIRISA/AA02-SCRIPTS/GRADS/cbarn.gs 0.5 0 6.6 0.3' 

'printim C:/Users/Nete/Documents/NETE_PROJETOS/TESTE_MIRISA/AA04-FIG/COMPOSICAO_MIRISA_20230226.png'
****