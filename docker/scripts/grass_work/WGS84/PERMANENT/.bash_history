pwd
cd /home/meteo/programmi/grass_work/scripts/output/indice_latlon_7km/
r.in.ascii input=LAMI.csv output=indici_nuovo nv=-999 --o
pwd
cd /home/meteo/programmi/grass_work/scripts/output/indice_latlon_7km
r.in.ascii input=/home/meteo/programmi/grass_work/scripts/output/indici_latlon_7km/LAMI.csv output=indici_nuovo nv=-999 --o
exit
v.out.ogr
./alfuoco.sh 
exit
d.vect
d.rast
d.mon x0
d.rast
exit
ls
vi 1
rm 1
ls
d.vect
d.mon x0
d.vect
d.rast
g.remove
d.rast
exit
r.in.ascii input= output=prova nv=-999 --o
r.in.ascii input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_20091124_2.txt output=prova nv=-999 --o
r.in.arc input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_20091124_2.txt output=prova nv=-999 --o
r.in.arc input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_20091124_2.txt output=prova --o
r.in.arc input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova nv=-999 --o
r.in.arc input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
r.in.ascii input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.ogr input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.ogr dns=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.ogr dsn=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.ogr dsn='/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt' output=prova --o
v.in.ogr 'dsn=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt' output=prova --o
v.in.ogr dns=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.ogr -c dns=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.ogr -c -o dns=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.ogr -c -o dns=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova  min_area=0.0001 --o
v.in.ogr -c -o dns=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova  min_area=0.0001 snap =-1--o
v.in.ogr
v.in.ogr -c -o dns=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova  type=point --o
v.in.ogr dsn=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova type=point --o
v.in.ascii dsn=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova type=point --o
v.in.ascii input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.arc input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
v.in.ascii input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
db.in.ogr input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
db.in.ogr dsn=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt output=prova --o
db.in.ogr dsn=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt --o
db.in.ogr dsn=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20091124_2.txt
db.in.ogr
v.in.ogr
v.in.ogr 
db.in.ogr
v.in.ascii
d.vect
d.mon x0
d.vect
g.remove
d.vect
v.in.ascii
d.vect
g.region vect=LAMI@PERMANENT res=0.063
d.vect
v.in.ascii
d.vect
v.what.vect
v.in.ascii
d.vect
v.in.ascii
d.vect
d.mon stop
d.mon stop=x0
d.mon x0
d.vect
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1
d.vect map=prova type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1
exit
d.vect
d.mon x0
d.vect indici_nuovo1
d.vect
d.mon x0
d.vect
v.to.rast input=indice_nuovo1@PERMANENT output=prova use=attr type=point,line,area layer=1 column= value=1 
pwd
v.to.rast input=/home/meteo/programmi/grass_work/WGS84/indice_nuovo1@PERMANENT output=prova use=attr type=point,line,area layer=1 column= value=1 
v.to.rast
d.mon x0
d.mon stop=x0
d.mon x0
d.rast
exit
d.vect
d.mon X0
d.mon x0
d.vect indici_nuovo1
d.what.vect
v.voronoi 
d.vect
v.voronoi 
d.vect prova
v.voronoi 
gis.m &
d.vect prova
d.erase
d.vect prova
d.erase
d.vect
d.what.vect
d.vect
d.what.vect
cd ../indici/prev/
vi bui_lami_20091212_2.txt 
v.in.ascii
d.mon x0
d.vect
d.what.vect
d.vect
d.what.vect
cd ..
ls
cd ..
cd fwi_grid/
ls
cd ..
cd grass_work/scripts/
ls
vi GRASS_WGS84_7Km_I.txt 
d.rast
d.mon x0
d.rast indici
exit
d.rast
d.mon x0
d.rast indici
d.vect
v.to.rast
d.what.vect AO
v.to.rast
d.rast
d.vect
d.mon x0
d.vect LAMI
d.what.vect
v.what.rast vector=LAMI raster=indici column=VAL
v.what.rast vector=LAMI raster=AO column=AO
v.what.rast
v.vect
d.vect
g.remove
g.copy
d.vect
d.what.vect AOsuLAMI
v.what.rast vector=AOsuLAMI raster=AO column=VAL
d.what.vect AOsuLAMI
v.select ainput=AOsuLAMI binput=AO output=prova
v.select ainput=AOsuLAMI binput=AO output=prova --o
d.vect 
d.what.vect 
v.select
d.mon x0
d.what.vect 
d.vect 
d.what.vect 
d.clear
d.mon clear
exit
cd ..
cd scripts/
ls
d.mon x0
d.rast AO
d.vect
d.what.vect
d.mon stop
d.mon stop=x0
d.mon x0
d.vect
d.what.vect
d.vect AO
d.what.vect
d.mon stop=x0
d.mon x0
d.vect AO
d.mon stop=x0
d.mon x0
d.vect 
d.what.vect
d.mon stop=x0
write.table
ls
exit
v.what.vect
v.average
r.average
exit
d.vect
d.mon x0
d.vect
d.what.vect
r.surf.idw input=indici_nuovo1 output=indici_nuovo1 npoint=1 column=VAL --o
r.surf.idw
v.to.rast
d.rast
d.mon stop=x0
v.remove
remove.vect
g.remove
d.vet
d.vect
exit
d.vect
d.mon x0
d.vect
d.what.vect
v.in.ascii
d.mon x1
d.vect
d.what.vect
d.mon stop x0
d.mon stop=x0
d.mon stop=x1
d.mon x0
d.rast
v.to.rast
d.mon x0
d.rast
g.remov
g.remove
d.rast
g.remove
d.rast
exit
v.in.ascii
exit
d.mon x0
d.vect
d.what.vect
v.out.ogr
exit
d.mon x0
d.vect
to
r.surf.idw
v.to.rast
d.what.vect
v.to.rast
d.rast
d.what.rast
d.rast
g.remove
d.rast
v.to.rast
g.remove
v.to.rast
d.rast
d.mon stop=x0
d.mon x0
d.rast
d.mon x0
v.to.rast
d.rast
v.to.rast
d.rast
v.to.rast
d.rast
exit
v.to.rast 
d.mon x0
d.rast
v.to.rast 
d.vect
d.what.vect
d.what.rast
d.what.rast.vect
d.what.vect.rast
d.what.rast
exit
d.rast
g.remove
d.mon x0
g.region vect=LAMI@PERMANENT res=0.063
d.vect
v.to.rast
d.rast
g.region vect=LAMI@PERMANENT res=0.063
d.rast
v.to.rast
d.rast
v.to.rast
d.rast
v.to.rast
d.rast
g.region rast=AO 
v.to.rast
g.region rast=AO 
d.rast
d.mon stop=x0
d.mon x0
d.rast indici_prev1
g.region vect=AO
g.remove
v.to.rast
d.rast indici_prev1
g.region vect=AO res=0.063
v.to.rast
d.rast indici_prev1
g.region vect=AO res=0.07
g.region vect=AO res=0.064
v.to.rast
d.rast indici_prev1
g.region vect=AO res=0.065
d.rast indici_prev1
g.region vect=AO res=0.07
v.to.rast input=indici_prev1@PERMANENT output=indici_prev1 use=attr type=point,line,area layer=1 column=dbl_5 value=1 rows=4096 --overwrite --quiet 
d.rast indici_prev1
g.region vect=AO res=0.1
v.to.rast input=indici_prev1@PERMANENT output=indici_prev1 use=attr type=point,line,area layer=1 column=dbl_5 value=1 rows=4096 --overwrite --quiet 
d.rast indici_prev1
g.region vect=AO res=0.08
v.to.rast input=indici_prev1@PERMANENT output=indici_prev1 use=attr type=point,line,area layer=1 column=dbl_5 value=1 rows=4096 --overwrite --quiet 
d.rast indici_prev1
g.region vect=AO res=0.09
v.to.rast input=indici_prev1@PERMANENT output=indici_prev1 use=attr type=point,line,area layer=1 column=dbl_5 value=1 rows=4096 --overwrite --quiet 
d.rast indici_prev1
d.rast.what
d.what.rast
d.rast i
d.rast 
grep g.region *
d.vect indice_prev1
d.vect indici_prev1
d.what
d.what.vect
d.vect AO
d.vect
d.rast indici_prev1
d.vect AO
exit
g.region vect=AO
g.region -s vect=AreeOmogenee@PERMANENT
g.region 
r.colors
d.rast AO
d.mon x0
d.rast AO
d.vect AO
d.rast AO
d.rast indici_prev1
d.rast AO
d.rast indici_prev1
d.rast AO
d.rast indici_prev1
d.rast AO
d.rast indici_prev1
d.rast AO
d.rast indici_prev1
d.rast indici_prev1 AO
d.rast indici_prev1,lAO
d.rast indici_prev1,AO
d.rast 
d.mon x0
d.rast 
d.what.rast
d.rast
d.what.rast
exit
cd programmi/grass_work/scripts/
vi GRASS_WGS84_7Km_II.txt 
d.mon x0
d.vect indici_prev1
v.surf.idw
d.rast indici_prev1
d.vect indici_prev1
vi GRASS_WGS84_7Km_II.txt 
v.surf.idw
vi GRASS_WGS84_7Km_II.txt 
exit
d.vect
d.vect help
v.label help
exit
g.region vect=LAMI@PERMANENT res=0.063
d.mon x0
d.what.rast map=indici
d.rast inpuit=AO
d.rast input=AO
d.vect input=AO
d.vect 
d.rast
d.rast inpuit=AO
d.rast map=indici
d.vect map=AO
d.rast map=indici
v.what.rast map=indici
v.what.rast vector=LAMI raster=indici column=VAL
d.rast indici
d.what.rast indici
v.what.rast
d.rast
d.vect
g.region vect=LAMI@PERMANENT res=0.063
d.rast neve
eit
exit
ls
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_I.txt 
./GRASS_WGS84_7Km_I.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_I.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
ls
vi impaginazione.txt 
./impaginazione.txt 
ls
ls -lrt
gwenview impaginata.gif 
vi impaginazione.txt 
./impaginazione.txt 
gwenview impaginata_analisi_20090306.gif 
rm impaginata.gif 
vi impaginazione.txt 
mv impaginazione.txt impaginazione_analisi.txt 
cp impaginazione_analisi.txt impaginazione_previsione.txt
vi impaginazione_previsione.txt 
vi impaginazione_analisi.txt 
mv impaginazione_analisi.txt impaginazione.txt
ls
rm impaginazione_previsione.txt 
vi impaginazione.txt 
./impaginazione.txt 
ls -lrt
rm impaginata_analisi_20090306.gif 
rm impaginata_dir_20090306.gif 
vi impaginazione.txt 
ls impaginazione.txt 
vi impaginazione.txt 
./impaginazione.txt 
vi impaginazione.txt 
./impaginazione.txt 
vi impaginazione.txt 
./impaginazione.txt 
vi impaginazione.txt 
./impaginazione.txt 
vi impaginazione.txt 
mv impaginazione.txt impaginazione_analisi.txt
cp impaginazione_analisi.txt impaginazione_previsione.txt 
vi impaginazione_analisi.txt 
./impaginazione_analisi.txt 
vi impaginazione_analisi.txt 
vi impaginazione_previsione.txt 
./impaginazione_previsione.txt 
vi impaginazione_previsione.txt 
./impaginazione_previsione.txt 
vi impaginazione_previsione.txt 
vi impaginazione_analisi.txt 
vi impaginazione_previsione.txt 
./impaginazione_previsione.txt 
vi impaginazione_previsione.txt 
./impaginazione_previsione.txt 
vi impaginazione_previsione.txt 
exit
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
./GRASS_WGS84_7Km_II.txt 
vi GRASS_WGS84_7Km_II.txt 
exit
g.region vect=LAMI res=0.063
v.in.ascii input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20090307_1.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --overwrite
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --overwrite
r.mask input=AO
r.mapcalculator amap=prova  formula="A" outfile=prova --o
g.remove rast=MASK
d.mon x0
d.rast prova
d.rast indici
d.rast indici_prev1
d.rast indici
d.rast indici_prev1
d.rast indici
ls
exit
./GRASS_WGS84_7Km_II.txt 
exit
g.remove
exit
g.region vect=LAMI@PERMANENT res=0.063
g.remove rast=indici,neve
exit
ls
g.region vect=LAMI@PERMANENT res=0.063
v.what.rast vector=LAMI raster=indici column=VAL
v.out.ogr -c input=LAMI type=point dsn=/home/meteo/programmi/fwi_grid/indici/ana/temp olayer=temporaneo layer=1 format=CSV
cd /home/meteo/programmi/fwi_grid/indici/ana/temp/
ls
vi temporaneo.csv 
exit
ls
rm prova.txt 
ls
exit
g.region -p
g.region -d
g.region -p
d.rast
exit
g.region -p
g.region -d
r.proj input=indici_IDI_neve_bruc location=GB output=indici_IDI_neve_bruc
d.mon x0
d.rast indici_IDI_neve_bruc
d.what.rast indici_IDI_neve_bruc
d.erase
g.region -p
d.rast
exit
d.mon x0
d.rast
exit
g.region vect=LAMI@PERMANENT res=0.063
d.mon x0
d.rast
g.region
g.region vect=LAMI@PERMANENT res=0.0135
d.rast
g.region vect=LAMI@PERMANENT res=0.0135
d.rast indici
d.rast indici_IDI_neve_bruc
d.rast indici
d.rast indici_IDI_neve_bruc
g.region vect=LAMI@PERMANENT res=0.063
d.rast indici_IDI_neve_bruc
g.region vect=LAMI@PERMANENT res=0.063
r.proj input=indici_IDI_neve_bruc location=GB output=indici_IDI_neve_bruc
r.proj input=indici_IDI_neve_bruc location=GB output=indici_IDI_neve_bruc --o
d.rast indici_IDI_neve_bruc
g.region vect=LAMI@PERMANENT res=0.0135
r.proj input=indici_IDI_neve_bruc location=GB output=indici_IDI_neve_bruc --o
d.rast indici_IDI_neve_bruc
exirt
exit
d.mon x0
g.region vect=LAMI@PERMANENT res=0.063
r.proj input=indici_IDI_neve_bruc location=GB output=indici_IDI_neve_bruc --o
d.rast indici_IDI_neve_bruc
g.region vect=LAMI@PERMANENT res=0.0135
r.proj input=indici_IDI_neve_bruc location=GB output=indici_IDI_neve_bruc_bis --o
d.mon x1
d.rast indici_IDI_neve_bruc_bis
r.colors map=indici_IDI_neve_bruc_bis color=fwi_ffmc_03
d.rast indici_IDI_neve_bruc
risoluzione-EO: 1500.000000
risoluzione-NS: 1500.000000
export GRASS_PNGFILE=prova
exit
./conversione_ana_perWEB.txt 
vi conversione_ana_perWEB.txt 
./conversione_ana_perWEB.txt 
vi conversione_ana_perWEB.txt 
exit
cd programmi/fwi_grid/
ls
cd ini
ls
v.in.ascii input=/home/meteo/programmi/fwi_grid/ini/lombardia_CI7.txt output=prova format=point fs=, skip=1 x=5 y=4 z=0 cat=1
d.mon x0
d.rast 
d.vect
v.surf.idw input=prova output=prova npoints=1 layer=1 column=dbl_5
d.rast prova
d.what.rast
d.mon x1
d.rast
d.vect
g.region  vect=LAMI res=0.063
v.proj input=AB location=GB output=AB
exit
g.region vect=LAMI res=0.063
r.proj input=AB location=GB output AB
r.proj input=AB location=GB output=AB
d.mon x1
d.rast AB
d.rast prova
d.mon x0
d.rast AB
exit
v.in.ascii input=/home/meteo/programmi/fwi_grid/ini/pippero_CI7.txt output=prova format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova output=prova npoints=1 layer=1 column=dbl_5
v.surf.idw input=prova output=prova npoints=1 layer=1 column=dbl_5n --o
d.mon x0
d.vect prova 
d.what.vect prova 
v.surf.idw input=prova output=prova npoints=1 layer=1 column=dbl_5 --o
d.rast prova
pwd
cd programmi/grass_work/scripts/
vi  GRASS_WGS84_7Km_II.txt 
vi  GRASS_WGS84_7Km_I.txt 
vi  GRASS_WGS84_7Km_II.txt 
d.rast
grep AB *
vi  GRASS_WGS84_7Km_II.txt 
vi  GRASS_GB_1500m.txt 
vi  GRASS_WGS84_7Km_II.txt 
d.mon x0
vi  GRASS_WGS84_7Km_II.txt 
g.region vect=LAMI res=0.063
v.in.ascii input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20100314_1.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1
v.in.ascii input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20100314_1.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
r.mask input=AO
r.mapcalculator amap=prova formula="A" outfile=prova  --o
g.remove rast=MASK
r.mask input=AB maskcats=1
r.mapcalculator amap=prova  formula="A" outfile=prova --o
g.remove rast=MASK
d.mon x0
r.colors map=prova color=fwi_ffmc_03
d.rast prova
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
v.in.ascii input=/home/meteo/programmi/fwi_grid/indici/prev/ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
r.mask input=AO
r.mapcalculator amap=prova formula="A" outfile=prova  --o
g.remove rast=MASK
r.mask input=AB maskcats=1
r.mapcalculator amap=prova  formula="A" outfile=prova --o
g.remove rast=MASK
r.colors map=prova color=fwi_ffmc_03
d.rast prova
d.vect map=AO type=point,line,boundary,face display=shape icon=basic/x size=8 layer=1                     width=0 wscale=1 color=black fcolor=200:200:200 rgb_column=GRASSRGB llayer=1                lcolor=red bgcolor=none bcolor=none lsize=8 font=romans xref=left yref=center
v.rast.stats -c vector=AO raster=prova  colprefix=FI
v.db.select -c map=AO layer=1 column=cat,FI_mean fs=" " > /home/meteo/programmi/grass_work/scripts/mean_fi.txt
for ((t=1; t<=15; t++)); do dirgrass=/home/meteo/programmi/grass_work/scripts;         head -$t $dirgrass/mean_fi.txt | tail -1 > $dirgrass/b.txt;         read cat mean < $dirgrass/b.txt;         echo "round (${mean})" | bc -l $dirgrass/arrot.b > $dirgrass/fi.txt;         read FI < $dirgrass/fi.txt;         echo "update AO set FI_mean=${FI} where cat=${t}" | db.execute; done
d.mon x1
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=0"                                   color=black fcolor=$colore1 lcolor=black bgcolor=230:230:48 bcolor=red                                lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <=0" color=black fcolor=$colore1 lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 0" color=black fcolor=$colore1 lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= '0'" color=black fcolor=$colore1 lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 1 " color=black fcolor=$colore1 lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 1 " color=black fcolor=green lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= 0.0000001 " color=black fcolor=green lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= -7000 " color=black fcolor=green lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.erase
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= -7000 " color=black fcolor=green lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= -9998 " color=black fcolor=green lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
d.erase
d.vect map=AO type=area display=shape,attr attrcol=FI_mean where="FI_mean <= -9998 " color=black fcolor=green lcolor=black bgcolor=230:230:48 bcolor=red lsize=14 font=romans xref=center yref=center
v.in.ascii
vi mean_fi.txt 
v.in.ascii
exit
g.region vect=LAMI res=0.063
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
d.mon x0
d.vect prova
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.rast prova
d.rast.what prova
d.what.rast prova
vi ffmc_lami_20100314_2.txt 
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
vi ffmc_lami_20100314_2.txt 
cp ../ffmc_lami_20100314_2.txt .
vi ffmc_lami_20100314_2.txt 
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
d.erase
d.vect prova
vi ffmc_lami_20100314_2.txt 
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
d.vect prova
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.rast prova
d.erase
d.rast prova
g.remove prova
d.erase
d.rast prova
vi ffmc_lami_20100314_2.txt 
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.rast prova
d.what.rast prova
g.remove rast=prova
g.remove vect=prova
cp ffmc_lami_20100314_2.txt indice.txt
vi indice.txt 
v.in.ascii input=indice.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 
d.rast prova
d.erase
d.rast prova
d.what.rast prova
v.in.ascii input=indice.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1 null=-9999.0000 --o
v.in.ascii input=indice.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1  --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.mon x0
d.rast prova
d.what.rast prova
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1  --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.rast prova
d.what.rast prova
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1  --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=, skip=1 x=5 y=4 z=0 cat=1  --o
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=| skip=1 x=5 y=4 z=0 cat=1  --o
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=| skip=1 x=5 y=4 z=0 cat=1  -overwrite
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs=| skip=1 x=5 y=4 z=0 cat=1  --overwrite
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova1  format=point fs=| skip=1 x=5 y=4 z=0 cat=1 
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova1  format=point fs="|" skip=1 x=5 y=4 z=0 cat=1 
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova1  format=point fs="|" skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova1  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.rast prova
d.what.rast prova
g.remove rast=prova
g.remove rast=prova1
g.remove vect=prova1
g.remove vect=prova
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs="|" skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.erase
d.rast prova
d.what.rast prova
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs="|" skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs="|" skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.erase
d.rast prova
d.what.rast prova
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs="," skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.erase
d.rast prova
d.what.rast prova
r.null
r.mapcalculator amap=prova formula="A" outfile=prova --o
d.erase
d.rast prova
d.what.rast prova
r.mapcalculator amap=prova formula="if(A=-9999,null(),A)" outfile=prova --o
r.mapcalculator amap=prova formula="if(A='-9999',null(),A)" outfile=prova --o
r.mapcalculator amap=prova formula="if(A=-9999,A,null())" outfile=prova --o
r.mapcalc amap=prova formula="if(A=-9999,A,null())" outfile=prova --o
r.mapcalculator amap=prova formula="if(A=-9999,A,null())" outfile=prova --o
r.mapcalculator amap=prova formula="if(A=-9999,A,0)" outfile=prova --o
r.mapcalculator amap=prova formula="A/1000" outfile=prova --o
r.mapcalculator amap=prova formula="if(A>-800,A,null())" outfile=prova --o
r.mapcalculator amap=prova formula="if(A!=-800,A,null())" outfile=prova --o
v.in.ascii input=ffmc_lami_20100314_2.txt output=prova  format=point fs="," skip=1 x=5 y=4 z=0 cat=1 --o
v.surf.idw input=prova  output=prova  npoints=1 layer=1 column=dbl_5 --o
d.erase
d.rast prova
r.mapcalculator amap=prova formula="if(A!=-9999,A,null())" outfile=prova --o
d.rast prova
d.what.rast prova
exit
d.rast neve
d.rast
d.mon x0
g.remove rast=prova,neve
v.proj input=neve location=GB output=neve 
exit
v.proj input=neve location=GB output=neve 
exit
d.mon x0
d.rast neve
g.region g.region vect=LAMI res=0.063
g.region vect=LAMI res=0.063
v.proj input=neve location=GB output=neve 
r.proj input=neve location=GB output=neve 
d.rast neve
g.region vect=LAMI res=0.063
r.proj input=neve location=GB output=neve --o
d.rast neve
d.mon x0
d.rast neve
g.region vect=LAMI res=0.063
d.rast 
d.mon x0
d.rast 
g.remove rast=neve
g.region vect=LAMI res=0.063
r.proj input=neve location=GB output=neve --o
d.rast 
g.remove rast=neve
d.erase
r.proj input=neve location=GB output=neve --o
d.rast neve
r.proj input=neve location=GB output=neve method=nearest --o
d.rast neve
d.erase
d.rast neve
d.erase
vi GRASS_WGS84_7Km_I.txt 
vi GRASS_WGS84_7Km_I.txt
exit
g.region vect=LAMI@PERMANENT
v.out.ogr -c input=AB  type=point dsn=$temporaneo olayer=temporaneo layer=1 format=CSV
d.vect
d.rast
ls
cd ..
ls
cd ini/
ls
vi lombardia.txt 
vi lombardia_CI7.txt
vi pippero_CI7.txt 
exit
d.rast
vi GRASS_WGS84_7Km_II.
vi GRASS_WGS84_7Km_II.txt 
grep IDI_neve_bruc
grep IDI_neve_bruc *
d.rast
exit
ls
./ConversioneAnalisiInLatLon.txt 
vi ConversioneAnalisiInLatLon.txt 
./ConversioneAnalisiInLatLon.txt 
exit
g.list vect

..out
v.out
v.out.ascii input=LAMI output=/home/meteo/grass_work/prova_lami.txt
exit
d.vect AO
d.mon
d.mon start=x0
d.vect AO
v.out.ascii 
exit
g.list vect
v.out.ascii
v.out.ogr
exit
g.list rast
vi AO
r.out.arc
exit
g.gui
exit
v.in.ascii input=/home/meteo/Scrivania/ur_lami_20110526_2_ctrl.txt output=humi_ctrl fs=, skip=1 x=3 y=4 cat=1
v.surf.idw
v.in.ascii --overwrite input=/home/meteo/Scrivania/ur_lami_20110526_2_ctrl.txt output=humi_ctrl fs=, skip=1 x=5 y=4 cat=1
v.surf.idw
v.surf.idw input=humi_ctrl@PERMANENT output=humi_ctrl column=dbl_5 npoints=1
r.colors map=humi_ctrl@PERMANENT color=scala_colori_ur
g.remove rast=humi_ctrl
g.remove vect=humi_ctrl
g.list vect
g.remove vect=prova
g.list rast
g.remove rast=humiA,humiB
g.region -p
exit
g.list vect
exit
g.gui
y
r.proj
n
exit
g.list vect
exit
G.LIST RAST
g.list rast
exit
r.what --v -f -n input=indici@PERMANENT east_north=9.194133,46.030204
r.what --v -f -n input=indici@PERMANENT east_north=9.593184,46.039378
r.what --v -f -n input=indici@PERMANENT east_north=9.272108,45.695368
r.what --v -f -n input=indici@PERMANENT east_north=9.134504,45.695368
r.what --v -f -n input=indici@PERMANENT east_north=9.171199,45.466028
r.what --v -f -n input=indici@PERMANENT east_north=9.836285,45.310077
r.what --v -f -n input=indici@PERMANENT east_north=10.047278,45.420160
r.what --v -f -n input=indici@PERMANENT east_north=10.061038,45.933882
v.what.rast vector=LAMI raster=indici column=VAL
v.out.ogr
v.out.ogr -c input=LAMI@PERMANENT type=point dsn=/home/meteo/Scrivania/test olayer=temporaneo format=CSV
r.what --v -f -n input=indici@PERMANENT east_north=9.414299,45.947642
r.what --v -f -n input=indici@PERMANENT east_north=9.987649,46.089833
r.what --v -f -n input=indici@PERMANENT east_north=10.079385,46.085246
r.what --v -f -n input=indici@PERMANENT east_north=10.340833,45.819212
r.what --v -f -n input=indici@PERMANENT east_north=10.354593,45.782517
r.what --v -f -n input=indici@PERMANENT east_north=10.450916,45.777930
r.what --v -f -n input=indici@PERMANENT east_north=10.083972,46.085246
r.what --v -f -n input=indici@PERMANENT east_north=9.983062,46.085246
r.what --v -f -n input=indici@PERMANENT east_north=10.042691,46.273305
r.what --v -f -n input=indici@PERMANENT east_north=10.148187,46.268718
r.what --v -f -n input=indici@PERMANENT east_north=10.327072,44.553255
v.what.rast
r.null
r.null map=indici@PERMANENT null=0
v.what.rast vector=LAMI raster=indici column=VAL
r.what --v -f -n input=indici@PERMANENT east_north=10.794926,45.897187
r.what --v -f -n input=indici@PERMANENT east_north=9.799590,44.855984
r.what --v -f -n input=indici@PERMANENT east_north=9.267522,45.071563
r.what --v -f -n input=indici@PERMANENT east_north=8.698758,44.814702
r.what --v -f -n input=indici@PERMANENT east_north=8.551981,45.397226
r.null
r.null map=indici@PERMANENT null=*
r.null map=indici@PERMANENT
r.what --v -f -n input=indici@PERMANENT east_north=8.730866,46.420082
r.what --v -f -n input=indici@PERMANENT east_north=8.538220,46.465951
r.what --v -f -n input=indici@PERMANENT east_north=8.519873,44.764247
r.what --v -f -n input=indici@PERMANENT east_north=10.015170,44.690859
r.null
v.what.rast vector=LAMI raster=indici column=VAL
v.out.ogr
v.out.ogr -c input=LAMI@PERMANENT type=point dsn=/home/meteo/Scrivania/test2 olayer=temporaneo format=CSV
g.list rast
d.rast map=indici
d.mon start=PNG
d.rast map=indici
d.mon stop=PNG
g.gui
exit
v.out.ogr
r.proj input=indici_IDI_neve_bruc location=GB output=indici method=nearest
v.out.ogr
v.out.ogr -c input=LAMI@PERMANENT type=point dsn=/home/meteo/Scrivania/ olayer=temporaneo format=CSV
v.out.ogr -c input=LAMI@PERMANENT type=point dsn=/home/meteo/Scrivania/temporaneo olayer=temporaneo format=CSV
v.out.ogr -c input=LAMI@PERMANENT type=point dsn=/home/meteo/Scrivania/temporaneo olayer=temporaneo format=CSV
v.out.ogr
v.out.ogr -c input=LAMI@PERMANENT type=point dsn=/home/meteo/Scrivania/pippo/test olayer=temporaneo format=CSV
v.out.ogr -c input=LAMI@PERMANENT type=point dsn=/home/meteo/Scrivania/pippo/test olayer=temporaneo format=CSV
g.gui
exit
v.proj
v.proj input=aree_ic location=GB mapset=PERMANENT output=aree_ic
v.to.rast
v.to.rast input=aree_ic@PERMANENT type=area output=aree_ic use=attr column=cat
g.gui
exit
g.region -p
g.region vect=aree_ic res=0.125
g.region -p
g.gui
exit
g.list vect
v.out.ascii
v.out.ascii input=LAMI@PERMANENT output=/home/meteo/Scrivania/test.txt fs=, columns=cat,VAL
g.gui
pwd
cd programmi/grass_work
ls
cd scripts
ls
clear
ls
./GRASS_WGS84_7Km_I.sh
exit
./GRASS_WGS84_7Km_I.sh
cd /programmi/grass_work/scripts/GRASS_WGS84_7Km_I.sh
cd /programmi/grass_work/scripts/
cd programmi/grass_work/scripts/
./GRASS_WGS84_7Km_I.sh
exit
g.region vect=LAMI@PERMANENT res=0.063
exit
g.region
g.region -l
g.region -d
g.region -l
g.region vect=LAMI@PERMANENT res=0.063
g.region -p
exit
g.list vect
g.gui wxpython
v.build.all 
exit
