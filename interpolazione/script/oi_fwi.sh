#!/bin/bash
#===============================================================================
# <oi_fwi.sh>
#
# DESCRIZIONE:
# ===========
#  Interpolazione spaziale delle osservazioni medie orarie rilevate dalla
#  rete meteorologica di ARPA Lombardia.
#  Generalmente, questo applicativo viene lanciato in automatico per
#  elaborazioni legate all'attivita anti-incedio.
#
# RIGA DI COMANDO:
# ================
#  >oi_fwi.sh -s datastart -e dataend
#  argomenti:
#   -s datastart
#     formato AAAAMMGGhhmm
#   -e dataend
#     formato AAAAMMGGhhmm
#
# CODICI D'USCITA:
# ================
# 0 -> successo!
# 1 -> errore!
#
# METODO:
# =======
# [ 0] Lettura riga di comando 
# [ 1] Dichiarazione variabili
# [ 2] Pulizia directory temporanee e di accumulo
# [ 3] Richiesta osservazioni medie orarie al DBmeteo
# [ 4] Statistical Interpolation Temperatura al Suolo
# [ 5] Statistical Interpolation Precipitazione
# [ 6] Statistical Interpolation Vento
# [ 7] Statistical Interpolation Umidita Relativa 
# [ 8] calcolo indici FWI
# [ 9] memorizzazione db meteo
# [10] Pulisci e uscita
#
# INFORMAZIONI ACCESSORIE PRODOTTE:
# =================================
# Questo script e' pensato per stampare dei messaggi a video (che possono
# essere rediretti in un file di log, per esempio) con lo scopo di segnalare
# quale sezione dello script e' in esecuzione. Inoltre, gli applicativi di 
# interpolazione e quelli di elaborazione con GrADS producono dei file di log 
# 
# FORMATO DEI PRINCIPALI FILES COINVOLTI:
# =======================================
# Le coppie di files .ctl/.dat rappresentano un insieme di dati codificati in
# formato GrADS (the Grid Analysis Display System, http://grads.iges.org) sia
# di tipo griglia che di tipo stazione.
#  ------------------
#  Misure in ingresso
#  ------------------
# I dati misurati vengono richiesti al DBmeteo attraverso una procedura che
# li rende disponibili in formato Comma Separated Value (.Csv). Ciascun file 
# contiene le misure di un sensore. Il formato dei file e':
# idsensore,data ora,valore,codice di validita'
# per ulteriori informazioni consigliamo di contattare l'UO meteorologia di 
# ARPA Lombardia.
#  --------------------------------------
#  File output delle interpolazioni
#  --------------------------------------
#  I files di output delle procedure di interpolazione sono in formato GrADS. 
#  Oppure sono in formato testuale. 
#
#  File .gif
#  ---------
# risoluzione 800x800. Le mappe delle aggregazioni giornaliere hanno 
# risoluzione diversa e sono l'unione di diverse immagini.
#
# REFERENTE: Cristian Lussana (c.lussana@arpalombardia.it)
# ==========
#
# STORIA:
# =======
#  data        commento
# ------      ----------
# 2011/07/07  C.Lussana - Codice Originale
# 2011/07/07  C.Lussana - variato il codice per la precipitazione "rainzln..."->"plzln11"
# 2012/01/13  C.Lussana - aggiunto flag "salta_interpolazione" per versione debug
#========================================================================================
#-------------------------------
# [ 0] Lettura riga di comando 
#-------------------------------
  flagDATAI=0
  flagDATAF=0
  while getopts "s:e:" Option
  do
    case $Option in
    s ) flagDATAI=1
    DATAI=$OPTARG
    ;;
    e ) flagDATAF=1
    DATAF=$OPTARG
    ;;
    * ) echo " Opzione non riconosciuta ";;
    esac
  done
# checks
  if [ "$flagDATAI" -eq 0 ] || [ "$flagDATAF" -eq 0 ]
  then
    echo "errore nell'inserimento delle date nella linea di comando"
    exit 1
  fi
# log
  DATAC=`date +%Y%m%d%H%M`
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > interpolazione temperatura al suolo richiesta da "$DATAI" a "$DATAF
#-------------------------------
# [ 1] Dichiarazione variabili
#-------------------------------
# DIRECTORIES
# /home/meteo/programmi/interpolazione_statistica
# oi_fwi
# +- applicativi
# |  +- log
# |     +- precipitazione 
# |     +- radiazione 
# |     +- temperatura 
# |     +- umiditarelativa
# |     +- vento 
# +- info
# |  +- province
# +- dati
# +- temp
# +- archivio_tabelle
# |  +- precipitazione 
# |  +- temperatura
# |  +- umiditarelativa 
# |  +- vento 
# +- archivio_risultati
# |  +- precipitazione 
# |  +- temperatura
# |  +- umiditarelativa 
# |  +- vento 
# +- mappe
#    +- script
#    |  +- log
#    +- immagini
#       +- precipitazione 
#          +- analisi 
#          +- analisi_giornaliera 
#          +- idi 
#       +- temperatura 
#          +- analisi 
#          +- analisi_giornaliera 
#          +- idi 
#       +- umiditarelativa 
#          +- analisi 
#          +- analisi_giornaliera 
#          +- idi 
#       +- vento 
#          +- analisi 
#          +- idi 
#------------------------------------------------------------------------------
  DIR_MAIN=$HOME/programmi/interpolazione_statistica/oi_fwi
  DIR_TEMP=$DIR_MAIN/temp
  DIR_INFO=$DIR_MAIN/info
  DIR_MAPPE=$DIR_MAIN/mappe
  DIR_MAPPE_IMMAGINI=$DIR_MAPPE/immagini
  DIR_AR_TAB=$DIR_MAIN/archivio_tabelle
  DIR_AR_RIS=$DIR_MAIN/archivio_risultati
  DIR_AR_TAB_T=$DIR_AR_TAB/temperatura
  DIR_AR_RIS_T=$DIR_AR_RIS/temperatura
  DIR_AR_TAB_RH=$DIR_AR_TAB/umiditarelativa
  DIR_AR_RIS_RH=$DIR_AR_RIS/umiditarelativa
  DIR_AR_TAB_VV=$DIR_AR_TAB/vento
  DIR_AR_RIS_VV=$DIR_AR_RIS/vento
  DIR_AR_TAB_PR=$DIR_AR_TAB/precipitazione
  DIR_AR_RIS_PR=$DIR_AR_RIS/precipitazione
  DIR_AP=$DIR_MAIN/applicativi
  DIR_AP_LOG=$DIR_AP/log
  DIR_AP_LOG_T=$DIR_AP_LOG/temperatura
  DIR_AP_LOG_RH=$DIR_AP_LOG/umiditarelativa
  DIR_AP_LOG_VV=$DIR_AP_LOG/vento
  DIR_AP_LOG_PR=$DIR_AP_LOG/precipitazione
  DIR_DATI=$DIR_MAIN/dati
  DIR_GEOINFO=/home/meteo/programmi/geoinfo
# richiesta dati
  GETDATA_MYSQL=/home/meteo/programmi/getdata/mysql_201103/getdata_mysql.sh
  CSV2GrADS=$HOME/programmi/CSV2GrADS/CSV2GrADSv2/CSV2GrADS
  DIFF_HOURS=$DIR_AP/diff-hours.sh
  IDPROJ=oi_`date +%Y%m%d%H%M%S`
  ANAGRAFICAGBCTL=$DIR_GEOINFO/anagrafica.ctl
  ANAGRAFICAGBDAT=$DIR_GEOINFO/anagrafica.dat
  DATIINGBCTL=$DIR_TEMP/DBgb_$DATAI"_"$DATAF"_"$DATAC".ctl"
  DATIINGBDAT=$DIR_TEMP/DBgb_$DATAI"_"$DATAF"_"$DATAC".dat"
  TEMPORANEO=$DIR_TEMP/csv2grads.tmp
  CODICECSV2GrADS=2
  TEMPABRV='temp '
  ELEVABRV='elev '
  RELHABRV='ur '
  VVABRV='vvc '
  DVABRV='dvc '
  VVSABRV='vvs '
  DVSABRV='dvs '
  PRABRV='pluvio '
# external application/command/utilities
  SCP=/usr/bin/scp
#  GRADS=/usr/local/bin/grads
#  GRADS=/usr/local/bin/grads/bin/grads
GRADS=/opt/bin/grads
#  STNMAP=/usr/local/bin/stnmap
#  STNMAP=/usr/local/bin/grads/bin/stnmap
STNMAP=/opt/bin/stnmap
# interpolazione 
  T2M11=$DIR_AP/t2m11
  T2M11log=$DIR_AP_LOG_T/t2m11.log
  RHTD11=$DIR_AP/rhtd11
  RHTD11log=$DIR_AP_LOG_RH/rhtd11.log
  WIND11=$DIR_AP/wind11
  WIND11log=$DIR_AP_LOG_VV/wind11.log
  PRECI=$DIR_AP/plzln11
  PRECIlog=$DIR_AP_LOG_PR/plzln11.log
#
  YYYY=${DATAI:0:4}
  YYYYMMDD=${DATAI:0:8}
  YYYYMMDDHH=${DATAI:0:10}
  YYYYMMDDHHf=${DATAF:0:10}
# GrADS & GrADS related files
  PLOTTA_T2M=$DIR_MAPPE/script/plotta_t2m.gs
  PLOTTA_T2Mlog=$DIR_MAPPE/script/log/plotta_t2m.gs.log
  PLOTTA_WIND11=$DIR_MAPPE/script/plotta_vento.gs
  PLOTTA_WIND11log=$DIR_MAPPE/script/log/plotta_vento.gs.log
  PLOTTA_PRECI=$DIR_MAPPE/script/plotta_hourlyrain_tana11.gs
  PLOTTA_PRECIlog=$DIR_MAPPE/script/log/plotta_hourlyrain_tana11.gs.log
  PLOTTA_PRECG=$DIR_MAPPE/script/plotta_dailyrain_tana11.gs
  PLOTTA_PRECGlog=$DIR_MAPPE/script/log/plotta_dailyrain_tana11.gs.log
  PLOTTA_RH=$DIR_MAPPE/script/plotta_rh2m.gs
  PLOTTA_RHlog=$DIR_MAPPE/script/log/plotta_rh2m.gs.log
  TOPOGRAPHY_1500=$DIR_GEOINFO/topography_1500.ctl
  T2M11GRDCTL=$DIR_INFO/t2m_g.ctl
  T2M11GRDDAT=$DIR_TEMP/$YYYYMMDD"t2m_g.dat"
  T2M11STNCTL=$DIR_INFO/t2m_s.ctl
  T2M11STNDAT=$DIR_TEMP/$YYYYMMDD"t2m_s.dat"
  WIND11GRDCTL=$DIR_INFO/wind_g.ctl
  WIND11GRDDAT=$DIR_TEMP/$YYYYMMDD"wind_g.dat"
  WIND11STNCTL=$DIR_INFO/wind_s.ctl
  WIND11STNDAT=$DIR_TEMP/$YYYYMMDD"wind_s.dat"
  RHTD11GRDCTL=$DIR_INFO/rhtd_g.ctl
  RHTD11GRDDAT=$DIR_TEMP/$YYYYMMDD"tdrh_g.dat"
  RHTD11STNCTL=$DIR_INFO/rhtd_s.ctl
  RHTD11STNDAT=$DIR_TEMP/$YYYYMMDD"tdrh_s.dat"
  PRECIGRDCTL=$DIR_INFO/raintana11_g.ctl
  PRECIGRDDAT=$DIR_TEMP/$YYYYMMDD"plzln_g.dat"
  PRECISTNCTL=$DIR_INFO/raintana11_s.ctl
  PRECISTNDAT=$DIR_TEMP/$YYYYMMDD"plzln_s.dat"
  PRECGGRDCTL=$DIR_INFO/cumraintana11_g.ctl
  PRECGGRDDAT=$DIR_TEMP/$YYYYMMDD"CUMplzln_g.dat"
# files per FWI
  FWIGRID=$HOME/programmi/fwi_grid/fwigrid_ana_2.1
  FWIGRIDINI=$HOME/programmi/fwi_grid/fwigrid.nml
  FWIGRIDLOG=$HOME/programmi/fwi_grid/fwigrid.log

# applicativo memorizzazione database
  FWIDBDATE=${DATAF:0:8}
  FWIDBMGR=$HOME/dev/redist/fwidbmgr/fwidbmgr

#..............................................................................
# flag per versione di debug - Luca Paganotti
salta_interpolazione=0
if [ "$salta_interpolazione" -eq 0 ]
then
#--------------------------------------------------
# [ 2] Pulizia directory temporanee e di accumulo
#--------------------------------------------------
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio procedura pulizia preliminare" 
#  find $DIR_AR_TAB -atime +4 -name "*" -exec rm -vf {} \;
#  find $DIR_AR_RIS -atime +4 -name "*" -exec rm -vf {} \;
#  find $DIR_AP_LOG -atime +4 -name "*" -exec rm -vf {} \;
  find $DIR_AR_TAB -name "*" -exec rm -vf {} \;
  find $DIR_AR_RIS -name "*" -exec rm -vf {} \;
  find $DIR_AP_LOG -name "*" -exec rm -vf {} \;
#  find $DIR_MAPPE_IMMAGINI/ -ctime +4 -iname "*.gif" -exec rm -vf {} \;
#  find $DIR_MAPPE_IMMAGINI/ -ctime +4 -iname "*.png" -exec rm -vf {} \;
#  find $DIR_MAPPE_IMMAGINI/ -ctime +4 -iname "*.jpg" -exec rm -vf {} \;
  find $DIR_MAPPE_IMMAGINI/ -iname "*.gif" -exec rm -vf {} \;
  find $DIR_MAPPE_IMMAGINI/ -iname "*.png" -exec rm -vf {} \;
  find $DIR_MAPPE_IMMAGINI/ -iname "*.jpg" -exec rm -vf {} \;
# look for empty dir
  if [ "$(ls -A $DIR_TEMP)" ]; then
    echo "Take action $DIR_TEMP is not Empty"
    rm -vf $DIR_TEMP/*
  else
    echo "$DIR_TEMP is Empty"
  fi
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine procedura pulizia preliminare"
#----------------------------------------------------
# [ 3] Richiesta osservazioni medie orarie al DBmeteo
#----------------------------------------------------
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio procedura richiesta dati [richiesta/CSV2GrADS]" 
#...................
# test che permette di saltare la procedura di richiesta dati in fase di debug
# skip=1 salta la richiesta dati
# skip=0 richiedi i dati
skip=0 
if [ "$skip" -eq 0 ]
then
  if [ "$(ls -A $DIR_DATI)" ]; then
    echo "Take action $DIR_DATI is not Empty"
    find $DIR_DATI/ -name "*.Csv" -exec rm -f {} \;
  else
    echo "$DIR_DATI is Empty"
  fi
#..............................................................................
# Temperatura
  $GETDATA_MYSQL -s $DATAI -e $DATAF -L T -f "ORARIA" -o $DIR_DATI -k "-102 -101 -100 -1 0 1" -n $IDPROJ -B -K -E 
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H%M`" >  Errore richiesta dati meteo (temperatura)"
    exit 1
  fi
#..............................................................................
# Umidita Relativa
  $GETDATA_MYSQL -s $DATAI -e $DATAF -L RH -f "ORARIA" -o $DIR_DATI -k "-102 -101 -100 -1 0 1" -n $IDPROJ -B -K -E
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  Errore richiesta dati meteo (umidita relativa)"
    exit 1
  fi
#..............................................................................
# Pressione
#  $GETDATA_MYSQL -s $DATAI -e $DATAF -L PA -f "ORARIA" -o $DIR_DATI -k "-102 -101 -100 -1 0 1" -n $IDPROJ -B -K -E
#  if [ "$?" -ne 0 ]
#  then
#    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  Errore richiesta dati meteo (pressione)"
#    exit 1
#  fi
#..............................................................................
# Radiazione Globale
#  $GETDATA_MYSQL -s $DATAI -e $DATAF -L RG -f "ORARIA" -o $DIR_DATI -k "-102 -101 -100 -1 0 1" -n $IDPROJ -B -K -E
#  if [ "$?" -ne 0 ]
#  then
#    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  Errore richiesta dati meteo (radiazione globale)"
#    exit 1
#  fi
#..............................................................................
# Velocita del vento
  $GETDATA_MYSQL -s $DATAI -e $DATAF -L VV -f "ORARIA" -o $DIR_DATI -k "-102 -101 -100 -1 0 1" -n $IDPROJ -B -K -E
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  Errore richiesta dati meteo (velocita del vento)"
    exit 1
  fi
#..............................................................................
# Direzione del vento 
  $GETDATA_MYSQL -s $DATAI -e $DATAF -L DV -f "ORARIA" -o $DIR_DATI -k "-102 -101 -100 -1 0 1" -n $IDPROJ -B -K -E
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  Errore richiesta dati meteo (direzione del vento)"
    exit 1
  fi
#..............................................................................
# Precipitazione 
  $GETDATA_MYSQL -s $DATAI -e $DATAF -L PP -f "ORARIA" -o $DIR_DATI -k "-102 -101 -100 -1 0 1" -n $IDPROJ -B -K -E
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  Errore richiesta dati meteo (precipitazione)"
    exit 1
  fi
#..............................................................................
  NUM_FILES_CSV=`ls -1 $DIR_DATI | wc -l`
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >     presenti "$NUM_FILES_CSV" files in "$DIR_DATI")"
  if [ "$NUM_FILES_CSV" -le 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! Nessun file presente nella directory :"$DIR_DATI
    exit 1
  fi
fi
# CSV2GrADS
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio CSV2GrADS"
  $CSV2GrADS $ANAGRAFICAGBCTL $DIR_DATI/ $DATIINGBCTL $TEMPORANEO $CODICECSV2GrADS
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > errore durante l'esecuzione della routine $CSV2GrADS."
    exit 1
  fi
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine CSV2GrADS"
# Individua le variabili nel file di input GrADS
  POSTEMP=0
  POSELEV=0
  POSRELH=0
  POSVV=0
  POSDV=0
  POSPR=0
  POSVVS=0
  POSDVS=0
  NVARS=0
  cont=0
  {
    while read RIGA
    do
      cont=$(( cont + 1 ))
      AUX=`expr match "$RIGA" "$TEMPABRV"`
      if [ "$AUX" -ne 0 ]
      then
        POSTEMP=$cont
      fi
      AUX=`expr match "$RIGA" "$RELHABRV"`
      if [ "$AUX" -ne 0 ]
      then
        POSRELH=$cont
      fi
      AUX=`expr match "$RIGA" "$ELEVABRV"`
      if [ "$AUX" -ne 0 ]
      then
        POSELEV=$cont
      fi
      AUX=`expr match "$RIGA" "$VVABRV"`
      if [ "$AUX" -ne 0 ]
      then
        POSVV=$cont
      fi
      AUX=`expr match "$RIGA" "$DVABRV"`
      if [ "$AUX" -ne 0 ]
      then
        POSDV=$cont
      fi
      AUX=`expr match "$RIGA" "$VVSABRV"`
      if [ "$AUX" -ne 0 ]
      then
        POSVVS=$cont
      fi
      AUX=`expr match "$RIGA" "$DVSABRV"`
      if [ "$AUX" -ne 0 ]
      then
        POSDVS=$cont
      fi
      AUX=`expr match "$RIGA" "$PRABRV"`
      if [ "$AUX" -ne 0 ]
      then
        POSPR=$cont
      fi
      AUX=`expr match "$RIGA" VARS`
      if [ "$AUX" -ne 0 ]
      then
        NVARS=`echo $RIGA | awk '{print $NF}'`
        POSNVARS=$cont
      fi    
    done
  } < $DATIINGBCTL
  POSTEMPrel=$((POSTEMP-POSNVARS))
  POSRELHrel=$((POSRELH-POSNVARS))
  POSELEVrel=$((POSELEV-POSNVARS))
  POSVVrel=$((POSVV-POSNVARS))
  POSDVrel=$((POSDV-POSNVARS))
  POSVVSrel=$((POSVVS-POSNVARS))
  POSDVSrel=$((POSDVS-POSNVARS))
  POSPRrel=$((POSPR-POSNVARS))
# LOG
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   GrADS file header (.ctl) con i dati "$DATIINGBCTL
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   numero   di  variabili  meteo [NVARS] ="$NVARS
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione                 temperatura ="$POSTEMP
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione              precipitazione ="$POSPR
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione            umidita relativa ="$POSRELH
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione                  elevazione ="$POSELEV
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione                    velocita ="$POSVV
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione                   direzione ="$POSDV
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione             velocita sonico ="$POSVVS
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione            direzione sonico ="$POSDVS
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione        relativa temperatura ="$POSTEMPrel
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione     relativa precipitazione ="$POSPRrel
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione   relativa umidita relativa ="$POSRELHrel
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione         relativa elevazione ="$POSELEVrel
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione           relativa velocita ="$POSVVrel
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione          relativa direzione ="$POSDVrel
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione    relativa velocita sonico ="$POSVVSrel
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   posizione   relativa direzione sonico ="$POSDVSrel
# check vari
  if [ "$NVARS" -lt 2 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! numero di variabili nel file di dati insufficiente (deve essere maggiore di 1)"
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  file di dati:"$DATIINGBCTL
    exit 1
  fi
  if [ "$POSTEMP" -eq 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! richiesta interpolazione della temperatura ma apparentemente non ci sono dati da interpolare! Ovvero all'interno del file di dati non appare l'abbreviazione per la temperatura."
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   file di dati: "$DATIINGBCTL
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  abbreviazione: "$TEMPABRV
    exit 1
  fi
  if [ "$POSPR" -eq 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! richiesta interpolazione della precipitazione ma apparentemente non ci sono dati da interpolare! Ovvero all'interno del file di dati non appare l'abbreviazione per la precipitazione."
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   file di dati: "$DATIINGBCTL
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  abbreviazione: "$PRABRV
    exit 1
  fi
  if [ "$POSRELH" -eq 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! manca il campo umidita relativa all'interno del file di dati, ovvero non appare l'abbreviazione per umidita relativa."
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   file di dati: "$DATIINGBCTL
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  abbreviazione: "$RELHABRV
    exit 1
  fi
  if [ "$POSELEV" -eq 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! manca il campo di elevazione all'interno del file di dati, ovvero non appare l'abbreviazione per l'elevazione."
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   file di dati: "$DATIINGBCTL
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  abbreviazione: "$ELEVABRV
    exit 1
  fi
  if [ "$POSVV" -eq 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! manca il campo di elevazione all'interno del file di dati, ovvero non appare l'abbreviazione per la velocita del vento."
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   file di dati: "$DATIINGBCTL
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  abbreviazione: "$VVABRV
    exit 1
  fi
  if [ "$POSVVS" -eq 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! manca il campo di elevazione all'interno del file di dati, ovvero non appare l'abbreviazione per la velocita del vento sonico."
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   file di dati: "$DATIINGBCTL
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  abbreviazione: "$VVSABRV
    exit 1
  fi
  if [ "$POSDV" -eq 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! manca il campo di elevazione all'interno del file di dati, ovvero non appare l'abbreviazione per la direzione del vento."
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   file di dati: "$DATIINGBCTL
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  abbreviazione: "$DVABRV
    exit 1
  fi
  if [ "$POSDVS" -eq 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  ERRORE! manca il campo di elevazione all'interno del file di dati, ovvero non appare l'abbreviazione per la direzione del vento sonico."
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   file di dati: "$DATIINGBCTL
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >  abbreviazione: "$DVSABRV
    exit 1
  fi
# individuazione numero di istanti temporali da interpolare
  NTEMPI=$((`$DIFF_HOURS $DATAI $DATAF`+1))
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   numero di istanti temporali per cui e' richiesta l'interpolazione [NTEMPI] = "$NTEMPI
  if [ "$NTEMPI" -lt 10 ]
  then
    NTEMPI_AUX="00"$NTEMPI
  else
    if [ "$NTEMPI" -lt 100 ]
    then
      NTEMPI_AUX="0"$NTEMPI
    else
      NTEMPI_AUX=$NTEMPI
    fi
  fi
  YY=${DATAI:2:2}
  MM=${DATAI:4:2}
  DD=${DATAI:6:2}
  HH=${DATAI:8:2}
  case "$MM"
  in
  "01") WORDM="jan" ;;
  "02") WORDM="feb" ;;
  "03") WORDM="mar" ;;
  "04") WORDM="apr" ;;
  "05") WORDM="may" ;;
  "06") WORDM="jun" ;;
  "07") WORDM="jul" ;;
  "08") WORDM="aug" ;;
  "09") WORDM="sep" ;;
  "10") WORDM="oct" ;;
  "11") WORDM="nov" ;;
  "12") WORDM="dec" ;;
  esac
#-----------------------------------------------------
# [ 4] Statistical Interpolation Temperatura al Suolo
#-----------------------------------------------------
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > ==============================================================="
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio procedura Statistical Interpolation Temperatura al suolo"
  $T2M11 $YYYYMMDDHH $NTEMPI $DATIINGBDAT $NVARS $POSTEMPrel $DIR_GEOINFO/ $DIR_TEMP/ > $T2M11log 
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   Errore nell'esecuzione dell'applicativo <$T2M11> (interpolazione spaziale delle misuredi temperatura a 2m)"
    echo "$T2M11 $YYYYMMDDHH $NTEMPI $DATIINGBDAT $NVARS $POSTEMPrel $DIR_GEOINFO/ $DIR_TEMP/ > $T2M11log"
    exit 1
  fi
  cp $DIR_TEMP/$YYYYMMDD"t2m_g.dat" $DIR_AR_RIS_T/$YYYYMMDD"t2m_g.dat".`date +%Y%m%d%H%M`
  cp $DIR_TEMP/$YYYYMMDD"t2m_s.dat" $DIR_AR_RIS_T/$YYYYMMDD"t2m_s.dat".`date +%Y%m%d%H%M`
  AUX=`ls $DIR_TEMP/temperatura_$YYYYMMDDHH"_"$NTEMPI"_bf"*"_sct"*".csv"| awk -F / '{print $NF}'`
  cp $DIR_TEMP/temperatura_$YYYYMMDDHH"_"$NTEMPI"_bf"*"_sct"*".csv" $DIR_AR_TAB_T/$AUX.`date +%Y%m%d%H%M`
  cp $DIR_TEMP/"RMS.txt" $DIR_AR_TAB_T/"RMS.txt"`date +%Y%m%d%H%M`
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine procedura Statistical Interpolation Temperatura al suolo"
#
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio aggiustamento files .ctl"
  sed '/DSET/ c\DSET '$T2M11GRDDAT' ' -i $T2M11GRDCTL
  sed '/TDEF/ c\TDEF '$NTEMPI' LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $T2M11GRDCTL
  sed '/DSET/ c\DSET '$T2M11STNDAT' ' -i $T2M11STNCTL
  sed '/TDEF/ c\TDEF '$NTEMPI' LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $T2M11STNCTL
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine aggiustamento files .ctl"
#
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio elaborazioni/plottaggi GrADS"
  $STNMAP -i $T2M11STNCTL > $PLOTTA_T2Mlog
  $GRADS -bpc "$PLOTTA_T2M $T2M11GRDCTL $T2M11STNCTL $TOPOGRAPHY_1500" >> $PLOTTA_T2Mlog 
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine elaborazioni/plottaggi GrADS"
#-----------------------------------------------------
# [ 5] Statistical Interpolation Precipitazione
#-----------------------------------------------------
  rm -vf $DIR_MAPPE_IMMAGINI/precipitazione/analisi_24h/*.gif
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > ========================================================="
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio procedura Statistical Interpolation Precipitazione"
  $PRECI $YYYYMMDDHH $NTEMPI $DATIINGBDAT $NVARS $POSPRrel $POSTEMPrel $DIR_GEOINFO/ $T2M11STNDAT $DIR_TEMP/ > $PRECIlog
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   Errore nell'esecuzione dell'applicativo <$PRECI> (interpolazione spaziale delle misure di precipitazione)"
    echo "$PRECI $YYYYMMDDHH $NTEMPI $DATIINGBDAT $NVARS $POSPRrel $POSTEMPrel $DIR_GEOINFO/ $T2M11STNDAT $DIR_TEMP/ > $PRECIlog"
    exit 1
  fi
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine procedura Statistical Interpolation Precipitazione"
# 
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio aggiustamento files .ctl"
  sed '/DSET/ c\DSET '$PRECIGRDDAT' ' -i $PRECIGRDCTL
  sed '/TDEF/ c\TDEF '$NTEMPI' LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $PRECIGRDCTL
  sed '/DSET/ c\DSET '$PRECGGRDDAT' ' -i $PRECGGRDCTL
  sed '/TDEF/ c\TDEF 1 LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $PRECGGRDCTL
  sed '/DSET/ c\DSET '$PRECISTNDAT' ' -i $PRECISTNCTL
  sed '/TDEF/ c\TDEF '$NTEMPI' LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $PRECISTNCTL
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine aggiustamento files .ctl"
#
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio elaborazioni/plottaggi GrADS"
  $STNMAP -i $PRECISTNCTL > $PLOTTA_PRECIlog
  $GRADS -bpc "$PLOTTA_PRECI $PRECIGRDCTL $PRECISTNCTL $DIR_MAPPE_IMMAGINI/precipitazione/analisi/ $DIR_MAPPE_IMMAGINI/precipitazione/idi/ xpa po xidiw+xidid" > $PLOTTA_PRECIlog
  $GRADS -bpc "$PLOTTA_PRECG $PRECGGRDCTL rain $DIR_MAPPE_IMMAGINI/precipitazione/analisi_24h/ $DATAI $DATAF" > $PLOTTA_PRECGlog
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine elaborazioni/plottaggi GrADS"
#-----------------------------------------------------
# [ 6] Statistical Interpolation Vento
#-----------------------------------------------------
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > ================================================"
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio procedura Statistical Interpolation Vento"
  $WIND11 $YYYYMMDDHH $NTEMPI $DATIINGBDAT $NVARS $POSVVrel $POSDVrel $POSVVSrel $POSDVSrel $DIR_GEOINFO/ $DIR_TEMP/ > $WIND11log
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   Errore nell'esecuzione dell'applicativo <$WIND11> (interpolazione spaziale delle misure di vento)"
    echo "$WIND11 $YYYYMMDDHH $NTEMPI $DATIINGBDAT $NVARS $POSVVrel $POSDVrel $POSVVSrel $POSDVSrel $DIR_GEOINFO/ $DIR_TEMP/ > $WIND11log"
    exit 1
  fi
  cp $DIR_TEMP/$YYYYMMDD"wind_g.dat" $DIR_AR_RIS_VV/$YYYYMMDD"wind_g.dat".`date +%Y%m%d%H%M`
  cp $DIR_TEMP/$YYYYMMDD"wind_s.dat" $DIR_AR_RIS_VV/$YYYYMMDD"wind_s.dat".`date +%Y%m%d%H%M`
  AUX=`ls $DIR_TEMP/vento_$YYYYMMDDHH"_"$NTEMPI"_bf"*"_sct"*".csv"| awk -F / '{print $NF}'`
  cp $DIR_TEMP/vento_$YYYYMMDDHH"_"$NTEMPI"_bf"*"_sct"*".csv" $DIR_AR_TAB_VV/$AUX.`date +%Y%m%d%H%M`
  cp $DIR_TEMP/"RMS.txt" $DIR_AR_TAB_VV/"RMS.txt"`date +%Y%m%d%H%M`
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine procedura Statistical Interpolation Vento"
#
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio aggiustamento files .ctl"
  sed '/DSET/ c\DSET '$WIND11GRDDAT' ' -i $WIND11GRDCTL
  sed '/TDEF/ c\TDEF '$NTEMPI' LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $WIND11GRDCTL
  sed '/DSET/ c\DSET '$WIND11STNDAT' ' -i $WIND11STNCTL
  sed '/TDEF/ c\TDEF '$NTEMPI' LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $WIND11STNCTL
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine aggiustamento files .ctl"
#
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio elaborazioni/plottaggi GrADS"
  $STNMAP -i $WIND11STNCTL > $PLOTTA_WIND11log
  $GRADS -bpc "$PLOTTA_WIND11 $WIND11GRDCTL $WIND11STNCTL" >> $PLOTTA_WIND11log
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine elaborazioni/plottaggi GrADS"
#----------------------------------------------------------------
# [ 7] Statistical Interpolation Umidita Relativa 
#----------------------------------------------------------------
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > ==========================================================="
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio procedura Statistical Interpolation Umidita Relativa"
  $RHTD11 $YYYYMMDDHH $NTEMPI $DATIINGBDAT $NVARS $POSRELHrel $POSTEMPrel $DIR_GEOINFO/ $DIR_TEMP/$YYYYMMDD"t2m_s.dat" $DIR_TEMP/$YYYYMMDD"t2m_g.dat" $DIR_TEMP/ > $RHTD11log
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   Errore nell'esecuzione dell'applicativo <$RHTD11> (interpolazione spaziale delle misure di umidita relativa)"
    exit 1
  fi
  cp $RHTD11GRDDAT $DIR_AR_RIS_RH/$YYYYMMDD"tdrh_g.dat".`date +%Y%m%d%H%M`
  cp $RHTD11STNDAT $DIR_AR_RIS_RH/$YYYYMMDD"tdrh_s.dat".`date +%Y%m%d%H%M`
  AUX=`ls $DIR_TEMP/umidita_$YYYYMMDDHH"_"$NTEMPI"_bf"*"_sct"*".csv"| awk -F / '{print $NF}'`
  cp $DIR_TEMP/umidita_$YYYYMMDDHH"_"$NTEMPI"_bf"*"_sct"*".csv" $DIR_AR_TAB_RH/$AUX.`date +%Y%m%d%H%M`
  cp $DIR_TEMP/"RMS.txt" $DIR_AR_TAB_RH/"RMS.txt"`date +%Y%m%d%H%M`
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine procedura Statistical Interpolation Umidita Relativa"
# 
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio aggiustamento files .ctl"
  sed '/DSET/ c\DSET '$RHTD11GRDDAT' ' -i $RHTD11GRDCTL
  sed '/TDEF/ c\TDEF '$NTEMPI' LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $RHTD11GRDCTL
  sed '/DSET/ c\DSET '$RHTD11STNDAT' ' -i $RHTD11STNCTL
  sed '/TDEF/ c\TDEF '$NTEMPI' LINEAR '$HH':00Z'$DD$WORDM$YYYY' 1HR' -i $RHTD11STNCTL
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine aggiustamento files .ctl"
#
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > inizio elaborazioni/plottaggi GrADS"
  $STNMAP -i $RHTD11STNCTL > $PLOTTA_RHlog
  $GRADS -bpc "$PLOTTA_RH $RHTD11GRDCTL $RHTD11STNCTL $TOPOGRAPHY_1500" >> $PLOTTA_RHlog
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" >   fine elaborazioni/plottaggi GrADS"
fi

#---------------------------
# [ 8] calcolo indici FWI
#---------------------------
  echo "oi_fwi.sh "`date +%Y%m%d%H%M`" > inizio procedura calcolo indici FWI"
  $FWIGRID $FWIGRIDINI > $FWIGRIDLOG
  if [ "$?" -ne 0 ]
  then
    echo "oi_fwi.sh "`date +%Y%m%d%H%M`" >   Errore nell'esecuzione dell'applicativo <$FWIGRID>"
    exit 1
  fi
  echo "oi_fwi.sh "`date +%Y%m%d%H%M`" >   fine procedura calcolo indici FWI"

#---------------------------------
# [ 9] memorizzazione db meteo
#---------------------------------
  echo `date +%Y-%m-%d" "%H:%M`" Memorizzazione db dati meteo giorno: "$FWIDBDATE" FWIDBMGR_HOME="$FWIDBMGR_HOME
  $FWIDBMGR -a in -d $FWIDBDATE
  echo `date +%Y-%m-%d" "%H:%M`" DONE."

#--------------------------
# [10] Pulisci e uscita
#--------------------------
  echo "oi_fwi.sh "`date +%Y-%m-%d" "%H:%M`" > script concluso con successo!"
  exit 0

