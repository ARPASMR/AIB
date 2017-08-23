EADME della directory: "/home/meteo/programmi/getdata"
ultimo aggiornamento 2011/03/28 - Cristian Lussana (c.lussana@arpalombardia.it)

Contenuto della directory (oltre al presente file):
+ mysql_201103
|  directory contenente l'ultima versione dell'applicativo getdata che scarica
|  direttamente i dati dal DBmeteo
+ mysql_old
|  directory contenente le versioni vecchie dell'applicativo getdata che scarica
|  direttamente i dati dal DBmeteo
+ blacklist
|  directory contenete files di testo con balcklist per applicativi
+ getdata_straight_from_DBunico
   directory contenente la prima versione di getdata che scarica le osservazioni
   dal DBunico (attraverso un PC di scambio)

Osservazioni generali
Le Directories contenenti le varie componenti dell'applicativo "getdata" sono 
in generale organizzate:

Files presenti e breve descrizione:
- getdata_mysql.sh oppure getdata.sh
     script bash shell driver per la richiesta dei dati al DB
- genric_mysql.sh oppure genric.sh
     script bash shell richiamato da getdata.sh
- getdata_mysql.txt oppure getdata.txt
     file di testo contenente un riassunto delle operazioni eseguite 
     dall'applicativo getdata
Per quanto riguarda la connessione al DBmeteo:
- getcsv_recenti.R e getcsv_recenti_sub.R
     script R per scaricare i dati dalle tavole del DBmeteo contenenti
     solo gli ultimi 15 giorni (scarico veloce)
- getcsv_storici.R e getcsv_storici_sub.R
     script R per scaricare i dati dalle tavole del DBmeteo contenenti
     i dati su base annuale
Inoltre esistono anche gli applicativi (in getdata_straight_from_DBunico):
- segnalasensorimancanti.sh
     script bash shell di post-processing di una richiesta al DB
- segnalasensoriundefval.sh
     script bash shell di post-processing di una richiesta al DB
