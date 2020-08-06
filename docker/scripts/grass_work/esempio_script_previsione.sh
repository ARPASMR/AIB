#!/bin/bash


# da personalizzare in fase di lancio
export DIR_BASE=/home/roberto/conversione_GRASS
export DIR_GRASS=$DIR_BASE/GRASS7/grass_work

###################################################
# da decommentare qua
#export dataieri=$(date --date=yesterday +"%Y%m%d") && echo $dataieri
export dataoggi=20200608
export datadomani=20200609

#DIR_BASE=/home/meteo/programmi/fwi_grid






for nomeindice in ffmc dmc dc isi bui fwi
	    do
                export nomeindice=$nomeindice
###	E) GRASS in WGS84 risoluzione 7Km
                echo "GRASS_WGS84_7Km_II inizio ========================================================================================"
                ./batch-grass7.sh WGS84 AIB -file $DIR_GRASS/scripts7/GRASS_WGS84_7Km_II.txt  $dataoggi $datadomani  $DIR_BASE $DIR_GRASS
                echo "GRASS_WGS84_7Km_II fine ========================================================================================="
                echo "ConversionePrevisioneInGB.txt inizio ========================================================================"
                ./batch-grass7.sh GB AIB -file $DIR_GRASS/scripts7/ConversionePrevisioneInGB_dmod.txt  $dataieri $DIR_BASE $DIR_GRASS
                echo "ConversionePrevisioneInGB.txt  fine ========================================================================="
	    done

                echo "GRASS_WGS84_METEO_I inizio ========================================================================="
                ./batch-grass7.sh WGS84 AIB -file $DIR_GRASS/scripts7/GRASS_WGS84_METEO_I_dmod.txt  $dataoggi $DIR_BASE $DIR_GRASS
                echo "GRASS_WGS84_METEO_I fine ==========================================================================="
                echo "GRASS_WGS84_METEO_II inizio ========================================================================"
                ./batch-grass7.sh GB AIB -file $DIR_GRASS/scripts7/GRASS_WGS84_METEO_II_dmod.txt  $dataoggi $DIR_BASE $DIR_GRASS
                echo "GRASS_WGS84_METEO_II  fine ========================================================================="