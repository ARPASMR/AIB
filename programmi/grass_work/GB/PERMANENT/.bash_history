exit
dvect
d.vect
d.mon x0
d.vect
d.rast
d.mon x0
d.rast
d.mon x0
d.rast
d.mon x0
d.rast
d.mon stop
d.mon stopx0
d.mon stop x0
d.mon stop=x0
d.rast
g.remove
d.rast
g.remove
d.rast
g.remove
d.rast
exit
cd
cd programmi/grass_work/
ls
cd scripts/
ls
prova.txt
./prova.txt
./prova.txt ffmc
exit
./prova.txt
./prova.txt ffk
exit
v.in.ascii
exit
v.rast.stats help
exit+
exit
g.region res=1500
r.in.gdal -o input=/home/meteo/programmi/fwi_grid/meteo/ana/neve_ieri.img output=neve --o
d.mon x0
d.rast neve
r.out.arc input=neve output=/home/meteo/programmi/fwi_grid/meteo/ana/neve_ieri.txt
quit
exit
g.region res=1500
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/PROVA999900000.txt  output=indici --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/PROVA9999.txt  output=indici --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/  output=indici --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/PROVA999.txt  output=indici --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/bui_20090306.txt  output=indici --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/file_maria/dc_grezzi_20091210.txt  output=indici --o
pwd
cd programmi/fwi_grid/
ls
cd indici/ana/
ls
vi bui_20090306.txt
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/file_maria/dc_20091210.txt  output=indici --o
vi bui_20090306.txt
vi file_maria/dc_20091210.txt
ls
vi bui_20090306.txt
vi bui_20090306.tx
vi PROVA999900000.txt
vi PROVA9999.txt
vi PROVA999.txt
exit
ls
g.region res=1500
d.mon x0
r.colors 
g.manual -i
whereis grass
cd /usr/lib/
ls
cd grass/
ls
cd etc
ls
cd colors/
ls
vi ryb
cat * >colori
vi terrain 
xterm &
ls
vi population 
vi rainbow 
vi ndvi 
vi evi 
d.mon x0
d.rast
d.rast map=indici_IDI_neve_bruc
d.rast map=indici_IDI_neve_bruc 
d.rast map=indici_IDI_neve_bruc fcolor=blue
d.rast map=indici_IDI_neve_bruc color=blue
d.rast map=indici_IDI_neve_bruc 
d.rast map=indici_IDI
d.rast map=indici_IDI_neve
d.rast map=indici_IDI
d.rast map=indici_IDI_neve
d.rast map=indici_IDI_neve_bruc
ls
vi etopo2 
vi terrain 
vi aspect
vi aspectcolr 
cp aspectcolr prova
ls -l aspectcolr 
su - root 
ls
vi fwi 
xterm 6
xterm &
d.what.rast indici_fill_IDI_neve_bruc
d.mon x0
d.what.rast indici_fill_IDI_neve_bruc
d.what.rast indici_IDI_neve_bruc
d.rast indici_IDI_neve_bruc
d.what.rast indici_IDI_neve_bruc
d.what.rast indici_fill
d.rast indici_fill
d.what.rast indici_fill
rmapcalculator amap=indici_fill formula="if(A>-3," outfile=prova --o
rmapcalculator amap=indici_fill formula="if(A>-3,0,1)" outfile=prova --o
r.mapcalculator amap=indici_fill formula="if(A>-3,0,1)" outfile=prova --o
d.rast prova
d.what.rast prova
r.colors prova
r.colors colors=prova
r.colors color=prova
r.colors map=indici_fill color=gyr
r.colors map=indici_fill color=prova
r.colors map=indici_fill color=fwi
r.colors color=fwi
r.colors map=indici_fill color=fwi
r.mapcalculator amap=indici_fill formula="if(A>-3,0,1)" outfile=prova --o
d.rast prova
d.what rast prova
d.what.rast prova
r.colors map=prova color=fwi
d.rast prova
r.mapcalculator amap=indici_fill formula="if(A>-3,0)if(A<-3,4)" outfile=prova --o
r.mapcalculator amap=indici_fill formula="if(A>-3,0)","if(A<-3,4)" outfile=prova --o
r.mapcalculator amap=indici_fill formula="if(A>-3,0,A<-3,4)" outfile=prova --o
d.rast prova
r.colors map=prova color=fwi
d.rast prova
d.what.rast prova
r.mapcalculator amap=indici_fill formula="if(A>-3,0,A<-3,4)" outfile=prova --o
$L1=1
$L1="1"
r.mapcalculator amap=indici_fill formula="if(A>-3,0;A<-3,4)" outfile=prova --o
r.mapcalculator amap=indici_fill formula="if(A>-3,0)(A<-3,4)" outfile=prova --o
r.mapcalculator amap=indici_fill formula=if"(A>-3,0)(A<-3,4)" outfile=prova --o
r.mapcalculator amap=indici_fill formula="if(A>-3,0,1)" outfile=prova --o
r.colors map=prova color=fwi
d.rast prova
r.colors map=prova color=fwi
d.rast prova
r.colors map=prova color=fwi
colors
exit
d.rast indici_IDI_neve
d.mon x0
d.rast indici_IDI_neve
d.rast indici_IDI
d.rast indici_fill
d.rast indici_IDI_neve
d.rast indici_fill
d.rast indici_IDI_neve
d.rast indici_fill
d.what.rast indici_fill
d.rast indici_IDI_neve
d.what.rast indici_fill
d.rast
exit
ls
vi GRASS_GB_1500m.txt.prova
exit
g.region res=1500
r.in.gdal -o  input=$fileinput output=indici --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/ffmc_grezzi_20090306.txt output=indici --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/ffmc_grezzi_20090306.txt output=indici nodata=-999 --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
d.mon x0
d.rast indici_prova
d.what.rast indici_prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
d.rast indici_prova
d.what.rast indici_prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
d.rast indici_prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
d.rast indici_prova
d.what.rast indici_prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
d.rast indici_prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
d.rast indici_prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
d.rast indici_prova
r.mapcalculator amap=indici_prova formula="if(A=-888.00000,NULL,A)"" outfile=indici_prova --o
d.rast indici_prova
d.what.rast indici_prova
r.mapcalculator amap=indici_prova formula="if(A=-888.00000,NULL,A)"" outfile=indici_prova --o
d.rast indici_prova
d.what.rast indici_prova
d.rast indici_prova
r.mapcalculator amap=indici_prova formula="if(A=-888.00000,NULL,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A=-888.00000,1,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A=-888,1,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A>-888,1,A)" outfile=indici_prova --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,1,A)" outfile=indici_prova --o
d.rast indici_prova
r.mapcalculator amap=indici_prova formula="if(A==-888,NULL,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,NaN,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,NODATA_value,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,Undefinde,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,undefined,A)" outfile=indici_prova --o
d.what.rast indici_prova
r.mapcalculator amap=indici_prova formula="if(A==-888,Null,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,no data,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,'no data',A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,'Null',A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,"Null",A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,,A)" outfile=indici_prova --o
r.mapcalculator amap=indici_prova formula="if(A==-888,'',A)" outfile=indici_prova --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/prova.txt output=indici_prova --o
d.rast indici_prova
d.what.rast indici_prova
r.in.gdal -o input=/home/meteo/programmi/fwi_grid/meteo/ana/neve_20090306.img output=neve --o
r.mask input=neve maskcats=1
r.mapcalculator amap=indici_prova formula="A" outfile=indici_prova --o
g.remove rast=MASK
d.rast indici_prova
d.what.rast indici_prova
exit
cd
cd programmi/grass_work/
ls
cd scripts/
ls
./prova.txt
dmon x0
d.mon x0
d.rast prova
./prova.txt
d.mon x0
d.rast prova
d.what.rast prova
./prova.txt
d.colortable
./prova.txt
r.colors map=prova color=fwi_dc
r.colors  color=fwi_dc
r.colors map=prova colors=fwi_dc
r.colors map=prova color=fwi_dc
r.colors map=prova color="fwi_dc"
r.colors map=prova color=gray
r.colors map=prova color=aspect
r.colors map=prova color=fwi_dc
./prova.txt
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/ffmc_20090306.txt output=prova --o
d.mon x0
d.rast prova
d.what.rast prova
r.colors map=prova color=grey
d.rast prova
d.what.rast prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/ffmc_grezzi_20090306.txt output=prova --o
d.rast prova
d.what.rast prova
d.what.rast neve
d.rast neve
d.what.rast neve
r.mask input=neve maskcats=1
r.mapcalculator amap=prova formula="A" outfile=prova --o
g.remove rast=MASK
d.rast prova
d.what.rast neve
d.what.rast prova
r.mapcalculator amap=prova formula="if(A>0,A)" outfile=prova --o
r.mask if(prova>0)
mask if(prova>0)
r.mapcalculator amap=prova mask=if(A>0) outfile=prova --o
r.mapcalculator amap=prova mask="if(A>0)" outfile=prova --o
r.mapcalculator amap=prova formula=mask(if(A>0)) outfile=prova --o
r.mapcalculator amap=prova formula=mask(ifA) outfile=prova --o
r.mapcalculator amap=prova formula=maskif(A) outfile=prova --o
r.mapcalculator amap=prova formula=maskif(A<0) outfile=prova --o
r.mapcalculator amap=prova formula="if(A>0,A,isnull) outfile=prova --o

r.mapcalculator amap=prova formula="if(A>0,A,isnull) outfile=prova --o
r.mapcalculator amap=prova formula="if(A>0,A,isnull) outfile=prova --o

r.mapcalculator amap=prova formula="if(A>0,A,isnull) outfile=prova --o
r.mapcalculator amap=prova formula="if(A>0,A,isnull)" outfile=prova --o
r.mapcalculator amap=prova formula="if(A>0,A,null())" outfile=prova --o
d.rast prova
d.what.rast prova
r.mapcalculator amap=prova formula="if(A>0,A,null())" outfile=prova --o
r.mapcalculator amap=prova formula="A*1000" outfile=prova_permille --o
r.surf.idw input=prova_permille  output=prova_calc_permille npoints=1 --o
r.mapcalculator amap=prova_calc_permille formula="A/1000" outfile=prova_calc --o
r.mask input=AO
r.mapcalculator amap=prova_calc formula="A" outfile=prova_calc --o
g.remove rast=MASK
r.mapcalculator amap=prova bmap=IDI cmap=prova_calc formula="if(B>0,A,C)" outfile=prova_fill --o
d.mon x0
r.colors map=indici_fill color=fwi_ffmc
d.rast map=prova_fill
r.colors map=prova_fill color=fwi_ffmc
d.rast map=prova_fill
d.what.rast map=prova_fill
r.colors map=prova_fill color=aqua
pwd
cd programmi/grass_work/scripts/
ls
./GRASS_GB_1500m.txt 
exit
g.region res=1500
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/fwi_grezzi_20090306.txt output=indici --o
d.mon x0
d.rast indici
d.what.rast indici
r.mapcalculator amap=indici formula="if(A>0,A,null())" outfile=indici --o
d.rast indici
r.color map=indici colors=grey
r.colors map=indici colors=grey
r.colors map=indici color=grey
d.rast indici
r.colors map=indici color=fwi_fwi
d.rast indici
r.colors map=indici color=fwi_fwi.old
d.rast indici
exit
ls
./GRASS_GB_1500m.
./GRASS_GB_1500m.txt
exit
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/fwi_grezzi_20090306.txt output=indici --o
d.mon x0
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 100 color=black fcolor=255:0:0  lcolor=black bgcolor=230:230:48 bcolor=red   lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 100 color=black fcolor=255:0:0  lcolor=black bgcolor=230:230:48 bcolor=red   lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 100 color=black fcolor=255:0:0  lcolor=black bgcolor=230:230:48 bcolor=red   lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 100" color=black fcolor=255:0:0  lcolor=black bgcolor=230:230:48 bcolor=red   lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 100 color=black fcolor=255:0:0  lcolor=black bgcolor=230:230:48 bcolor=red   lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 100" color=black fcolor=255:0:0  lcolor=black bgcolor=230:230:48 bcolor=red   lsize=14 font=romans xref=center yref=center
d.rast neve
d.rast AB
d.mon x0
d.rast AB
exit
d.mon x0
r.mask 
r.mask input=AO
d.rast neve
g.remove rast=MASK
r.mask input=indici
g.remove rast=MASK
r.mask input=indici
d.rast neve
exit
d.mon x0
d.rast indici_fill_calc
d.what.rast indici_fill_calc
d.rast neve
d.rast indici_fill_calc
d.what.rast indici_fill_calc
d.what.rast indici_fill_calc neve
d.what.rast neve
exit
d.mon x0
d.rast indici
d.rast IDI
d.rast indici
exit
d.mon x0
d.rast indici_calc
d.what.rast indici_calc
d.what.rast indici_calc_permille
d.rast indici_calc_permille
d.what.rast indici_calc_permille
d.rast indici_calc_permille
exit
d.mon x0
d.rast indici
d.rast indici_calc
d.what.rast indici_calc
d.what.rast indici_calc_permille
d.rast indici_calc_permille
exit
ls
cd
d.mon x0
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/dc_20090306.txt output=prova --o
d.mon x0
d.rast prova
d.rast neve
d.rast prova
d.what.rast neve
d.rast neve
d.what.rast neve
d.rast prova
r.mask input=neve maskcats=1
r.mapcalculator amap=prova formula="A" outfile=prova --o
g.remove mask
g.remove rast=mask
g.remove rast=MASK
d.rast prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/dc_20090306.txt output=prova --o
r.mask input=neve maskcats=1
r.mapcalculator amap=prova formula="A" outfile=prova_mask --o
g.remove rast=MASK
d.rast prova
d.rast prova_mask
d.rast neve
d.rast prova
d.rast prova_mask
d.rast prova
d.rast prova_mask
r.color map=prova colors=rainbow
r.colors map=prova colors=rainbow
r.colors map=prova color=rainbow
d.rast prova
d.rast prova_mask
r.colors map=prova_mask color=rainbow
d.rast prova_mask
d.what.rast prova_mask
d.mon stop=x0
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/dc_20090306.txt output=prova --o
exit
./ConversioneCoperturaNevosa.txt 
vi ConversioneCoperturaNevosa.txt 
./ConversioneCoperturaNevosa.txt 
exit
cd
cd 
pwd
cd programmi/grass_work/scripts/
ls
vi GRASS_GB_1500m.txt 
d.mon x0
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/bui_grezzi_20090306.txt output=prova_grezzi --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/bui_20090306.txt output=prova --o
d.rast prova_grezzi
d.what.rast prova_grezzi
d.rast prova
d.rast prova_grezzi
d.mon x1
d.rast neve
d.vect input=AO
r.mask input=AO
r.mask input=AO maskcat=1
vi GRASS_GB_1500m.txt 
r.mask input=AO
g.remove MASK
r.mask input=AO
d.rast neve
g.remove MASK
d.mon x2
d.rast prova
d.what.rast prova
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/ffmc_grezzi_20090306.txt output=prova --o
r.mask input=AO
r.mapcalculator amap=prova formula="A" outfile=prova --o
g.remove rast=MASK
g.region rast=prova res=1500
r.out.arc input=prova output=/home/meteo/programmi/fwi_grid/ini
r.out.arc input=prova output=/home/meteo/programmi/fwi_grid/ini/confini.txt
cd
cd /home/meteo/programmi/fwi_grid/ini/
vi confini.txt 
g.remove
exit
g.remove
exit
g.region res=1500
g.remove rast=indici,indici_permille,indici_calc_permille,indici_calc,indici_fill,indici_fill_calc,IDI,neve,indici_IDI_neve,indici_IDI_neve_bruc
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/ffmc_20090305.txt output=indici
exit
g.region res=1500
r.in.gdal -o input=/home/meteo/script/fwi/conversione_img_neve/swe_neve_20090301_areeinn.img
r.in.gdal -o input=/home/meteo/script/fwi/conversione_img_neve/swe_neve_20090301_areeinn.img output=prova_eq_idrico
d.mon x0
d.rast prova_eq_idrico
r.out.arc input=prova_eq_idrico output=prova_eq_idrico.txt
ls
vi prova_eq_idrico.txt 
pwd
ls
pwd
exit
g.region
g.region -p
d.mon x0
d.rast indici
d.rast
g.region res=1500
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/maria/ffmc_20091012.txt output=indici
d.rast indici
d.rast AO
d.rast AB
g.region -d
g.region -p
d.rast AB
exit
d.rast
ls
vi comandi
d.rast AO
d.mon x0
d.rast AO
g.region res=1500
d.rast AO
g.region
d.rast AO
g.region -p
g.region res=1500
g.region -p
g.region 
g.region rows=177 cols=174 res=1500
g.region -p
vi comandi 
g.region -s vect=AO@PERMANENT
g.region -p
g.region res=1500
g.region -p
g.region
g.region -p
d.mon x0
d.rast AO
g.region -p
d.erase
d.rast AO
g.region
g.region -p
d.rast AO
d.erase
d.rast AO
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/maria/bui_grezzi_20991009.txt output=indici
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/maria/bui_grezzi_20991009.txt output=indici --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/maria/bui_grezzi_20091009.txt output=indici --o
d.mon x0
d.rast indici
d.what.rast indici
d.rast neve
d.what.rast indici
d.rast indici
g.region -p
g.region rast=indici res=1500
d.rast indici
d.erase
d.rast indici
d.what.rast indici

g.region -p
d.rast
g.region 
g.region -p
g.region -d
g.region -p
g.region -d
r.in.gdal -o  input=/home/meteo/Desktop/isi_mask_20100212_prova2.txt output=prova
r.colors map=prova color=fwi_isi_02
d.mon x0
d.rast prova
exit
g.region -d
r.in.gdal -o  input=/home/meteo/Desktop/dc_mask_20090725provetta.txt output=prova --o
d.mon x0
r.colors map=prova color=fwi_dc_07
d.rast prova
d.erase
d.rast prova
d.erase
d.rast prova
d.erase
d.rast prova
r.colors map=prova color=fwi_dc_07
d.rast prova
r.colors map=prova color=fwi_dc_07
d.rast prova
r.colors map=prova color=fwi_dc_07
d.rast prova
r.colors map=prova color=fwi_dc_07
d.rast prova
r.colors map=prova color=fwi_dc_07
d.rast prova
r.colors map=prova color=fwi_dc_07
d.rast prova
r.colors map=prova color=fwi_dc_07
d.rast prova
r.colors map=prova color=fwi_dc_07
d.rast prova
d.mon x0
exit
d.mon x0
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=black fcolor=$colore1 lcolor=black bgcolor=230:230:48 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=black fcolor=blue lcolor=black bgcolor=230:230:48 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.rast map=AO
d.erase
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=black fcolor=blue lcolor=black bgcolor=230:230:48 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=red fcolor=red lcolor=red bgcolor=255:255:255 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=transparent fcolor=red lcolor=red bgcolor=255:255:255 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=red fcolor=red lcolor=red bgcolor=255:255:255 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=transparent fcolor=red lcolor=red bgcolor=255:255:255 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.erase
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=transparent fcolor=red lcolor=red bgcolor=255:255:255 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=red fcolor=red lcolor=red bgcolor=255:255:255 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=5"                                 color=red fcolor=red lcolor=red bgcolor=255:255:255 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
exit
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/dc_grezzi_20100104.txt output=prova --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/IDI_comune_20100104.txt output=prova_idi --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/meteo/ana/IDI_comune_20100104.txt output=prova_idi --o
d.mon x0
d.rast prova
d.rast prova_idi
d.what.rast prova
r.mapcalculator amap=prova formula="A*1000" outfile=prova_permill
r.surf.idw input=prova_permille  out
r.surf.idw input=prova_permill  output=prova_calc_permille npoints=1
r.mapcalculator amap=prova_calc_permille formula="A/1000" outfile=prova_calc
d.rast prova_calc
d.what.rast prova_calc
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
d.what.rast prova_calc
r.surf.idw
r.neighbors input=prova_permill  output=prova_calc_permille
r.neighbors input=prova_permill  output=prova_calc_permille --o
r.mapcalculator amap=prova_calc_permille formula="A/1000" outfile=prova_calc --o
d.rast prova_calc
d.what.rast prova_calc
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/dc_grezzi_20100104.txt output=prova --o
r.in.gdal -o  input=/home/meteo/programmi/fwi_grid/indici/ana/IDI_comune_20100104.txt output=prova_idi --o
r.mapcalculator amap=prova bmap=IDI formula="if(B>0,A,null())" outfile=prova_bucata
r.mapcalculator amap=prova formula="A*1000" outfile=prova_permille --o
r.neighbors input=prova_permille  output=prova_calc_permille --o
r.mapcalculator amap=prova_calc_permille formula="A/1000" outfile=prova_calc
r.mapcalculator amap=prova_calc_permille formula="A/1000" outfile=prova_calc --o
d.rast prova_calc
d.erase
d.rast prova_calc
d.what.rast prova_calc
r.mapcalculator amap=prova_bucata formula="A*1000" outfile=prova_permille --o
r.neighbors input=prova_permille  output=prova_calc_permille --o
r.mapcalculator amap=prova_calc_permille formula="A/1000" outfile=prova_calc --o
d.rast prova_calc
d.vect AO
d.erase
d.rast prova_calc
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
d.what.rast prova_calc
d.rast prova
d.rast IDI
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
d.what.rast prova_calc
d.rast prova_calc
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
r.surf.idw input=prova_permille  output=prova_calc_permille npoints=1 --o
r.mapcalculator amap=prova_calc_permille formula="A/1000" outfile=prova_calc --o
d.rast prova_calc
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
d.what.rast prova_calc
exit
d.rast
d.mon x0
d.rast
g.region -p
exit
d.mon xo
d.mon x0
d.rast indici
exit
d.vect
d.rast
exit
d.rast
exit
d.rast
d.mon x0
d.rast neve
exit
d.mon x0
d.rast A=
d.rast AO
r.mapcalculator amap=AO formula="if(A=2,A,null())"
r.mapcalculator amap=AO formula="if(A=2,A,null())" outfile=prova
r.mapcalculator amap=AO formula="if(A=2,A,null())" outfile=prova --o
r.mapcalculator amap=AO formula="if(A>2,A,null())" outfile=prova --o
r.mapcalculator amap=AO formula="if(A==2,A,null())" outfile=prova --o
d.rast prova
grep legend *
grep label *
v.label map=AO type=centroid layer=1 label=ao
v.label map=AO type=centroid layer=1 labels=ao
d.rast prova
d.what.rast AO
d.rast AO
d.what.rast AO
vi GRASS_WGS84_7Km_II.txt 
vi GRASS_GB_1500m.txt 
vi GRASS_WGS84_7Km_II.txt 
d.rast prova
d.rast neve
d.rast.leg neve
d.rast indici
d.rast.leg indici
d.rast
d.rastleg
d.rast.leg
vi GRASS_GB_1500m.txt 
vi GRASS_WGS84_7Km_II.txt 
d.rast
d.rast prova
d.mon x0
d.rast prova
d.rast indici
d.rast.leg indici
d.rast.leg vallist=0-1,2-3 indici
d.rast vallist=0-1,2-3 indici
d.rast vallist=0-1 indici
d.rast indici vallist=0-1 
d.rast indici vallist=2-5 
d.rast indici vallist=0-5 
d.rast indici vallist=0-0.3 
d.rast indici vallist=0-0.3,0.3-0.5 
d.rast indici vallist=0-0.5 
d.rast indici vallist=0-0.3,0.5-0.6 
d.rast indici 
d.rast prova
exit
d.rast
exit
vi ConversionePrevisioneInGB.txt 
./ConversionePrevisioneInGB.txt 
vi ConversionePrevisioneInGB.txt 
./ConversionePrevisioneInGB.txt 
vi ConversionePrevisioneInGB.txt 
vi GRASS_GB_1500m
vi GRASS_GB_1500m.txt 
vi ConversionePrevisioneInGB.txt 
./ConversionePrevisioneInGB.txt 
vi ConversionePrevisioneInGB.txt 
./ConversionePrevisioneInGB.txt 
vi ConversionePrevisioneInGB.txt 
vi GRASS_GB_1500m.txt 
vi ConversionePrevisioneInGB.txt 
./ConversionePrevisioneInGB.txt 
ls
gwenview map.png 
vi ConversionePrevisioneInGB.txt 
gwenview map.png 
./ConversionePrevisioneInGB.txt 
ls
gwenview label_legenda.gif 
gwenview legenda.png 
vi GRASS_GB_1500m.txt 
ls 
mv legenda.png legenda.png.old
scp mranci@10.10.0.146:/home/mranci/Scrivania/legenda.png .
ls
gwenview 
./ConversionePrevisioneInGB.txt 
exit
quit
exit
cd /opt
ls
exit
g.gui
exit
g.gui
exit
cd /home/meteo/programmi/grass_work/scripts
exit
g.gui
exit
g.gui
exit
g.gui
exit
g.gui
exit
g.list vect
v.info map=AO
v.db.select
v.db.select map=AO
exit
g.region -p
exit
g.region -p
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1 width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1 lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
v.info map=AO
v.label map=AO type=centroid layer=1 column=FI_mean labels=ao_mean xoffset=0 yoffset=0 size=4200 color=black rotation=0 width=1 hcolor=none hwidth=2 background=yellow border=black opaque=yes
exit
g.list vect
v.info map=AO
v.db.select map=AO
v.to.rast input=AO output=AOmask col=NOME
v.to.rast input=AO output=AOmask col=2
db describe -c table=AO
db.describe -c table=AO
v.to.rast input=AO output=AOmask col=2
v.to.rast input=AO output=AOmask use=cat
r.out.arc input=AOmask output=/home/meteo/Documenti/Davide/AOmask.txt
g.list rast
g.remove rast=AOmask
g.list vect
exit
g.gui
n
g.list vect
exit
g.list vect
g.list rast
wxit
exit
v.in.ogr dsn=/home/meteo/programmi/grass_work/scripts/Aree_IC/aree_ic.shp layer=aree_ic output=aree_ic --overwrite -o
v.to.rast
v.to.rast input=aree_ic@PERMANENT type=area output=aree_ic use=attr column=cat
g.gui
exit
v.db.addcol
v.db.addcol map=aree_ic@PERMANENT columns=SNOW_mean
v.rast.stats
v.rast.stats vector=aree_ic@PERMANENT raster=cosmo_00_12@PERMANENT colprefix=SNOW
g.gui
exit
g.list rast
g.gui
exit
r.what --v -f -n input=AB@PERMANENT east_north=1542707.449766,5088183.939252
r.what --v -f -n input=AB@PERMANENT east_north=1515875.674065,5035496.088785
r.what --v -f -n input=AB@PERMANENT east_north=1610030.814252,5055010.107477
r.what --v -f -n input=AB@PERMANENT east_north=1625642.029206,5052083.004673
r.what --v -f -n input=AB@PERMANENT east_north=1593931.748832,5070621.322430
r.what --v -f -n input=AB@PERMANENT east_north=1565148.571262,5107697.957944
r.what --v -f -n input=AB@PERMANENT east_north=1519778.477804,4972075.528037
r.what --v -f -n input=AB@PERMANENT east_north=1453918.664720,5048668.051402
r.what --v -f -n input=AB@PERMANENT east_north=1449528.010514,4984271.789720
r.what --v -f -n input=AB@PERMANENT east_north=1454406.515187,4964757.771028
r.mask
r.mask input=AB@PERMANENT maskcats=1
r.mask
r.mask input=AB@PERMANENT maskcats=2
r.mask input=AB@PERMANENT maskcats=0
r.mask -i input=AB@PERMANENT maskcats=0
r.mask input=AB@PERMANENT maskcats=1
r.info
r.info map=AB@PERMANENT
r.what --v -f -n input=AB@PERMANENT east_north=1719797.169393,4964269.920561
ls
./GRASS_GB_1500m_rgmod
g.gui
exit
r.mask input=AO maskcats=1
r.univar
r.univar map=indici_tmp@PERMANENT
r.univar -e map=indici_tmp@PERMANENT
g.remove rast=MASK
r.mask input=AO maskcats=1
r.univar
r.univar map=indici_fill_calc@PERMANENT
r.univar map=indici_fill_calc@PERMANENT,indici_IDI_neve_bruc@PERMANENT
r.univar map=indici_fill_calc@PERMANENT,indici_IDI_neve_bruc@PERMANENT,indici_tmp@PERMANENT
r.univar map=indici_tmp@PERMANENT
v.rast.stats
v.rast.stats vector=AO@PERMANENT raster=indici_tmp@PERMANENT colprefix=test
g.remove rast=MASK
v.rast.stats vector=AO@PERMANENT raster=indici_tmp@PERMANENT colprefix=test
v.rast.stats -c vector=AO@PERMANENT raster=indici_tmp@PERMANENT colprefix=test
v.rast.stats -c vector=AO@PERMANENT raster=indici_fill_calc@PERMANENT colprefix=test
v.rast.stats -c vector=AO@PERMANENT raster=indici_tmp@PERMANENT colprefix=test
g.gui
exit
v.in.ogr -o dsn=/home/meteo/programmi/grass_work/DATI/superficie_bruciabile/Grimaldelli_invio_17_12_2008/celle_NOAA_bruciabile/celle_noaa_bruciabile_2000mq.shp output=test_AB_1
v.in.ogr -o dsn=/home/meteo/programmi/grass_work/DATI/superficie_bruciabile/Grimaldelli_invio_17_12_2008/Bruciabile_seviri/seviri_singol2000_5000_10000.shp output=test_AB_2
v.in.ogr -o dsn=/home/meteo/programmi/grass_work/DATI/superficie_bruciabile/Grimaldelli_invio_17_12_2008/Bruciabile_seviri/seviri_sommatoria_bruciabile_2000_5000_10000.shp output=test_AB_3
v.to.rast
v.to.rast input=test_AB_1@PERMANENT output=test_AB_1 use=attr column=BRUCIABILE
v.to.rast --overwrite input=test_AB_1@PERMANENT type=point output=test_AB_1 use=attr column=BRUCIABILE
v.to.rast --overwrite input=test_AB_1@PERMANENT type=area output=test_AB_1 use=attr column=BRUCIABILE
v.to.rast input=test_AB_2@PERMANENT output=test_AB_2 use=attr
v.to.rast input=test_AB_2@PERMANENT output=test_AB_2 use=attr column=SING5000
v.surf.idw
v.surf.idw input=test_AB_1@PERMANENT output=test_AB_1@PERMANENT column=BRUCIABILE npoints=1
v.surf.idw --overwrite input=test_AB_1@PERMANENT output=test_AB_1@PERMANENT column=BRUCIABILE npoints=1
v.surf.idw --overwrite input=test_AB_1 output=test_AB_1 column=BRUCIABILE npoints=1
r.what --v -f -n input=test_AB_1@PERMANENT east_north=1510731.779895,5069075.989606
r.what --v -f -n input=test_AB_1@PERMANENT east_north=1570608.046023,5035856.965247
r.what --v -f -n input=test_AB_1@PERMANENT east_north=1585372.056849,5039547.967954
r.what --v -f -n input=test_AB_1@PERMANENT east_north=1580860.831319,4983362.704532
r.info map=AB@PERMANENT
g.remove vect=test_AB_1, test_AB_2, test_AB_3
g.remove vect=test_AB_1,test_AB_2,test_AB_3
g.remove rast=test_AB_1
r.mapcalculator amap=AB bmap=indici_bucato output=test_bruc formula if A=1, B, null()
r.mapcalculator amap=AB bmap=indici_bucato outfile=test_bruc formulaif A>0, B, null()
r.mapcalculator amap=AB bmap=indici_bucato outfile=test_bruc formulaif (A>0, B, null())
r.mapcalculator amap=AB bmap=indici_bucato outfile=test_bruc formula=if (A>0,B,null())
g.region
g.region -p
g.region -d
g.region -p
r.mapcalculator amap=AB bmap=indici_bucato outfile=test_bruc formula=if (A>0,B,null())
r.mapcalculator amap=AB bmap=indici_bucato outfile=test_bruc formula=if (A>0,B,null()) --overwrite
r.mapcalculator amap=AB bmap=indici_bucato outfile=test_bruc_2 formula=if (A>0, B, null())
g.remove rast=test_bruc,test_bruc_2
g.gui
exit
r.info map=AO@PERMANENT
v.info map=AO@PERMANENT
v.info -t map=AO@PERMANENT
r.info
.info
v.info
exit
g.gui
exit
g.gui
exit
v.db.se√lect -c map=AO
v.db.select -c map=AO
v.db.select -c map=AO file=/home/meteo/programmi/stati_test.txt
exit
v.db.select -c map=AO layer=1 column=FI_n,FI_min,FI_max,FI_mean,FI_range,FI_stddev,FI_varianc,FI_cf_var,FI_sum fs=" "
v.db.select -c map=AO layer=1 column=cat,FI_n,FI_min,FI_max,FI_mean,FI_range,FI_stddev,FI_varianc,FI_cf_var,FI_sum fs="|"
v.db.select -c map=AO layer=1 fs="|"
exit
v.db.select -c map=AO layer=1
exit
v.info vector=AO
v.info map=AO
v.db
v.db.select
xit
exit
v.db.select map=AO
exit
g.list type=vect
g.remove vect=aree_ic
g.list type=vect
g.remove vect=test2, test2_tmp
g.remove vect=test2,test2_tmp
g.list type=vect
g.remove vect=ecmwfhr01
g.remove vect=ecmwfhr02
g.remove vect=ecmwfhr03
g.remove vect=ecmwfhr04
g.remove vect=ecmwfhr05
g.remove vect=ecmwfhr06
g.remove vect=ecmwfhr07
g.remove vect=ecmwfhr08
g.remove vect=ecmwfhr09
g.remove vect=ecmwfhr11
g.remove vect=ecmwfhr12
g.remove vect=ecmwfhr13
g.remove vect=ecmwfhr14
g.remove vect=ecmwfhr15
g.remove vect=ecmwfhr16
g.remove vect=ecmwfhr17
exit
v.in.ogr
v.in.ogr dsn=/home/meteo/programmi/grass_work/Aree_IC/aree_neve.shp output=aree_ic
v.in.ogr dsn=/home/meteo/programmi/grass_work/scripts/Aree_IC/aree_neve.shp output=aree_ic
exit
v.db.select map=aree_ic@PERMANENT
g.gui wxpython
exit
g.list vect
v.info
v.info map=LAMI
v.db.connect map=LAMI -p
v.db.connect -c map=LAMI
exit
g.gui wxpython
rxit
exit
g.gui
g.list b
g.gui
exit
v.in.ogr dsn=/home/meteo/programmi/grass_work/scripts/stazioni_GB/stazioni_fireless_GB.shp layer=stazioni_fireless_GB output=stazioni_fireless_GB
g.gui
g.list vect
exit
g.gui
exit
d.mon --help
exit
v.build.all
g.list
g.list type=raster
exit
r.mask --help
r.mask vector=AO  --quiet
g.list --help
g.list type=vector
d.mon start=png output=test_wind.png --quiet --overwrite
d.mon select=png --quiet
r.colors map=wind rules=legende/scala_colori_ws --quiet
d.rast map=wind --quiet
d.mon stop=png --quiet
exit
tempout=/home/roberto/conversione_GRASS/immagini/png/t_20200607.png
d.mon start=png output=$tempout --quiet --overwrite
 d.mon select=png --quiet
 r.colors map=temp rules=legende/scala_colori_temp --quiet
 d.rast map=temp --quiet
 d.legend raster=temp labelnum=10 at=10,65,0,5 --quiet
d.mon stop=png --quiet
r.out.png --help
r.out.png
sudo apt install grass
nano script_dmon.sh
sh script_dmon.sh 
sh script_dmon.sh 
exit
exit
exit
