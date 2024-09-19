### 											     ASSIMILAÇÃO DOS DADOS DO MIRI.SA

##### AA00-NC-BRUTOS : ['Base de Dados brutas em NC4 NC_classic ']

##### AA02-ANOM      : ['Anomalias Brutas']

##### AA03-APAD      : ['Anomalias padronizadas']

##### AA04-COEF_EXP  : ['Coeficiente de expansão']

#### Site para download das variaveis:
#### *U-wind*
          
           https://downloads.psl.noaa.gov/Datasets/ncep.reanalysis/Dailies/pressure/ 
 
#### *V-wind*
           
           https://downloads.psl.noaa.gov/Datasets/ncep.reanalysis/Dailies/pressure/ 
 
#### *Rain CPC*

 
###### _[Option 1]_ 
			
							https://psl.noaa.gov/data/gridded/data.cpc.globalprecip.html
 

###### _[Option 2]_ 
			
							ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/RT/

 
#### *OLR* 
	
					https://www.ncei.noaa.gov/data/outgoing-longwave-radiation-daily/access/


##### *TESTE DE AVALIAÇÃO (2023)*
###### - VERIFICAR SE O FILTRO DO R É EQUIVALENTE AO FILTRO DO NCL
###### - PACOTE DO R (signal)
###### - PACOTE DO R library(seewave) *- ATUALIZADO: 26-02-2023* 


##### *FAZER O TESTE DA MCA COM DIFERENTES FILTRAGENS*
######  1 - BUTTERWORFH NO NCL (PERDE 40 DIAS)
######  2 - PASSA-BANDA NO CDO (PROBLEMAS COM OLR, SEM TEMPO PRA CORRIGIR)
######  3 - BUTTERWORFH NO R (RESPOSTAS COM POUCAS DIFERENÇAS DO NCL, MELHOR OPÇAO, POUCA PERDA DE SINAL)
######  4 - BUTTERWORFH NO PYTHON (RESPOSTA DIFERENTES DO NCL) 

##### *ATUALIZAÇAO 26-02-2023* 
 ###### - FOI REAPLICA A MCA NOS DADOS CLIMATOLOGICOS, DE 1991-03-01 ATÉ 2020-02-28 (29 ANOS). PARA AGILIZAR O PROCESSO, FOI MULTIPLICADO OS VALORES APENAS NOS ARQUIVOS DE SAIDA E SALVOS NOVAMENTE. 

###### - TAMBÉM FOI CORRIGDO O PERFIL PARA CALCULO DAS FASES FOI TROCADO 
    
#### _function(x1,x2) ---->> function(x2,x1)_
 
##### *ATUALIZAÇAO 01-05-2023* 
###### - FOI COMCLUIDO A ROTINA DO DIAGRAMA DA PHASE-SPACE NO PYTHON - EM INGLÊS OS TERMOS 
###### - FOI TESTADO A PROJEÇAO DO MIRISA PARA O DIA 26-04-2023, RAPIDO E FACIL 

#####  [É NECESSARIO VERIFICAR AS ROTINAS DE PRE-PROCESSAMENTO, DOS DADOS NCDF] 

