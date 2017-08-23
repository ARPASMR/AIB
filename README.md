# AIB
La procedura per la creazione dei file e delle immagini necessarie alla produzione del Bollettino Anti Incendio Boschivo si compone di due fasi:
1. analisi: viene elaborato il file di copertura nevosa, i dati rilevati (nel dBMETEO, via R), viene fatto il calcolo degli indici (FORTRAN compilato) e una prima aggregazione su grigliato (GRASS), quindi l'aggregazione definitiva per aree di alletra (GRASS).
2. previsione: 


L'organizzazione degli script e dei programmi è la seguente (_nota: estratta solo la parte in milanone che corrisponde agli script; i programmi eseguibili e i relativi sorgenti non sono compresi in questo repository_)

**script**
alfuoco_roberto_dmod.sh
batch-grass6.sh
### interpolazione
oi_fwi.sh
## programmi
### interpolazione statistica/oi_fwi/applicativi
*tutti i file binari per l'interpolazione*
#### interpolazione statistica/oi_fwi/applicativi/log
*log per tipologia: precipitazione, radiazione,temperatura, umiditarelativa, vento*
### interpolazione statistica/oi_fwi/info
                      
