#!/bin/bash
#===============================================================================
# < getdata_mysql.sh >
#
# DESCRIZIONE:
# ============
# Applicazione che si occupa di richiedere all'archivio meteo di ARPA Lombardia
# le misure rilevate in un predeterminato periodo da una serie di sensori.
#
# RIGA DI COMANDO:
# ================
#
# getdata_mysql.sh -selofknb
#
# opzioni:
# -s DATA_START  specifica la data di inizio richiesta dati al DB (AAAAMMGGhhmm)
# -e DATA_END    specifica la data di fine richiesta dati al DB (AAAAMMGGhhmm)
# -l LIST_SENS   percorso assoluto del file di testo contenente la lista dei sensori
# -L IDvariabile richiedi tutte le osservazioni di una variabile (anagrafica DBmeteo)
#                IDvariabile, stringa identificativa variabile:
#                T temperatura
#                RH umidita relativa
#                VV velocita del vento
#                DV direzione del vento
#                PA pressione atmosferica
#                PP precipitazione
#                RG radiazione solare globale
#                RN radiazione netta
# -o DIR_OUT     percorso assoluto alla directory che conterra' i files di output
# -f AGGREG      tipo di aggregazione scelta per i files di output (solo "ORARIA")
# -k VALID       filtro sul flag di validita' dei dati all'interno del DB unico
# -K             filtro sul flag di validita' dei dati all'interno dell'archivio 
#                mysql ("Flag_automatica")
# -n PROGETTO    nome del progetto
# -b FILE        se presente utilizza il file FILE come file di blacklist
# -B             utilizza la blacklist del DB METEO
# -G             ottieni solo le osservazioni giudicate buone
#                (aventi Flag_manuale=G nel DBmeteo)
# -E             ottieni solo le osservazioni non giudicate errate 
#                (aventi Flag_manuale!=E, ovvero =G o M, nel DBmeteo)
#
# nota sul filtro di validita' dei dati all'interno del DB unico:
#  -102 validato (da non attendibile)
#  -101 validato (da attendibile incompleto)
#  -100 validato (da attendibile completo)
#     0 attendibile completo
#     1 attendibile incompleto
#     2 non attendibile
#     3 non presente
#   100 invalidato (da attendibile completo)
#   101 invalidato (da attendibile incompleto)
#   102 invalidato (da non attendibile)
# + E' possibile utilizzare una combinazione dei codici (es: "-100 0 1 102") e la
#   richiesta restituira' SOLO le misure contrassegnate dal codice specificato.
#   Le misure contrassegnate dal flag di validita' non specificato non vengono 
#   restituite all'utente ma viene invece restituito il codice di valore non 
#   definito
# + Nel caso in cui l'opzione non sia attivata non si compie alcun filtro sui dati
#   in funzione del flag di validita' del DB unico
# + Ricordarsi sempre gli apici all'inizio e alla fine! (es: "-100 0 1 102")
#
# nota sul filtro di validita' dei dati all'interno dell'archivio meteo mysql:
# G   "good"  dato che ha superato tutti i test a cui e' stato sottoposto
# F   "fail"  dato che non rientra nei criteri ottimali 
# -Se attivata l'opzione -G vengono restituiti solo i dati contrassegnati da "G"
# -Se attivata l'opzione -E vengono restituiti solo i dati non contrassegnati 
# da "E"
# -L'opzione -G ha la priorita' sull'opzione -E, ovvero in caso di presenza 
# contemporanea di -G e -E vengono restituiti solo le osservazioni aventi
# flag "G"
#
# CODICI D'USCITA:
# ================
# (0) -> successo! I files .Csv sono presenti nella directory locale specificata
# (1) -> ERRORE! di varia natura:
#
# METODO:
# =======
# L'interazione e' con un archivio MYSQL su una macchina remota attraverso uno
# script R.
#
# ALGORITMO:
# @@@ [1.0] Dichiarazione parametri @@@
# @@@ [2.0] etichettatura file di log @@@
# @@@ [3.0] controlla la presenza di un ERRORE rilevante accaduto in precedenza @@@
# @@@ [4.0] controlli vari @@@
# @@@ [5.0] Lettura riga di comando @@@
# @@@ [6.0] genera file di richiesta @@@
# @@@ [7.0]  recupera i dati dall'archivio mysql @@@
# @@@ [8.0] goodnight players  @@@
#
# NOTA: ciascun passo presentato ha una propria sezione di commento
# NOTA: tutte le informazioni accessorie di debug/log vengono memorizzate nel
#       file di log:
#        FILE_LOG=$MAIN/log/getdata_mysql_"`date  +%Y%m%d`".log
#
# FORMATO FILES INPUT:
# ====================
# LIST_SENS   file di testo contenente la lista con i codici sensori.
#             Un codice per riga.
#
# FORMATO FILES OUTPUT:
# =====================
# nome file (lungo a piacere) -> "XXXXXX.Csv"
#   ---------------------------------------------------------
#   | IDsens | "AAAA/MM/GG hh:mm" | misura | flag validita' |
#   ---------------------------------------------------------
# esempio:
# "8050,2006/02/20 00:00,-999,3"
# note: "-999" undefined value
#
# FORMATO FILE DI LOG ($HOME"/log/getdata_"$data_log".log"):
# ==========================================================
#
# FORMATO FILE : $HOME"/programmi/getdata/mysql/getdata_mysql.txt"
# ================================================================
# Questo file e' un'estensione del file di log e contiene le
# informazioni sull'esito delle richieste fatte al DB attraverso la macchina
# sulla quale gira "getdata_mysql.sh". Formato files:
# -------------------------------------------
# | DATA | ORA | RICHIESTA | N CSV | CODICE |
# -------------------------------------------
# DATA       = AAAA/MM/GG
# ORA        = hh:mm
# RICHIESTA  = nome del file di richiesta .ric
# N CSV      = numero dei files .Csv depositati nella directory di output
# CODICE     = codice d'uscita da "getcsv.sh"
# (-1) depositata la richiesta nella directory del PC remoto (putric.sh)
# (0) richiesta conclusa - tutto OK
# (1) richiesta conclusa - ERRORE
# (2) richiesta non conclusa
# (3) ERRORE generico
#
# REFERENTE: Cristian Lussana (c.lussana@arpalombardia.it)
# ==========
#
# STORIA:
# =======
#    data     ver   commento
# ----------  ---   --------
# 2008/06/03  1.0   C.Lussana - versione originale ispirata a "getdata.sh"
# 2009/11/04  1.0   C.Lussana - aggiornamento che tiene conto della blacklist
#                               del DBmeteo
# 2010/07/xx  1.0   C.Lussana - inserimento flag G
# 2011/03/24  1.0   C.Lussana - inserimento flags: L,E
#===============================================================================
  DATA_INI=`date +%Y/%m/%d" "%H:%M:%S`
#---------------------------------------------
# @@@ [1.0] Dichiarazione parametri @@@
#---------------------------------------------
  MAIN=$HOME/programmi/getdata/mysql_201103
  TEMP=$MAIN/temp
  GENRIC=$MAIN/genric_mysql.sh
  GETCSV_RECENTI=$MAIN/getcsv_recenti.R
  GETCSV_STORICO=$MAIN/getcsv_storici.R
  FILE_LOG=/home/meteo/log/getdata_mysql_"`date  +%Y%m%d`".log
  FILE_STAT=$MAIN/getdata_mysql.txt
  SYSTEM_FAILURE_FILE=$MAIN/SYSTEM_FAILURE_MYSQL
  DAYS_BETWEEN=$MAIN/days-between.sh
#
  SLEEP=/bin/sleep
  WC=/usr/bin/wc
  SED=/bin/sed
  AWK=/bin/awk
#  AWK=/usr/bin/awk
  R=/usr/bin/R
#  R=/usr/local/bin/R
# parametri per ciclo
  MAX_CICLI=3
  TIME_SLEEP=30
# flags
  flag_s=0
  flag_e=0
  flag_l=0
  flag_L=0
  flag_o=0
  flag_f=0
  flag_k=0
  flag_K=0
  flag_G=0
  flag_E=0
  flag_n=0
  flag_b=0
  flag_B=0
#---------------------------------------------
# @@@ [2.0] etichettatura file di log @@@
#---------------------------------------------
  dataora=$(date +%Y/%m/%d" "%H:%M)
  echo "@@@@@~@@@@@@@@@@@@~@~@@@@@@@@@@@@@@@@@@@@@@@@@~@@@@@@@@~@@@@@@@@@@@~@@@@~@@@@"  >> $FILE_LOG
  echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> START << getdata_mysql.sh >>" >> $FILE_LOG
  echo "@@~@@@@~@@@@@@@@@@@@~@@@@@@@~@@@@@@@@@@@@@~@@@@@~@@@@@@@@@@@@~@@@~@@@@@~@@@@@"  >> $FILE_LOG
#-----------------------------------------------------------------------------------
# @@@ [3.0] controlla la presenza di un ERRORE rilevante accaduto in precedenza @@@
#-----------------------------------------------------------------------------------
  if [ -e "$SYSTEM_FAILURE_FILE" ]
  then
    echo "getdata.sh "`date +%Y/%m/%d" "%H:%M`"> ERRORE ERRORE ERRORE! Rilevata la presenza del file "$SYSTEM_FAILURE_FILE  >> $FILE_LOG
    echo "  convenzionalmente questo significa che in precedenza si e' verificato un grave ERRORE di sistema "  >> $FILE_LOG
    echo "  per cui si e' giudicato piu' prudente non procedere a nuove richieste dati al DB."  >> $FILE_LOG
    echo "  Per riattivare la procedura cancellare il file "$SYSTEM_FAILURE_FILE  >> $FILE_LOG
    echo "  In seguito rilanciare l'applicativo"  >> $FILE_LOG
    exit 3
  fi
#---------------------------------------------
# @@@ [4.0] Lettura riga di comando @@@
#---------------------------------------------
  while getopts "L:l:s:e:o:f:k:KGEn:b:B" Option
  do
    case $Option in
    s ) flag_s=1
    DATA_START=$OPTARG
    ;;
    e ) flag_e=1
    DATA_END=$OPTARG
    ;;
    l ) flag_l=1
    LIST_SENS=$OPTARG
    ;;
    L ) flag_L=1
    ID_VAR=$OPTARG
    ;;
    o ) flag_o=1
    DIR_OUT=$OPTARG
    ;;
    f ) flag_f=1
    AGGREG=$OPTARG
    ;;
    k ) flag_k=1
    VALID=$OPTARG
    ;;
    K ) flag_K=1
    ;;
    G ) flag_G=1
    ;;
    E ) flag_E=1
    ;;
    n) flag_n=1
    PROGETTO=$OPTARG
    ;;
    b ) flag_b=1
    BLCKFILE=$OPTARG
    ;;
    B ) flag_B=1
    ;;
    * ) echo " Opzione non riconosciuta ";;
    esac
  done
  # scrittura su file di log
  if [ "$flag_s" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">          richiesti dati da [DATA_START] = "$DATA_START >> $FILE_LOG
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">        richiesti dati fino a [DATA_END] = "$DATA_END >> $FILE_LOG
    NUM_DAYS=`$DAYS_BETWEEN ${DATA_START:4:2}/${DATA_START:6:2}/${DATA_START:0:4} ${DATA_END:4:2}/${DATA_END:6:2}/${DATA_END:0:4}`
    DATA_TODAY=`date +%Y%m%d%H00`
#    echo $DATA_START"->"$DATA_TODAY
    NUM_DAYS_FROM_TODAY=`$DAYS_BETWEEN ${DATA_START:4:2}/${DATA_START:6:2}/${DATA_START:0:4} ${DATA_TODAY:4:2}/${DATA_TODAY:6:2}/${DATA_TODAY:0:4}`
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">             numero di giorni richiesti  = "$NUM_DAYS >> $FILE_LOG
  else
    exit 1
  fi
  if [ "$flag_l" -ne 0 ]
  then
    if [ "$flag_L" -ne 0 ]
    then
      echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">  ERRORE!  presenti contemporaneamente flag l e flag L!!!" >> $FILE_LOG
      exit 1
    else
      echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">  lista di sensori richiesti [LIST_SENS] = "$LIST_SENS >> $FILE_LOG
      if [[ ! -e $LIST_SENS &&  "$flag_L" -eq 0 ]]
      then
        echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">  ERRORE!  file con lista sensori richiesti non esistente!!!" >> $FILE_LOG
        exit 1
      fi
    fi
  else
    LIST_SENS=0
  fi
  if [ "$flag_L" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">  richiesta tipologia [ID_VAR] = "$ID_VAR >> $FILE_LOG
  fi
  if [ "$flag_o" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">           directory di output [DIR_OUT] = "$DIR_OUT >> $FILE_LOG
  fi
  if [ "$flag_f" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> Tipologia di aggregazione dati [AGGREG] = "$AGGREG >> $FILE_LOG
  fi
  if [ "$flag_n" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> Radice del file di richiesta [PROGETTO] = "$PROGETTO >> $FILE_LOG
  else
    exit 1
  fi
  if [ "$flag_b" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">                 Blacklisting [BLCKFILE] = "$BLCKFILE >> $FILE_LOG
  fi
  if [ "$flag_B" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">                 Blacklisting using DBmeteo blacklist" >> $FILE_LOG
  fi
  if [ "$flag_k" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">   filtro sul flag di validita' DB unico = "$VALID >> $FILE_LOG
    NUMW_VALID=`echo $VALID | $WC -w | $AWK '{print $1}'`
    VALID_R=`echo "("$VALID")" | $SED "s/ /,/g" | $AWK '{print $1}'`
  else
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">   filtro sul flag di validita' DB unico = "$VALID >> $FILE_LOG
    NUMW_VALID=0
    VALID_R=""
  fi
#  echo "NUMW_VALID="$NUMW_VALID
#  echo "VALID_R="$VALID_R
#  exit 1
  if [ "$flag_K" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">   filtro sul flag di validita' automatico attivato " >> $FILE_LOG
  fi
  if [ "$flag_G" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">   filtro G sul flag di validita' manuale attivato " >> $FILE_LOG
  fi
  if [ "$flag_E" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`">   filtro !E sul flag di validita' manuale attivato " >> $FILE_LOG
  fi
#------------------------------------------------------------------------
# @@@ [5.0] controlli vari @@@
#------------------------------------------------------------------------
  FILE_RIC=$TEMP/$PROGETTO.ric
  if [ -e $FILE_RIC ]
  then
    rm -vf $FILE_RIC
  fi
#---------------------------------------------
# @@@ [6.0] genera file di richiesta @@@
#---------------------------------------------
# genera il file di richiesta dati al DB. Tale file richiede i dati da DATA_START
# a DATA_END, secondo i criteri di aggregazione e validita' specificati
# in AGGREG e VALID. La lista dei sensori da richiedere e' specificata nel file
# LIST_SENS e il nome del file di output e' $FILE_RIC
# aggiunta dell'opzione -b con il file contenente la blacklist.
  if [ "$flag_b" -eq 1  ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> $GENRIC -s $DATA_START -e $DATA_END -f $AGGREG -k "$VALID" -l $LIST_SENS -n $FILE_RIC -b $BLCKFILE" >> $FILE_LOG
    $GENRIC -s $DATA_START -e $DATA_END -f $AGGREG -k "$VALID" -l $LIST_SENS -n $FILE_RIC -b $BLCKFILE >> $FILE_LOG
  else
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> $GENRIC -s $DATA_START -e $DATA_END -f $AGGREG -k "$VALID"  -l $LIST_SENS -n $FILE_RIC" >> $FILE_LOG
    $GENRIC -s $DATA_START -e $DATA_END -f $AGGREG -k "$VALID" -l $LIST_SENS -n $FILE_RIC >> $FILE_LOG
  fi
  if [ "$?" -ne 0 ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> ERRORE in genric.sh" >> $FILE_LOG
    rm -f $FILE_RIC
    exit 1
  fi
#------------------------------------------------------------------
# @@@ [7.0]  recupera i dati dall'archivio mysql @@@
#------------------------------------------------------------------
#  find $DIR_OUT/ -name "*.Csv" -exec rm -f {} \;
#
  if [ "$(ls -A $DIR_OUT)" ]; then
    NUM_PRIMA=`ls -1 $DIR_OUT/*.Csv | $WC -l | awk '{ print $1}' `
  else
    NUM_PRIMA=0
  fi
  if [ -e $LIST_SENS ]
  then
    NUM_RIC=`$WC -l $LIST_SENS | awk '{ print $1}' `
  fi
  CONT=0
  while [ "$CONT" -le "$MAX_CICLI" ]
  do
    if [ "$NUM_DAYS_FROM_TODAY" -gt 15 ]
    then
      GETCSV=$GETCSV_STORICO
    else
      GETCSV=$GETCSV_RECENTI
    fi
    ARG0=$flag_G
    ARG1=$flag_K
    if [ "$flag_k" -eq 0 ]
    then
      ARG2=0
    else
      ARG2=$VALID_R
    fi
    ARG3=$flag_E
    if [ "$flag_L" -eq 0 ]
    then
      ARG4=0
    else
      ARG4=$ID_VAR
    fi
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> inizia esecuzione di "$GETCSV >> $FILE_LOG
#    $R --no-save --no-restore --args $ARG0 $ARG1 $ARG2 $ARG3 $ARG4 $flag_B $FILE_RIC $DIR_OUT $FILE_LOG < $GETCSV > /dev/null 2>&1
#echo "$R --no-save --no-restore --args $ARG0 $ARG1 $ARG2 $ARG3 $ARG4 $flag_B $FILE_RIC $DIR_OUT $FILE_LOG < $GETCSV"
    $R --no-save --no-restore --args $ARG0 $ARG1 $ARG2 $ARG3 $ARG4 $flag_B $FILE_RIC $DIR_OUT $FILE_LOG < $GETCSV > /dev/null 2>&1 
#    echo "$R --no-save --no-restore --args $ARG1 $ARG2 $FILE_RIC $DIR_OUT $FILE_LOG < $GETCSV"
#    $R --no-save --no-restore --args $ARG1 $ARG2 $FILE_RIC $DIR_OUT $FILE_LOG < $GETCSV
    if [ "$?" -ne 0 ]
    then
      echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> tentativo "$CONT" su "$MAX_CICLI" ERRORE in "$GETCSV >> $FILE_LOG
      CONT=$(( CONT+1 ))
      $SLEEP $TIME_SLEEP
      continue
    else
      break
    fi
  done
  if [ "$CONT" -gt "$MAX_CICLI" ]
  then
    echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> ERRORE in "$GETCSV >> $FILE_LOG
    exit 1
  fi
  NUM_DOPO=`ls -1 $DIR_OUT/*.Csv | $WC -l | awk '{ print $1}' `
  NUM=$(( NUM_DOPO-NUM_PRIMA ))
#  echo " * "$DATA_INI"  "`date +%Y/%m/%d" "%H:%M:%S`"  richiesta "$FILE_RIC" > # sensori richiesti/ottenuti = "$NUM_RIC"/"$NUM >> $FILE_STAT
  if [ ! -e $LIST_SENS ]
  then
    echo " * "$DATA_INI"  "`date +%Y/%m/%d" "%H:%M:%S`"  progetto "$PROGETTO" > # sensori richiesti/ottenuti = "$NUM_RIC"/"$NUM >> $FILE_STAT
  else
    echo " * "$DATA_INI"  "`date +%Y/%m/%d" "%H:%M:%S`"  progetto "$PROGETTO" > # sensori ottenuti = "$NUM >> $FILE_STAT
  fi
#------------------------------------------------------------------
# @@@ [8.0] goodnight players  @@@
#------------------------------------------------------------------
  rm -vf $FILE_RIC
  echo "getdata_mysql.sh "`date +%Y/%m/%d" "%H:%M`"> Successo!!" >> $FILE_LOG
  exit 0
