#!/bin/bash
#===============================================================================
# < genric.sh >
#
# DESCRIZIONE:
# ============
# script  per generare i files .ric, ovvero i files che le applicazioni
# HORTUS (su un PC remoto) richiedono per l'estrazione di informazioni dal
# DB ARPA Lombardia.
#
# RIGA DI COMANDO:
# ================
#
# genric.sh -s data_start -e data_end -f aggregazione -k validita' -l lista [opzioni] -n file.ric
#
# parametri riga di comando:
# -s DATA     -> data inizio richiesta AAAAMMGGHHmm
# -e DATA     -> data fine richiesta AAAAMMGGHHmm
# -f AGGREG   -> aggregazione dati: ORARI, GIORNALIERI
# -k VALIDITA -> filtro sulla validazione dei dati richiesti
#                -102 validato (da non attendibile)
#                -101 validato (da attendibile incompleto)
#                -100 validato (da attendibile completo)
#                   0 attendibile completo
#                   1 attendibile incompleto
#                   2 non attendibile
#                   3 non presente
#                 100 invalidato (da attendibile completo)
#                 101 invalidato (da attendibile incompleto)
#                 102 invalidato (da non attendibile)
# E' possibile utilizzare una combinazione dei codici (es: "-100 0 1 102")
# -l LIST     -> percorso completo al file contenente la lista dei codici
#                sensori da includere in .ric
# -n NOME     -> percorso completo in cui salvare il file .ric
# opzioni in riga di comando:
#  -b         -> utilizza il file con la lista nera dei sensori
#
# CODICI D'USCITA:
# ================
# (0) -> applicazione eseguita con successo
# (1) -> applicazione terminata in modo anomalo
#
# METODO:
# =======
# I files .ric sono formati da:
# + una prima riga che specifica l'intervallo temporale per l'estrazione
# + una seconda riga che specifica il tipo di aggregazione dei dati
# + una terza riga che specifica il filtro voluto in base allo stato di
#   validazione dei dati richiesti al DB e infine un'elenco di codici
#   sensore che rappresenta la chiave univoca per le misure nel DB.
# Per creare un file .ric e' quindi necessario raccogliere e assemblare
# opportunamente le informazioni sopra descritte. L'unica informazione non
# richiesta direttamente dalla riga di comando e' l'elenco dei codici sensore,
# che puo' arrivare tipicamente a contenere anche 1000 codici. Allora viene
# chiesto all'utente di specificare un file nel quale e' specificato questo
# elenco, una riga per ogni codice sensore.
#
# Algoritmo:
#
# FORMATO FILES .ric:
# ===================
# si veda il documento "Accesso facilmente automatizzabile al DataBase
# meteorologico di ARPA Lombardia attraverso applicativi Hortus" C.Antoniazzi,
# C.Lussana (21/11/2005)
#
# REFERENTE: Cristian Lussana (c.lussana@arpalombardia.it)
# ==========
#
# STORIA:
# =======
#    data     ver   commento
# ----------  ---   --------
# 2008/04/15  1.0   C.Lussana - portato il codice da ECCELLENTE a qui
#===============================================================================
# @@@ [1.0] Inizializzazione variabili @@@
#-------------------------------------------------------------------------------
#    DATA_START - data inizio richiesta DB AAAAMMGGHHmm
#      DATA_END - data fine richiesta DB AAAAMMGGHHmm
#        AGGREG - stringa che specifica l'aggregazione dei dati: ORARI, GIORNALIERI
#         VALID - stringa che specifica il filtro sulla validità dei dati
#     LIST_SENS - percorso completo+nomefile dell'elenco dei codici sensore
#                 da richiedere al DB (opz -l)
#          data - data AAAAMMGG
#           ora - ora HHmm
#       dataora - data+ora AAAA/MM/GG HH:mm
#        flag_s - flag associato a opzione riga di comando "-s";
#        flag_e - flag associato a opzione riga di comando "-e";
#        flag_f - flag associato a opzione riga di comando "-f";
#        flag_k - flag associato a opzione riga di comando "-k";
#        flag_l - flag associato a opzione riga di comando "-l";
#        flag_h - flag associato a opzione riga di comando "-h";
#    checkflags - flag utilizzato nella verifica della consistenza delle opzioni
#                 in input
#      FILE_AUX - percorso completo + nome del file da utilizzare per il passaggio
#                 unix2dos del file .ric
#      FILE_RIC - associato all'opzione "-n" e' il nome del file di richiesta
#                 (.ric)
#-------------------------------------------------------------------------------
  MAIN='/programmi/mysql/getdata'
  UNIX2DOS='/usr/bin/unix2dos'
  DATA_START=""
  DATA_END=""
  AGGREG=""
  VALID=""
  NUM_SENS_m=0
  NUM_SENS=0
  LIST_SENS=""
  FILE_RIC=""
  flag_s=0
  flag_e=0
  flag_f=0
  flag_k=0
  flag_n=0
  flag_l=0
  flag_h=0
  flag_b=0
  checkflags=0
# @@@ [2.0] Leggi riga di comando @@@
  while getopts "hs:e:f:k:l:n:b:" Option
  do
    case $Option in
    h ) flag_h=1;;
    s ) flag_s=1
    DATA_START=$OPTARG
    ;;
    e ) flag_e=1
    DATA_END=$OPTARG
    ;;
    f ) flag_f=1
    AGGREG=$OPTARG
    ;;
    k ) flag_k=1
    VALID=$OPTARG
    ;;
    l ) flag_l=1
    LIST_SENS=$OPTARG
    ;;
    n ) flag_n=1
    FILE_RIC=$OPTARG
    ;;
    b ) flag_b=1
    BLCKFILE=$OPTARG
    ;;
    * ) echo " Opzione non riconosciuta ";;
    esac
  done
  DATE=`echo ""$DATA_START" "$DATA_END""`
# ---- DEBUG ----
  echo "genric.sh "`date +%Y/%m/%d\ %T`"> VALORE VARIABILI PRINCIPALI:"
  echo "genric.sh "`date +%Y/%m/%d\ %T`">                          data inizio richiesta [DATA_START] = "$DATA_START
  echo "genric.sh "`date +%Y/%m/%d\ %T`">                              data fine richiesta [DATA_END] = "$DATA_END
  echo "genric.sh "`date +%Y/%m/%d\ %T`"> tipologia di aggregazione dei dati richiesti al DB [AGGREG] = "$AGGREG
  echo "genric.sh "`date +%Y/%m/%d\ %T`">           filtro sulla validita' dei dati richiesti [VALID] = "$VALID
  echo "genric.sh "`date +%Y/%m/%d\ %T`">            file contenente la lista dei sensori [LIST_SENS] = "$LIST_SENS
  echo "genric.sh "`date +%Y/%m/%d\ %T`">                radice del file di richiesta .ric [FILE_RIC] = "$FILE_RIC
  echo "genric.sh "`date +%Y/%m/%d\ %T`">               file con la lista nera dei sensori [BLCKFILE] = "$BLCKFILE
  echo "genric.sh "`date +%Y/%m/%d\ %T`">  LISTA DEI FLAG SPECIFICABILI DA RIGA DI COMANDO (1=fa quello che c'e' scritto):"
  echo "genric.sh "`date +%Y/%m/%d\ %T`">                         specificata data di inizio [flag_s] = "$flag_s
  echo "genric.sh "`date +%Y/%m/%d\ %T`">                           specificata data di fine [flag_e] = "$flag_e
  echo "genric.sh "`date +%Y/%m/%d\ %T`">                  specificata aggregazione dei dati [flag_f] = "$flag_f
  echo "genric.sh "`date +%Y/%m/%d\ %T`">        specificato filtro sulla validita' dei dati [flag_k] = "$flag_k
  echo "genric.sh "`date +%Y/%m/%d\ %T`">        specificata lista dei sensori da richiedere [flag_l] = "$flag_l
  echo "genric.sh "`date +%Y/%m/%d\ %T`">    specificato il nome del file .ric da richiedere [flag_n] = "$flag_n
  echo "genric.sh "`date +%Y/%m/%d\ %T`">  specificato il file con la lista nera dei sensori [flag_b] = "$flag_n
# controlla che siano soddisfatti i parametri sulla riga di comando
  if [[ $flag_s -eq 0 || $flag_e -eq 0 ]]
  then
    checkflags=1
    echo "1 "$checkflags
  fi
  if [[ $flag_f -eq 0 || $flag_k -eq 0 ]]
  then
    checkflags=1
    echo "2 "$checkflags
  fi
  if [ "$flag_n" -eq 0 ]
  then
    checkflags=1
    echo "3 "$checkflags
  fi
  if [ "$flag_l" -eq 0 ]
  then
    checkflags=1
    checkflags=0
    echo "4 "$checkflags
  fi
  if [[ $flag_b -eq 1 && ! -e $BLCKFILE ]]
  then
    checkflags=1
    echo "5 "$checkflags
  fi
  if [ "$checkflags" -eq 1 ]
  then
    echo "..genric.sh..ARPA Lombardia..UO meteo..CL.."`date +%Y/%m/%d\ %T`
    echo ""
    echo "Riga di comando:"
    echo ""
    echo "genric.sh -s data_start -e data_end -f aggregazione -k validita' -l lista [opzioni] -n file.ric -b blacklist"
    echo ""
    echo "Generatore di files .ric"
    echo ""
    echo "PARAMETRI RIGA DI COMANDO:"
    echo "-s DATA     -> data inizio richiesta AAAAMMGGHHmm"
    echo "-e DATA     -> data fine richiesta AAAAMMGGHHmm"
    echo "-f AGGREG   -> aggregazione dati: ORARI, GIORNALIERI"
    echo "-k VALIDITA -> filtro sulla validazione dei dati richiesti"
    echo "-l LIST     -> percorso completo al file contenente la lista dei codici"
    echo "               sensori da includere in .ric"
    echo "-n NOME     -> questo argomento contiene due informazioni:"
    echo "               (1) percorso completo in cui salvare il file/i files .ric"
    echo "               (2) radice principale del nome del file/dei files .ric"
    echo "OPZIONI IN RIGA DI COMANDO:"
    echo "-b          -> utilizza la lista nera dei sensori per filtrare la richiesta dati"
    echo "CODICE D'USCITA:"
    echo "(0) -> applicazione eseguita con successo"
    echo "(1) -> applicazione terminata in modo anomalo"
    exit 1
  fi
# @@@ [3.0] imposta correttamente NUM_SENS @@@
  if [ ! -e $LIST_SENS ]
  then
    echo "ecco"
    echo "genric.sh "`date +%Y/%m/%d\ %T`"> ATTENZIONE! file "$LIST_SENS" inesistente!"
#    exit 1
  else
    NUM_SENS=`wc -l $LIST_SENS | awk '{ print $1}' `
    echo "genric.sh "`date +%Y/%m/%d\ %T`">  numero di sensori richiesti [NUM_SENS] = "$NUM_SENS
    if [ "$NUM_SENS" -le 0 ]
    then
      echo "genric.sh "`date +%Y/%m/%d\ %T`"> ERRORE! numero di sensori in "$LIST_SENS" deve essere > 0 "
      exit 1
    fi
  fi 
# @@@ [5.0] ciclo @@@
  # inizializzazioni per l'esecuzione del ciclo
  echo $DATE >> $FILE_RIC
  echo $AGGREG >> $FILE_RIC
  echo $VALID >> $FILE_RIC
  echo "genric.sh "`date +%Y/%m/%d\ %T`">  radice definitiva del file .ric [FILE_RIC] = "$FILE_RIC
  # ciclo di lettura id sensori da LIST_SENS / scrittura su FILE_RIC
  # con eventuale blacklisting
  if [ -e $LIST_SENS ]
  then
    echo "ecco"
    {
    while read IDSENS
    do
      if [ "$flag_b" -eq 1  ]
      then
        flag_black=`grep -w $IDSENS $BLCKFILE | wc -l`
      else
        flag_black=0
      fi
      if [ "$flag_black" -eq 0  ]
      then
        # copia codice sensore nell'opportuno file di richiesta
        echo $IDSENS >> $FILE_RIC
      fi 
    done
    } < $LIST_SENS
  fi
  # trasforma il carriage return nel formato dos
#  $UNIX2DOS -q $FILE_RIC
# @@@ [6.0] FINE APPLICAZIONE: ESCI @@@
  echo "genric.sh "`date +%Y/%m/%d\ %T`"> genric.sh eseguito con successo!"
  exit 0
