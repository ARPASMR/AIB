#!/bin/bash


# usato su PC Roberto
export DIR_GRASS=/home/roberto/conversione_GRASS/GRASS7/grass_work

###################################################
# da decommentare qua
#export dataieri=$(date --date=yesterday +"%Y%m%d") && echo $dataieri
export dataieri=20200607


#DIR_BASE=/home/meteo/programmi/fwi_grid

export DIR_BASE=/home/roberto/conversione_GRASS



 echo "GRASS_GB_METEO inizio ========================================================================="
 ./batch-grass7.sh GB PERMANENT -file $DIR_GRASS/scripts7/GRASS_GB_METEO_dmod.txt $dataieri $DIR_BASE $DIR_GRASS
   echo "GRASS_GB_METEO fine ==========================================================================="