#!/bin/bash

###	definizioni

## modificare percorsi inserendo: DIR_BASE, FWIGRID, GRASS_WORK
#HOME=/home/meteo
#DIR_INI=/home/meteo/programmi/fwi_grid/ini
#DIR_ANA=/home/meteo/programmi/fwi_grid/meteo/ana
#DIR_PREVI=/home/meteo/programmi/fwi_grid/meteo/prev
#DIR_NEVE_IMG=/home/meteo/programmi/fwi_grid/immagini/meteo/neve
#DIR_IMG_PNG=/home/meteo/programmi/fwi_grid/immagini/png
#DIR_ANA_IMG=/home/meteo/programmi/fwi_grid/immagini/ana
#DIR_PREV_IMG=/home/meteo/programmi/fwi_grid/immagini/prev
#DIR_ANAME_IMG=/home/meteo/programmi/fwi_grid/immagini/meteo/ana/archivio
#DIR_PREVME_IMG=/home/meteo/programmi/fwi_grid/immagini/meteo/prev/archivio
#DIR_ANAMET_IMP=/home/meteo/programmi/fwi_grid/immagini/meteo/ana
#DIR_FORMET_IMP=/home/meteo/programmi/fwi_grid/immagini/meteo/prev
#DIR_NONFWI_IMG=/home/meteo/programmi/non_fwi_grid/immagini/ana
#SPEDIZIONI=$HOME/programmi/fwi_grid/spedizioni
#DIR_VUOTI=$HOME/programmi/fwi_grid/modelli_vuoti
#DIR_GRASS=/home/meteo/programmi/grass_work

## ambiente
DIR_BASE=/fwi
DIR_DATA=$DIR_BASE/data
DIR_IMG=$DIR_DATA/immagini
DIR_SCRIPTS=$DIR_BASE/scripts
DIR_BIN=/$DIR_BASE/bin

## path fwi
DIR_INI=$DIR_DATA/ini
DIR_ANA=$DIR_DATA/meteo/ana
DIR_PREVI=$DIR_DATA/meteo/prev
DIR_NEVE=$DIR_DATA/modis_neve
DIR_NEVE_IMG=$DIR_IMG/meteo/neve
## DIR_IMG_PNG sembra non sia usata in questo script
DIR_IMG_PNG=$DIR_IMG/pmg
DIR_ANA_IMG=$DIR_IMG/ana
DIR_PREV_IMG=$DIR_IMG/prev
DIR_ANAME_IMG=$DIR_IMG/meteo/ana/archivio
DIR_PREVME_IMG=$DIR_IMG/meteo/prev/archivio
DIR_ANAMET_IMP=$DIR_IMG/meteo/ana
DIR_FORMET_IMP=$DIR_IMG/meteo/prev
DIR_NONFWI_IMG=$DIR_IMG
DIR_SPEDIZIONI=$DIR_DATA/spedizioni
DIR_VUOTI=$DIR_DATA/modelli_vuoti
DIR_GRASS=$DIR_SCRIPTS/grass_work
GRASS_SCRIPTS=$DIR_GRASS/scripts7

BATCH_GRASS=$DIR_GRASS/batch-grass7.sh

## fwigrid_ana fortran binary
FWIGRID_ANA=$DIR_BIN/fwigrid_ana
FWIGRID_FOR=$DIR_BIN/fwigrid_for


# Analisi su Ghost Virtuale
WEBSERVER_V_ANA=/var/www/html/prodottimeteo/analisi/fwi
WEBSERVER_V_ANAME=/var/www/html/prodottimeteo/analisi/fwi_meteo
WEBSERVER_V_NONFWI=/var/www/html/prodottimeteo/analisi/non_fwi
# Previsione su Ghost virtuale
WEBSERVER_V_FORE=/var/www/html/prodottimeteo/forecast/fwi
WEBSERVER_V_FOREME=/var/www/html/prodottimeteo/forecast/fwi_meteo
control=$DIR_PREVI/fwi_controllo.data
datafor=$DIR_INI/data_for.ini
end_isaia=$HOME/tmp/end_isaia
end_grass=$HOME/tmp/end_grass
end_forecast=$HOME/tmp/end_forecast
underscore="_"
ll="LL"

## parte di pubblicazione resta uguale, in attesa di modifiche apportate in GESTISCO per passaggio da ghost2 a ghost3

SMBCLIENT=/usr/bin/smbclient
WEBESTIP=172.16.1.6
#WEBESTIP=172.16.1.2
WEBESTDIR=meteo
WEBESTDIR1=bollettini/img_aib
WEBESTDIR2=mappe/fwi_img
WEBESTDIR3=mappe/xml
#WEBESTUSR=administrator
#WEBESTPWD=siemens
WEBESTUSR=meteo_img
WEBESTPWD=meteo
WEBESTWKG=ARPA



#++++++++++++++++++++++++++++++++++++++++++++++++++ DEBUG non facciamo analisi
#if false; then


####################
# functions
####################

function neve_operativo {
  echo "conversione copertura nevosa"

  for FILE in $DIR_NEVE/*.img
  do 
    ##export fileneve=$FILE
    FILEOUT=`echo $FILE | awk -F "." '{print $(NF-1)};'`.txt
    ##export fileoutneve=$FILEOUT
    echo " passaggio da $FILE  a $FILEOUT "
    #  grass -text $DIR_GRASS/GB/PERMANENT <  $DIR_GRASS/scripts/ConversioneCoperturaNevosa_mod.txt
    ## $DIR_GRASS/batch-grass7.sh GB PERMANENT -file $DIR_GRASS/scripts/ConversioneCoperturaNevosa_mod.txt

    gdal_translate -of "AAIgrid" $FILE $FILEOUT

  done
}

#++++++++++++++++++++++++++++++++++++++++++++++++++ DEBUG non facciamo analisi
#if false; then



# applicativo memorizzazione database
# non utilizzato
# FWIDBMGR=$HOME/dev/redist/fwidbmgr/fwidbmgr

#count=/tmp/fwi_count
#end_grassWGS84=$HOME/tmp/end_grassWGS84.txt
#
export dataaltroieri=$(date --date='2 day ago' +"%Y%m%d") && echo "dataaltroieri: " $dataaltroieri
export dataieri=$(date --date=yesterday +"%Y%m%d") && echo "dataieri: " $dataieri
export dataoggi=$(date +"%Y%m%d") && echo "dataoggi: " $dataoggi
export datadomani=$(date --date=tomorrow +"%Y%m%d") && echo "datadomani: " $datadomani

logger - is -p user.notice "Script per il calcolo di FWI iniziato $dataoggi" -t "PREVISORE"




#++++++++++++++++++++++++++++++++++++++++++++++++++ DEBUG non facciamo analisi
if false; then


## Inizializza immagini su web-server
if [ ! -s $end_grass.$dataoggi ]
then 
$SMBCLIENT //$WEBESTIP/$WEBESTDIR -U $WEBESTUSR%$WEBESTPWD <<End-of-smbclient0
prompt
cd $WEBESTDIR1
lcd $DIR_VUOTI
mput *ieri*
End-of-smbclient0
fi

if [ ! -s $end_forecast.$dataoggi ]
then 
$SMBCLIENT //$WEBESTIP/$WEBESTDIR -U $WEBESTUSR%$WEBESTPWD <<End-of-smbclient1
prompt
cd $WEBESTDIR1
lcd $DIR_VUOTI
mput *oggi*
mput *domani*
End-of-smbclient1
fi

###########  creazione file di neve per analisi di ieri

## se Bellingeri resta autonomo (dipende da UOICT) direttamente copia lui nell'area NFS o dove decideremo, altrimenti...soluzione altrenativa

## accorpare cobcversione_neve in un unico script e fare ordine unitamente alla parte qui sotto di trattamento immagine satelliatere (oppure inserire qui piccoli script)


if [ ! -s $end_isaia.$dataoggi ] 
then

# controlla la cartella /home/meteo/programmi/fwi_grid/modis_neve
  #### DIR_NEVE=/home/meteo/programmi/fwi_grid/modis_neve/
  NUMFILES_NEVE=`ls -1 $DIR_NEVE* | wc -l`
  if [ "$NUMFILES_NEVE" -gt 0 ]; then
#se la directory $DIR_NEVE non e' vuota allora ...
    if [ "$NUMFILES_NEVE" -gt 1 ]
    then
  #se la directory $DIR_NEVE contiene piu' di 1 file allora ...
      echo "ERRORE: directory $DIR_NEVE contiene piu' di 1 file"
      logger - is -p user.crit "ERRORE: directory $DIR_NEVE contiene piu' di 1 file" -t "PREVISORE"
      exit 1
    else
  #...altrimenti la directory $DIR_NEVE contiene esattamente 1 file
      echo "directory $DIR_NEVE contiene 1 solo file"
      logger - is -p user.notice "directory $DIR_NEVE contiene 1 solo file" -t "PREVISORE"
    # il seguente ciclo FOR verra' ripetuto una sola volta: e' tanto per leggere il 
    #  nome dell'unico file (.img) che so essere in DIR_NEVE e ricavare la data alla quale
    # il file si riferisce (DATA_NEVE)
      for FILE in $DIR_NEVE*
      do
        echo $FILE
        DATA_NEVE=`echo $FILE | awk -F _ '{ print $NF }' | awk -F . '{ print $1 }'`
      done
      echo $DATA_NEVE
      if [ "$DATA_NEVE" == "$dataieri"  ]; then
      # se DATA_NEVE coincide con la data di IERI allora chiamo lo script per la Conversione Neve
      #  e sposto i files creati in /home/meteo/programmi/fwi_grid/meteo/ana 
             ##/home/meteo/script/fwi/conversione_img_neve/neve_operativo.sh
             neve_operativo
	     if [ "$?" -ne 0 ]
	     then
      	        echo "codice errore di neve_operativo"
		exit 1
	     fi 
             mv -f $DIR_NEVE/neve_$dataieri.txt $DIR_ANA/
             mv -f $DIR_NEVE/neve_$dataieri.img $DIR_ANA/
      else
      # ...altrimenti DATA_NEVE non coincide con la data di ieri
      echo "ERRORE: la directory $DIR_NEVE contiene 1 file con la data diversa da quella di ieri"
      exit 1
      fi
    fi
  else
# ...altrimenti la directory $DIR_NEVE e' vuota
      echo "directory $DIR_NEVE e' vuota"
      echo "prendo il file neve dell'altro ieri e lo copio con data di ieri"
    # prende i file neve_dataaltroieri.txt e neve_dataaltroieri.img in /home/meteo/programmi/fwi_grid/meteo/ana e li copia con la data di ieri 
      cp -f $DIR_ANA/neve_$dataaltroieri.txt $DIR_ANA/neve_$dataieri.txt
      cp -f $DIR_ANA/neve_$dataaltroieri.img $DIR_ANA/neve_$dataieri.img
  fi
fi

###	eseguo analisi, a prescindere

###	  A)  Script OI per interpolazione dati meteo + calcolo analisi FWI
if [ ! -s $end_isaia.$dataoggi ] 
then

## al posto di oi_fwi lanciare fwigrid_ana, con input meteo già disponibile in directory opportuna
## prima verifico che ci siano i file di input meteo (attualmente su mediano), se ok fwigrid_ana prende la data da riga di comando, altrimenti stop

	$HOME/script/interpolazione/oi_fwi.sh -s $dataaltroieri"1300" -e $dataieri"1200"
	if [ $? == 1 ] 
	then
		echo "codice errore di oi_fwi.sh"
		echo "vedere file di log -> /home/meteo/programmi/fwi_grid/fwigrid.log "
		exit 1
	else
		echo "ok" >$end_isaia.$dataoggi
	fi 
fi

if [ ! -s $end_grass.$dataoggi ]
then 
###     B1) GRASS meteo ANALISI

## mantenere struttura, macambiare grass7 e PERMANENT, ecc...inserire variabili d'ambiente

                echo "GRASS_GB_METEO inizio ========================================================================="
                $BATCH_GRASS GB AIB -file $GRASS_SCRIPTS/GRASS_GB_METEO_dmod.txt
                echo "GRASS_GB_METEO fine ==========================================================================="

	for nomeindice in ffmc dmc dc isi bui fwi
	do
		export nomeindice=$nomeindice
###     B2) GRASS in GB risoluzione 1500m
#               grass63 -text $DIR_GRASS/GB/PERMANENT <  $DIR_GRASS/scripts/GRASS_GB_1500m.txt
                echo "GRASS_GB_1500m inizio ========================================================================="
                ##/home/meteo/script/fwi/batch-grass6.sh GB PERMANENT -file $DIR_GRASS/scripts/GRASS_GB_1500m_rgmod.txt
                $BATCH_GRASS GB AIB -file $GRASS_SCRIPTS/GRASS_GB_1500m_rgmod.txt
		if [ "$?" -ne 0 ]
		then
			echo "codice errore di grass63 in GB"
		exit 1
		fi 
                echo "GRASS_GB_1500m fine ========================================================================="

###     per utilizzo cosmo-i7
        	case $nomeindice in ffmc|dmc|dc)
###     C) GRASS in WGS84 risoluzione 7Km
#                       grass63 -text $DIR_GRASS/WGS84/PERMANENT <  $DIR_GRASS/scripts/GRASS_WGS84_7Km_I.txt
                        echo "GRASS_WGS84_7Km_I inizio ========================================================================="
                        ##/home/meteo/script/fwi/batch-grass6.sh WGS84 PERMANENT -file $DIR_GRASS/scripts/GRASS_WGS84_7Km_I.txt
                        $BATCH_GRASS WGS84 AIB -file $GRASS_SCRIPTS/GRASS_WGS84_7Km_I.txt
			if [ "$?" -ne 0 ]
			then
				echo "codice errore di grass63 in WGS84"
				exit 1
			fi
                        echo "GRASS_WGS84_7Km_I fine ========================================================================="
                	;;
        	esac

                echo "ConversioneAnalisiinLatLon.txt inizio ========================================================================"
                ##/home/meteo/script/fwi/batch-grass6.sh WGS84 PERMANENT -file $DIR_GRASS/scripts/ConversioneAnalisiInLatLon.txt 
                $BATCH_GRASS WGS84 AIB -file $GRASS_SCRIPTS/ConversioneAnalisiInLatLon.txt
                echo "ConversioneAnalisiinLatLon.txt fine ========================================================================="

	done

echo "ok" >$end_grass.$dataoggi

#----------------------------------
# [10] memorizzazione db indici
#----------------------------------

### da commentare
# 
# echo `date +%Y-%m-%d" "%H:%M`" Memorizzazione db indici giorno: "$FWIDBDATE" FWIDBMGR_HOME="$FWIDBMGR_HOME
# $FWIDBMGR -a out -d $dataieri
# echo `date +%Y-%m-%d" "%H:%M`" DONE."

### da commentare (tenendo conto che per il calcolo utilizza i dati meteo in db)
# 
#----------------------------------
# [11] calcolo nuovi indici
#----------------------------------
# echo `date +%Y-%m-%d" "%H:%M`" Calcolo nuovi indici giorno: "$FWIDBDATE" FWIDBMGR_HOME="$FWIDBMGR_HOME
# $FWIDBMGR -a computeidx -d $dataieri
# echo `date +%Y-%m-%d" "%H:%M`" DONE."

## da commentare o togliere

#----------------------------------
# [12] export nuovi indici
#----------------------------------
# echo `date +%Y-%m-%d" "%H:%M`" Export nuovi indici giorno: "$FWIDBDATE" FWIDBMGR_HOME="$FWIDBMGR_HOME
# $FWIDBMGR -a exportidx -d $dataieri
# echo `date +%Y-%m-%d" "%H:%M`" DONE."

## da commentare o togliere (da aggiornare su Grass7)

###     GRASS FMI ANALISI
                echo "GRASS_GB_METEO inizio ========================================================================="
                ##/home/meteo/script/fwi/batch-grass6.sh GB PERMANENT -file $DIR_GRASS/scripts/GRASS_GB_FMI.txt
                $BATCH_GRASS GB AIB -file $GRASS_SCRIPTS/GRASS_GB_FMI.txt
                echo "GRASS_GB_METEO fine ==========================================================================="


## da mantenere tale e quale fino a ****

###	conversione file in formato gif ANALISI -> creazione impaginata

convert \( $DIR_NEVE_IMG/neve_$dataieri.gif $DIR_ANA_IMG/IDI_comune_$dataieri.gif +append \) \
        \( $DIR_ANA_IMG/ffmc_legenda_$dataieri.gif $DIR_ANA_IMG/ffmc_mask_$dataieri.gif +append \) \
        \( $DIR_ANA_IMG/dmc_legenda_$dataieri.gif $DIR_ANA_IMG/dmc_mask_$dataieri.gif +append \) \
        \( $DIR_ANA_IMG/dc_legenda_$dataieri.gif $DIR_ANA_IMG/dc_mask_$dataieri.gif +append \) \
        \( $DIR_ANA_IMG/isi_legenda_$dataieri.gif $DIR_ANA_IMG/isi_mask_$dataieri.gif +append \) \
        \( $DIR_ANA_IMG/bui_legenda_$dataieri.gif $DIR_ANA_IMG/bui_mask_$dataieri.gif +append \) \
        \( $DIR_ANA_IMG/fwi_legenda_$dataieri.gif $DIR_ANA_IMG/fwi_mask_$dataieri.gif +append \) \
        \( -size 100x200 xc:none +append \) \
        -background none -append $DIR_ANA_IMG/impaginata_$dataieri.gif

###     Impaginata meteo ANALISI

convert \( $DIR_ANAME_IMG/t_$dataieri.gif $DIR_ANAME_IMG/ur_$dataieri.gif +append \) \
	\( $DIR_ANAME_IMG/ws_$dataieri.gif $DIR_ANAME_IMG/prec24_$dataieri.gif +append \) \
	\( -size 100x200 xc:none +append \) \
	-background none -append $DIR_ANAMET_IMP/impaginatameteo_$dataieri.gif
convert $DIR_ANAMET_IMP/impaginatameteo_$dataieri.gif -crop 1600x1200 +repage $DIR_ANAMET_IMP/impaginatameteo_$dataieri.gif

###	Impaginata NONFWI ANALISI

convert \( $DIR_NONFWI_IMG/archivio/angstrom_legenda_$dataieri.gif $DIR_NONFWI_IMG/archivio/angstrom_mask_$dataieri.gif +append \) \
        \( $DIR_NONFWI_IMG/archivio/fmi_legenda_$dataieri.gif $DIR_NONFWI_IMG/archivio/fmi_mask_$dataieri.gif +append \) \
        \( $DIR_NONFWI_IMG/archivio/sharples_legenda_$dataieri.gif $DIR_NONFWI_IMG/archivio/sharples_mask_$dataieri.gif +append \) \
        \( -size 100x200 xc:none +append \) \
        -background none -append $DIR_NONFWI_IMG/impaginata_NONFWI_$dataieri.gif

###	copio ANALISI impaginata su Ghost Virtuale
scp $DIR_ANA_IMG/impaginata_$dataieri.gif meteo@10.10.0.14:$WEBSERVER_V_ANA
scp $DIR_ANAMET_IMP/impaginatameteo_$dataieri.gif meteo@10.10.0.14:$WEBSERVER_V_ANAME/
scp $DIR_NONFWI_IMG/impaginata_NONFWI_$dataieri.gif meteo@10.10.0.14:$WEBSERVER_V_NONFWI/

# copio analisi su WEB-SERVER ARPA 172.16.1.6/ecc
# A) copia delle mappe con aggregazione su Aree 
rm -f $DIR_SPEDIZIONI/*
cp $DIR_ANA_IMG/*_legenda_$dataieri.gif $DIR_SPEDIZIONI/
rename.ul legenda_$dataieri ieri $DIR_SPEDIZIONI/*.gif
$SMBCLIENT //$WEBESTIP/$WEBESTDIR -U $WEBESTUSR%$WEBESTPWD <<End-of-smbclient2
prompt
cd $WEBESTDIR1
lcd $DIR_SPEDIZIONI
mput *
End-of-smbclient2
#
# B) copia delle mappe originali mascherate con neve\idi\aree non bruciabili per GoogleMaps (e in più mappe aggregate per thumbnails)
rm $DIR_SPEDIZIONI/*.*
cp $DIR_ANA_IMG/*_mask_$dataieri.png $DIR_SPEDIZIONI/
cp $DIR_ANA_IMG/*_AO_$dataieri.png $DIR_SPEDIZIONI/
cp $DIR_ANA_IMG/*_$dataieri$underscore$ll.png $DIR_SPEDIZIONI/
cp $DIR_ANA_IMG/*_AO_$dataieri$underscore$ll.png $DIR_SPEDIZIONI/
rename.ul $dataieri$underscore$ll ieri $DIR_SPEDIZIONI/*.png
rename.ul AO_$dataieri$underscore$ll A0_ieri $DIR_SPEDIZIONI/*.png
$SMBCLIENT //$WEBESTIP/$WEBESTDIR -U $WEBESTUSR%$WEBESTPWD <<End-of-smbclient3
prompt
cd $WEBESTDIR2
lcd $DIR_SPEDIZIONI
mput *
End-of-smbclient3

fi

## ****

## da commentare
# 
#----------------------------------
# [13] memorizzazione db immagini
#----------------------------------
# echo `date +%Y-%m-%d" "%H:%M`" Memorizzazione db immagini giorno: "$FWIDBDATE
# $FWIDBMGR -a outimg -d $dataieri
# echo `date +%Y-%m-%d" "%H:%M`" DONE."

###	fine esecuzione analisi

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++  DEBUG  per non fare analisi
fi



###	eseguo forecast, triggerato da file control
datacontrologgi=`cat $control|cut -d' ' -f1` && echo "control: " $control 
echo "datacontrologgi: " $datacontrologgi
datacontrolieri=$(date +%Y%m%d --date "$dataoggi -24 hour") && echo "datacontrolieri: " $datacontrolieri
datacontroldomani=$(date +%Y%m%d --date "$dataoggi +24 hour") && echo "datacontroldomani: " $datacontroldomani

### controllo se la parte di forecast oggi e' gia' stata eseguita
if [ -s $end_forecast.$dataoggi ]
then 
      echo "Forecast gia' eseguita precedentemente. Esco"
      exit 0
fi

###	controllo se esiste file control di oggi
if [ ! -s $control ]
then
	echo "non esiste ancora file $control in data $(date)"
	exit
else
      if [ "$datacontrologgi" == "$dataoggi" ]
      then
###	D) FORTRAN PREVISIONE
            echo $dataieri"  "$dataoggi"  "$datadomani > $datafor
            #/home/meteo/programmi/fwi_grid/fwigrid_for_1.4ù
            #+++++++++++++++++++++++++++++++++++++++++ DEBUG
            #$FWIGRID_FOR

	    if [ "$?" -ne 0 ]
	    then
	        echo "codice errore di fwigrid_for"
	        exit 1
	    fi 

	    for nomeindice in ffmc dmc dc isi bui fwi
	    do
                export nomeindice=$nomeindice
###	E) GRASS in WGS84 risoluzione 7Km
#	        grass63 -text $DIR_GRASS/WGS84/PERMANENT < $DIR_GRASS/scripts/GRASS_WGS84_7Km_II.txt
                echo "GRASS_WGS84_7Km_II inizio ========================================================================="
                ##/home/meteo/script/fwi/batch-grass6.sh WGS84 PERMANENT -file $DIR_GRASS/scripts/GRASS_WGS84_7Km_II.txt 
                $BATCH_GRASS WGS84 AIB -file $GRASS_SCRIPTS/GRASS_WGS84_7Km_II.txt
                echo "GRASS_WGS84_7Km_II fine ========================================================================="
                echo "ConversionePrevisioneInGB.txt inizio ========================================================================"
                ##/home/meteo/script/fwi/batch-grass6.sh GB PERMANENT -file $DIR_GRASS/scripts/ConversionePrevisioneInGB_dmod.txt 
                $BATCH_GRASS GB AIB -file $GRASS_SCRIPTS/ConversionePrevisioneInGB_dmod.txt
                echo "ConversionePrevisioneInGB.txt  fine ========================================================================="
	    done

                echo "GRASS_WGS84_METEO_I inizio ========================================================================="
                ##/home/meteo/script/fwi/batch-grass6.sh WGS84 PERMANENT -file $DIR_GRASS/scripts/GRASS_WGS84_METEO_I_dmod.txt 
                $BATCH_GRASS WGS84 AIB -file $GRASS_SCRIPTS/GRASS_WGS84_METEO_I_dmod.txt
                echo "GRASS_WGS84_METEO_I fine ==========================================================================="
                echo "GRASS_WGS84_METEO_II inizio ========================================================================"
                ##/home/meteo/script/fwi/batch-grass6.sh GB PERMANENT -file $DIR_GRASS/scripts/GRASS_WGS84_METEO_II_dmod.txt 
                $BATCH_GRASS GB AIB -file $GRASS_SCRIPTS/GRASS_WGS84_METEO_II_dmod.txt
                echo "GRASS_WGS84_METEO_II  fine ========================================================================="

###	F) CREO file per compilazione "Vigilanza AIB"	
            #********************************************  verificare il sorgente di creaxvigaib ***************************
            #/home/meteo/programmi/fwi_grid/creaxvigaib_2.1
	    if [ "$?" -ne 0 ]
	    then
		echo "codice errore di creaxvigaib"
	    exit 1
	    fi 


###	conversione file in formato gif FORECAST -> creazione impaginata

            numero=1

    convert \( $DIR_PREV_IMG/ffmc_AO_$dataoggi$underscore$numero.gif $DIR_PREV_IMG/ffmc_$dataoggi$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/dmc_AO_$dataoggi$underscore$numero.gif $DIR_PREV_IMG/dmc_$dataoggi$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/dc_AO_$dataoggi$underscore$numero.gif $DIR_PREV_IMG/dc_$dataoggi$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/isi_AO_$dataoggi$underscore$numero.gif $DIR_PREV_IMG/isi_$dataoggi$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/bui_AO_$dataoggi$underscore$numero.gif $DIR_PREV_IMG/bui_$dataoggi$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/fwi_AO_$dataoggi$underscore$numero.gif $DIR_PREV_IMG/fwi_$dataoggi$underscore$numero.gif +append \) \
            \( -size 100x200 xc:none +append \) \
            -background none -append $DIR_PREV_IMG/impaginata_$dataoggi$underscore"1".gif

###     impagino mappe meteo oggi in previsione
    convert \( $DIR_PREVME_IMG/t_lami_$dataoggi$underscore$numero.gif $DIR_PREVME_IMG/ur_lami_$dataoggi$underscore$numero.gif +append \) \
	    \( $DIR_PREVME_IMG/ws_lami_$dataoggi$underscore$numero.gif $DIR_PREVME_IMG/prec24_lami_$dataoggi$underscore$numero.gif +append \) \
	    \( -size 100x200 xc:none +append \) \
	    -background none -append $DIR_FORMET_IMP/impaginatameteo_$dataoggi$underscore"1".gif
    convert $DIR_FORMET_IMP/impaginatameteo_$dataoggi$underscore"1".gif -crop 1600x1200 +repage $DIR_FORMET_IMP/impaginatameteo_$dataoggi$underscore"1".gif

            numero=2
    convert \( $DIR_PREV_IMG/ffmc_AO_$datadomani$underscore$numero.gif $DIR_PREV_IMG/ffmc_$datadomani$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/dmc_AO_$datadomani$underscore$numero.gif $DIR_PREV_IMG/dmc_$datadomani$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/dc_AO_$datadomani$underscore$numero.gif $DIR_PREV_IMG/dc_$datadomani$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/isi_AO_$datadomani$underscore$numero.gif $DIR_PREV_IMG/isi_$datadomani$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/bui_AO_$datadomani$underscore$numero.gif $DIR_PREV_IMG/bui_$datadomani$underscore$numero.gif +append \) \
            \( $DIR_PREV_IMG/fwi_AO_$datadomani$underscore$numero.gif $DIR_PREV_IMG/fwi_$datadomani$underscore$numero.gif +append \) \
            \( -size 100x200 xc:none +append \) \
            -background none -append $DIR_PREV_IMG/impaginata_$datadomani$underscore"0".gif

###     impagino mappe meteo oggi in previsione
    convert \( $DIR_PREVME_IMG/t_lami_$dataoggi$underscore$numero.gif $DIR_PREVME_IMG/ur_lami_$dataoggi$underscore$numero.gif +append \) \
	    \( $DIR_PREVME_IMG/ws_lami_$dataoggi$underscore$numero.gif $DIR_PREVME_IMG/prec24_lami_$dataoggi$underscore$numero.gif +append \) \
	    \( -size 100x200 xc:none +append \) \
	    -background none -append $DIR_FORMET_IMP/impaginatameteo_$datadomani$underscore"0".gif
    convert $DIR_FORMET_IMP/impaginatameteo_$datadomani$underscore"0".gif -crop 1600x1200 +repage $DIR_FORMET_IMP/impaginatameteo_$datadomani$underscore"0".gif

  
###	copio FORECAST impaginata su ghost 2

            rm -fv $WEBSERVER_V_FORE/*.gif
            scp $DIR_PREV_IMG/impaginata_$dataoggi$underscore"1".gif meteo@10.10.0.14:$WEBSERVER_V_FORE/
            scp $DIR_PREV_IMG/impaginata_$datadomani$underscore"0".gif meteo@10.10.0.14:$WEBSERVER_V_FORE/
            rm -fv $WEBSERVER_V_FOREME/*.gif
            scp $DIR_FORMET_IMP/impaginatameteo_$dataoggi$underscore"1".gif meteo@10.10.0.14:$WEBSERVER_V_FOREME/
            scp $DIR_FORMET_IMP/impaginatameteo_$datadomani$underscore"0".gif meteo@10.10.0.14:$WEBSERVER_V_FOREME/

# copio FORECAST su WEB SERVER ARPA 172.16.1.6/ecc
# A) copia delle mappe con aggregazione su Aree
            rm $DIR_SPEDIZIONI/*
            cp $DIR_PREV_IMG/*AO*$dataoggi$underscore"1".gif $DIR_SPEDIZIONI/
            cp $DIR_PREV_IMG/*AO*$datadomani$underscore"2".gif $DIR_SPEDIZIONI/
            rename.ul AO_$dataoggi$underscore"1" oggi $DIR_SPEDIZIONI/*.gif
            rename.ul AO_$datadomani$underscore"2" domani $DIR_SPEDIZIONI/*.gif
$SMBCLIENT //$WEBESTIP/$WEBESTDIR -U $WEBESTUSR%$WEBESTPWD <<End-of-smbclient4
prompt
cd $WEBESTDIR1
lcd $DIR_SPEDIZIONI
mput *
End-of-smbclient4

# B) copia delle mappe originali mascherate con neve\idi\aree non bruciabili per GoogleMaps (e in più mappe aggregate per thumbnails)
            rm $DIR_SPEDIZIONI/*
            cp $DIR_PREV_IMG/*_$dataoggi$underscore"1".png $DIR_SPEDIZIONI/
            cp $DIR_PREV_IMG/*_$datadomani$underscore"2".png $DIR_SPEDIZIONI/
            rename.ul $underscore$dataoggi$underscore"1" _oggi $DIR_SPEDIZIONI/*.png
            rename.ul $underscore$datadomani$underscore"2" _domani $DIR_SPEDIZIONI/*.png
$SMBCLIENT //$WEBESTIP/$WEBESTDIR -U $WEBESTUSR%$WEBESTPWD <<End-of-smbclient5
prompt
cd $WEBESTDIR2
lcd $DIR_SPEDIZIONI
mput *
End-of-smbclient5
#
# Copia su /previsore del file per la compilazione del bollettino "Vigilanza AIB"
            rm $DIR_SPEDIZIONI/*.*
            cp $DIR_INI/creaxvigaib$underscore$dataieri".txt" $DIR_SPEDIZIONI/
            cp $DIR_INI/creaxvigaib$underscore$dataoggi".txt" $DIR_SPEDIZIONI/ 
            cp $DIR_INI/creaxvigaib$underscore$datadomani".txt" $DIR_SPEDIZIONI/
            cp $DIR_INI/creaxvigalp$underscore$dataieri".txt" $DIR_SPEDIZIONI/
            cp $DIR_INI/creaxvigalp$underscore$dataoggi".txt" $DIR_SPEDIZIONI/
            cp $DIR_INI/creaxvigalp$underscore$datadomani".txt" $DIR_SPEDIZIONI/
            WEBPREVIP=10.10.0.10
            WEBPREVDIR=F
            WEBPREVDIR1=Incendi_boschivi/creaxvigaib/
			WEBPREVDIR2="\Precompilazione\AIB_vig"
            WEBPREVUSR=ARPA/meteo
            WEBPREVPWD="%meteo2010"
# ...prima però li copio su meteo.arpalombardia.it/Precompilazione/AIB/bolvig
scp $DIR_SPEDIZIONI/creaxvigaib* meteoweb@172.16.1.10:/var/www/meteo/Precompilazione/AIB/bolvig			

$SMBCLIENT //$WEBPREVIP/$WEBPREVDIR -U $WEBPREVUSR%$WEBPREVPWD <<End-of-smbclient6
prompt
cd $WEBPREVDIR1
lcd $DIR_SPEDIZIONI
mput creaxvigaib*
cd $WEBPREVDIR2
mput creaxvigaib*
End-of-smbclient6
#

# Copia su /previsore delle mappe per la compilazione del bollettino "Meteo Stagione AIB"
            rm $DIR_SPEDIZIONI/*.*
            cp $DIR_ANA_IMG/ffmc$underscore"mask"$underscore$dataieri".gif" $DIR_SPEDIZIONI/
            cp $DIR_ANA_IMG/dmc$underscore"mask"$underscore$dataieri".gif" $DIR_SPEDIZIONI/
	    cp $DIR_ANA_IMG/dc$underscore"mask"$underscore$dataieri".gif" $DIR_SPEDIZIONI/
	    cp $DIR_NEVE_IMG/neve$underscore$dataieri".gif" $DIR_SPEDIZIONI/
            WEBPREVDIR2=Incendi_boschivi/Meteo_stagione/mappe/ffmc/
            WEBPREVDIR3=../dmc/
            WEBPREVDIR4=../dc/
            WEBPREVDIR5=../neve/
$SMBCLIENT //$WEBPREVIP/$WEBPREVDIR -U $WEBPREVUSR%$WEBPREVPWD <<End-of-smbclient7
prompt
cd $WEBPREVDIR2
lcd $DIR_SPEDIZIONI
mput ffmc*
cd $WEBPREVDIR3
mput dmc*
cd $WEBPREVDIR4
mput dc*
cd $WEBPREVDIR5
mput neve*
End-of-smbclient7
#

#       script per ftp alpffirs 

           /home/meteo/programmi/fwi_grid/xml/createXML_prova.sh > /home/meteo/tmp/arcibaldone.log 2>&1


            echo "ok" >$end_forecast.$dataoggi
#           fine FORECAST

      else	
	    echo "$datacontrologgi non e' uguale a $dataoggi: problemi corsa cosmoi7"
	    exit 1
      fi
fi

echo "<font face="Verdana, Arial, Helvetica, sans-serif"><font size=4><b>`date +%d-%m-%Y`</b></font>" > $HOME/programmi/fwi_grid/dataoggi.html
$SMBCLIENT //$WEBESTIP/$WEBESTDIR -U $WEBESTUSR%$WEBESTPWD <<End-of-smbclient7
prompt
cd $WEBESTDIR3
lcd $HOME/programmi/fwi_grid 
put dataoggi.html 
End-of-smbclient7
 
exit 0
