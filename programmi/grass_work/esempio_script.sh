#!/bin/bash


# da personalizzare in fase di lancio
export DIR_GRASS=/home/roberto/conversione_GRASS/GRASS7/grass_work

###################################################
# da decommentare qua
#export dataieri=$(date --date=yesterday +"%Y%m%d") && echo $dataieri
export dataieri=20200607


#DIR_BASE=/home/meteo/programmi/fwi_grid

export DIR_BASE=/home/roberto/conversione_GRASS



echo "GRASS_GB_METEO inizio ========================================================================="
 ./batch-grass7.sh GB AIB -file $DIR_GRASS/scripts7/GRASS_GB_METEO_dmod.txt $dataieri $DIR_BASE $DIR_GRASS
echo "GRASS_GB_METEO fine ==========================================================================="


for nomeindice in ffmc dmc dc isi bui fwi
	do
		export nomeindice=$nomeindice
###     B2) GRASS in GB risoluzione 1500m

                echo "GRASS_GB_1500m inizio ========================================================================="
               ./batch-grass7.sh GB AIB -file $DIR_GRASS/scripts7/GRASS_GB_1500m_rgmod.txt $DIR_BASE $DIR_GRASS
		if [ "$?" -ne 0 ]
		then
			echo "codice errore di grass63 in GB"
		exit 1
		fi 
                echo "GRASS_GB_1500m fine ========================================================================="

###     per utilizzo cosmo-i7
 
 
 
 
 # da decommentare
 #       	case $nomeindice in ffmc|dmc|dc)
        	
        	
        	
        	
###     C) GRASS in WGS84 risoluzione 7Km
#                     grass63 -text $DIR_GRASS/WGS84/PERMANENT <  $DIR_GRASS/scripts/GRASS_WGS84_7Km_I.txt


# da decommentare
#                        echo "GRASS_WGS84_7Km_I inizio ========================================================================="
#                        /home/meteo/script/fwi/batch-grass6.sh WGS84 AIB -file $DIR_GRASS/scripts/GRASS_WGS84_7Km_I.txt
#			if [ "$?" -ne 0 ]
#			then
#				echo "codice errore di grass63 in WGS84"
#				exit 1
#			fi
#                        echo "GRASS_WGS84_7Km_I fine ========================================================================="
#                	;;
#        	esac

#                echo "ConversioneAnalisiinLatLon.txt inizio ========================================================================"
#                /home/meteo/script/fwi/batch-grass6.sh WGS84 PERMANENT -file $DIR_GRASS/scripts/ConversioneAnalisiInLatLon.txt 
#                echo "ConversioneAnalisiinLatLon.txt fine ========================================================================="

	done
#echo "ok" >$end_grass.$dataoggi