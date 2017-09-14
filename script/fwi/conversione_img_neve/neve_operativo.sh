#!/bin/bash

DIR_GRASS=/home/meteo/programmi/grass_work/


echo "conversione copertura nevosa"

DIR=/home/meteo/programmi/fwi_grid/modis_neve
for FILE in $DIR/*.img
do 
  export fileneve=$FILE
  FILEOUT=`echo $FILE | awk -F "." '{print $(NF-1)};'`.txt
  export fileoutneve=$FILEOUT
  echo " passaggio da "$FILE" >> a >> "$FILEOUT
#  grass -text $DIR_GRASS/GB/PERMANENT <  $DIR_GRASS/scripts/ConversioneCoperturaNevosa_mod.txt
  /home/meteo/script/fwi/batch-grass6.sh GB PERMANENT -file $DIR_GRASS/scripts/ConversioneCoperturaNevosa_mod.txt
done
exit 0

